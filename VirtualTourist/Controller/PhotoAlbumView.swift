//
//  PhotoAlbumView.swift
//  VirtualTourist
//
//  Created by Lindsey Gjoraas on 7/23/18.
//  Copyright © 2018 Developed by Gjoraas. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumView: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noImagesLabel: UILabel!
    
    
    
    // MARK: Properties
    var insertedIndices: [IndexPath]!
    var updatedIndices: [IndexPath]!
    var deletedIndices: [IndexPath]!
    
    let latitudeSpan: Double = 2.0
    let longitudeSpan: Double = 2.0
    var annotation: MKPointAnnotation?
    var pin: Pin?
    var photos: [Photo] = [] // array containing photos to store
    
    var dataController:DataController?
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    let reuseIdentifier = "photoCell"
    
    // MARK: Flickr API variables
    var session = URLSession.shared
    
    var imageURLArray : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // place pin on the mapview
        putPinOnMap()
        guard let pin = pin else { return }
        setUpFetchedControllerWithPin(pin)
        
        if let photos = pin.photos, photos.count == 0 {
            newCollectionButton.isEnabled = false
            let latitude = Double(pin.latitude!)!
            let longitude = Double(pin.longitude!)!
            Client.sharedInstance.getFlickrImages(latitude: latitude, longitude: longitude) { (success, photosArray) in
                if success == true {
                        for index in 0..<photosArray.count {
                            let photoDictionary = photosArray[index] as [String: AnyObject]
                            /* GUARD: Does our photo have a key for 'url_m'? */
                            guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                                print("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
                                return }
                            let imageURL = URL(string: imageUrlString)
                            let imageData = try? Data(contentsOf: imageURL!)
                            let photo = Photo(imageData: imageData!, forPin: self.pin!, context: (self.dataController?.viewContext)!)
                            self.photos.append(photo)
                            self.imageURLArray.append(imageUrlString)
                        }
                    self.storePhotos(self.photos, forPin: self.pin!)
                    performUIUpdatesOnMain {
                        self.newCollectionButton.isEnabled = true
                    }
                } else {
                    self.newCollectionButton.isEnabled = true
                }
            }
        }
    }
    
    @IBAction func newCollectionButttonPressed(_ sender: Any) {
        
        for photos in fetchedResultsController.fetchedObjects! {
            dataController?.viewContext.delete(photos)
        }
        try? dataController?.viewContext.save()
        newCollectionButton.isEnabled = false
        
        // need to disable the collection button pressing in this case***!!!
        guard let pin = pin else { return }
        let latitude = Double(pin.latitude!)!
        let longitude = Double(pin.longitude!)!
        Client.sharedInstance.getFlickrImages(latitude: latitude, longitude: longitude) { (success, photosArray) in
            if success == true {
                    for index in 0..<photosArray.count {
                        let photoDictionary = photosArray[index] as [String: AnyObject]
                        /* GUARD: Does our photo have a key for 'url_m'? */
                        guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                            print("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
                            return }
                        let imageURL = URL(string: imageUrlString)
                        let imageData = try? Data(contentsOf: imageURL!)
                        let photo = Photo(imageData: imageData!, forPin: self.pin!, context: (self.dataController?.viewContext)!)
                        self.photos.append(photo)
                        self.imageURLArray.append(imageUrlString)
                    }
                self.storePhotos(self.photos, forPin: self.pin!)
                performUIUpdatesOnMain {
                    self.newCollectionButton.isEnabled = true
                }
            } else {
                self.newCollectionButton.isEnabled = true
            }
        }
        collectionView.reloadData()
    }
    
    
    // MARK: Helpers
    func putPinOnMap() {
        // check if pin exists otherwise return
        guard let pin = pin else { return }
        let latitude = Double(pin.latitude!)!
        let longitude = Double(pin.longitude!)!
        let center = CLLocationCoordinate2DMake(latitude, longitude)
        let span = MKCoordinateSpanMake(latitudeSpan, longitudeSpan)
        let region = MKCoordinateRegionMake(center, span)
        self.mapView.setRegion(region, animated: true)
        
        // create an annotation from the center coordinate
        let annotation = MKPointAnnotation()
        annotation.coordinate = center
        self.mapView.addAnnotation(annotation)
    }
    
    private func setUpFetchedControllerWithPin(_ pin: Pin)
    {
        let fr = NSFetchRequest<Photo>(entityName: Photo.name)
        fr.sortDescriptors = []
        fr.predicate = NSPredicate(format: "pin == %@", argumentArray: [pin])
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: dataController!.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        // Start the fetched results controller
        var error: NSError?
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            print("\(#function) Error performing initial fetch: \(error)")
        }
    }
    
    private func storePhotos(_ photos: [Photo], forPin: Pin) {
        for photo in photos {
            performUIUpdatesOnMain {
                if let imageData = photo.imageData {
                    _ = Photo(imageData: imageData, forPin: forPin, context: (self.dataController?.viewContext)!)
                    do {
                        try self.dataController?.viewContext.save()
                    } catch {
                        print("Unable to store photos to persistent store")
                    }
                }
            }
        }
    }
}
