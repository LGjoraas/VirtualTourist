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
    
    // MARK: Properties
    var latitude: Double?
    var longitude: Double?
    let latitudeSpan: Double = 2.0
    let longitudeSpan: Double = 2.0
    var annotation: MKPointAnnotation?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let latitude = latitude, let longitude = longitude, let annotation = annotation {
            print("LATITUDE = \(latitude)")
            let center = CLLocationCoordinate2DMake(latitude, longitude)
            let span = MKCoordinateSpanMake(latitudeSpan, longitudeSpan)
            let region = MKCoordinateRegionMake(center, span)
            print("REGION = \(region)")
            self.mapView.setRegion(region, animated: true)
            self.mapView.addAnnotation(annotation)
        }
        else
        {
            print("Could not set the map view properly to its region")
        }
    }
    
    
    @IBAction func newCollectionButttonPressed(_ sender: Any) {
    }
    
//        let space:CGFloat = 4.0
//        let dimensionWidth = (view.frame.size.width - (3 * space)) / 3.0
//        let dimensionHeight = (view.frame.size.height - (3 * space)) / 2.0
//
////
//        collectionView.minimumInteritemSpacing = space
//        collectionView.minimumLineSpacing = space
//        collectionView.itemSize = CGSize(width: dimensionWidth, height: dimensionHeight)
    
    
//    override func viewWillAppear(_ animated: Bool) {
//        collectionView?.reloadData()
//    }
    
    
    
    // MARK: UICollectionViewDataSource
    
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return memes.count
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
//        let smallMeme = self.memes[(indexPath as NSIndexPath).row]
//        cell.memeImage?.image = smallMeme.memeImage
//        return cell
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let memeGeneratorVC = storyboard?.instantiateViewController(withIdentifier: "memeDetail") as! MemeDetailViewController
//        memeGeneratorVC.memes = self.memes[(indexPath as NSIndexPath).row]
//        self.navigationController!.pushViewController(memeGeneratorVC, animated: true)
//    }
    

    // MARK: newCollection Button pressed
//    @IBAction func newCollectionPressed(_ sender: Any) {
//        collectionView?.reloadData()
//    }
    
    
}
