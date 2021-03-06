//
//  TravelLocationsMapVC.swift
//  VirtualTourist
//
//  Created by Lindsey Gjoraas on 7/22/18.
//  Copyright © 2018 Developed by Gjoraas. All rights reserved.
//

import UIKit
import MapKit
    
class TravelLocationsMapVC: UIViewController, UIGestureRecognizerDelegate, MKMapViewDelegate {
    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: Properties


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add tap and hold gesture recognizer to view to drop a pin on map
        addTapandHoldGestureRecognizer()
        
        // load map view to its center and zoom level if app was opened before which saved peristent data to UserDefaults
        if let latitude = UserDefaults.standard.object(forKey: "latitude"),
           let longitude = UserDefaults.standard.object(forKey: "longitude"),
           let latitudeSpan = UserDefaults.standard.object(forKey: "latitudeDelta"),
           let longitudeSpan = UserDefaults.standard.object(forKey: "longitudeDelta") {
            
            let center = CLLocationCoordinate2DMake(latitude as! Double, longitude as! Double)
            let span = MKCoordinateSpanMake(latitudeSpan as! Double, longitudeSpan as! Double)
            let region = MKCoordinateRegionMake(center, span)
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    func addTapandHoldGestureRecognizer() {
        let tapAndHoldPress = UILongPressGestureRecognizer(target: self, action: #selector(tapAndHoldPressed(sender:)))
        tapAndHoldPress.minimumPressDuration = 0.5
        tapAndHoldPress.delegate = self
        self.mapView.addGestureRecognizer(tapAndHoldPress)
    }

    
    @IBAction func tapAndHoldPressed(sender: UILongPressGestureRecognizer)  {
        
        // Get the coordinates of where on the map the user touched
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = touchCoordinate
        self.mapView.addAnnotation(annotation)
        
        
    }
    
    // this function gets called whenever the region or zoom level/center of the map has changed. Save the map's region and span in this function to UserDefaults
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        UserDefaults.standard.set(self.mapView.centerCoordinate.latitude, forKey: "latitude")
        UserDefaults.standard.set(self.mapView.centerCoordinate.longitude, forKey: "longitude")
        UserDefaults.standard.set(self.mapView.region.span.latitudeDelta, forKey: "latitudeDelta")
        UserDefaults.standard.set(self.mapView.region.span.longitudeDelta, forKey: "longitudeDelta")
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // transfer data to PhotoAlbumView and then present it
        guard let albumVC = storyboard?.instantiateViewController(withIdentifier: "albumVC") as? PhotoAlbumView else { return }
        if let annotation = view.annotation {
            albumVC.latitude = annotation.coordinate.latitude
            albumVC.longitude = annotation.coordinate.longitude
            albumVC.annotation = annotation as? MKPointAnnotation
        }
        self.navigationController?.pushViewController(albumVC, animated: true)
    }
}

extension TravelLocationsMapVC {
    
    
}
