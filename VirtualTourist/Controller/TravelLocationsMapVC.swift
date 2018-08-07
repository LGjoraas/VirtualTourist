//
//  TravelLocationsMapVC.swift
//  VirtualTourist
//
//  Created by Lindsey Gjoraas on 7/22/18.
//  Copyright © 2018 Developed by Gjoraas. All rights reserved.
//

import UIKit
import MapKit
import CoreData
    
class TravelLocationsMapVC: UIViewController, UIGestureRecognizerDelegate, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Properties
    var dataController:DataController!
    
    //var fetchedResultsController:NSFetchedResultsController<Pin>!

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
        
        
        // load pins that are in persistent store if any
        if let pins = loadAllPins() {
            showPins(pins)
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
        
        // save pin to persistent store
        let pin = Pin(latitude: String(annotation.coordinate.latitude), longitude: String(annotation.coordinate.longitude), context: dataController.viewContext)
        do {
            try dataController.viewContext.save()
        } catch {
            print("Unable to save pin to persistent store")
        }
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
            let lat = String(annotation.coordinate.latitude)
            let long = String(annotation.coordinate.longitude)
            let pin = loadPin(latitude: lat, longitude: long)
            albumVC.pin = pin
            albumVC.dataController = dataController
        }
        self.navigationController?.pushViewController(albumVC, animated: true)
    }
    
    // MARK: Helper functions
    
    private func fetchAllPins(_ predicate: NSPredicate? = nil, entityName: String, sorting: NSSortDescriptor? = nil) throws -> [Pin]? {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fr.predicate = predicate
        if let sorting = sorting {
            fr.sortDescriptors = [sorting]
        }
        guard let pin = try dataController.viewContext.fetch(fr) as? [Pin] else {
            return nil
        }
        return pin
    }
    
    func fetchPin(_ predicate: NSPredicate, entityName: String, sorting: NSSortDescriptor? = nil) throws -> Pin? {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fr.predicate = predicate
        if let sorting = sorting {
            fr.sortDescriptors = [sorting]
        }
        guard let pin = (try dataController.viewContext.fetch(fr) as! [Pin]).first else {
            return nil
        }
        return pin
    }
    
    private func loadAllPins() -> [Pin]? {
        var pins: [Pin]?
        do {
            try pins = fetchAllPins(entityName: Pin.name)
        } catch {
            print("\(#function) error:\(error)")
        }
        return pins
    }
    
    private func loadPin(latitude: String, longitude: String) -> Pin? {
        let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", latitude, longitude)
        var pin: Pin?
        do {
            try pin = fetchPin(predicate, entityName: Pin.name)
        } catch {
            print("\(#function) error:\(error)")
        }
        return pin
    }
    
    private func showPins(_ pins: [Pin]) {
        for pin in pins {
            let annotation = MKPointAnnotation()
            let lat = Double(pin.latitude!)!
            let lon = Double(pin.longitude!)!
            annotation.coordinate = CLLocationCoordinate2DMake(lat, lon)
            mapView.addAnnotation(annotation)
        }
    }
}
