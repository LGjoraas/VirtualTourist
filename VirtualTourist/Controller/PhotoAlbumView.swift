//
//  PhotoAlbumView.swift
//  VirtualTourist
//
//  Created by Lindsey Gjoraas on 7/23/18.
//  Copyright © 2018 Developed by Gjoraas. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumView: UIViewController, MKMapViewDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noImagesLabel: UILabel!
    
    // MARK: Properties
    var latitude: Double?
    var longitude: Double?
    let latitudeSpan: Double = 2.0
    let longitudeSpan: Double = 2.0
    var annotation: MKPointAnnotation?
    var pin: Pin?
    
    let reuseIdentifier = "photoCell"
    
    // MARK: Flickr API variables
    var session = URLSession.shared
    
    var imageURLArray : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newCollectionButton.isEnabled = false
        
        if let latitude = latitude, let longitude = longitude, let annotation = annotation {
            let center = CLLocationCoordinate2DMake(latitude, longitude)
            let span = MKCoordinateSpanMake(latitudeSpan, longitudeSpan)
            let region = MKCoordinateRegionMake(center, span)
            self.mapView.setRegion(region, animated: true)
            self.mapView.addAnnotation(annotation)
        }
        else
        {
            print("Could not set the map view properly to its region")
        }
        
        getFlickrImages { (success) in
            if success == true {
                performUIUpdatesOnMain {
                    self.collectionView.reloadData()
                    self.newCollectionButton.isEnabled = true
                }
            }
        }
    }
    
    @IBAction func newCollectionButttonPressed(_ sender: Any) {
        
        newCollectionButton.isEnabled = false
        
        // need to disable the collection button pressing in this case***!!!
        getFlickrImages { (success) in
            if success == true {
                performUIUpdatesOnMain {
                    self.collectionView.reloadData()
                    self.newCollectionButton.isEnabled = true
                }
            }
        }
    }
}

// MARK: UICollectionView Functions
extension PhotoAlbumView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageURLArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoAlbumViewCell
        
        let imageURL = URL(string: self.imageURLArray[indexPath.row])
        if let imageData = try? Data(contentsOf: imageURL!) {
            cell.imageView.image = UIImage(data: imageData)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.imageURLArray.remove(at: indexPath.row)
        collectionView.deleteItems(at: [indexPath])
    }
}


// MARK : Flickr functions

extension PhotoAlbumView {
    
    // function to load images from flickr to put into an array
    private func getFlickrImages(completionHander: @escaping (_ success: Bool) -> Void) {
        
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.BoundingBox: bboxString(),
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            //Constants.FlickrParameterKeys.NumberOfPictures:
                //Constants.FlickrParameterValues.PicturesToRetrieve,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
        // create a getImagesFromFlickrBySearch method here instead
        getImagesFromFlickrBySearch(methodParameters as [String : AnyObject]) { (success) in
            if success == true {
                completionHander(true)
            }
        }
    }
    
    private func getImagesFromFlickrBySearch(_ methodParameters: [String: AnyObject], completionHander: @escaping (_ success: Bool) -> Void) {
        
        // initialize imageURLArray to have zero elements
        self.imageURLArray = []
        
        // create session and request
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            //print(data)
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                print("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            //print(parsedResult["photos"])
            /* GUARD: Is "photos" key in our result? */
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                print("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            /* GUARD: Is the "photo" key in photosDictionary? */
            guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                print("Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
                return
            }
            
            if photosArray.count == 0 {
                performUIUpdatesOnMain {
                    self.view.bringSubview(toFront: self.noImagesLabel)
                }
            }
            
            for index in 0..<photosArray.count {
                let photoDictionary = photosArray[index] as [String: AnyObject]
                /* GUARD: Does our photo have a key for 'url_m'? */
                guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                    print("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
                    return }
                self.imageURLArray.append(imageUrlString)
            }
            completionHander(true)
            
        }
        // start the task!
        task.resume()
    }
    
    // MARK: Helper for Creating a URL from Parameters
    
    private func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    private func bboxString() -> String {
        // ensure bbox is bounded by minimum and maximums
        if let latitude = annotation?.coordinate.latitude, let longitude = annotation?.coordinate.longitude {
            let minimumLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
            let minimumLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
            let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
            let maximumLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
            return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
        } else {
            return "0,0,0,0"
        }
    }
}
