//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Moe El Tanahy on 24/04/2020.
//  Copyright © 2020 Bright Creations. All rights reserved.
//

import UIKit
import MapKit

// MARK: - MapViewController:UIViewController - Main UI Class

class MapViewController: UIViewController {
    
    // MARK: - Variables
    
    let mapDefaultKey = ProjectCustomKeys.mapDefaultKey.rawValue
    
    var dataController:DataController = DataController.getInstance()
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupMapView()
        
    }
    
    // -------------------------------------------------------------------------
    // MARK:- Setting up the Map
    
    // sets up the map the way we want it to be
    fileprivate func setupMapView() {
        
        // set the delegate
        mapView.delegate = self
        
        // get the location of the map to display
        let locationDict = UserDefaults.standard.value(forKey: mapDefaultKey) as! [String:Double]
        // Designate center point.
        let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(locationDict["lat"]!, locationDict["lon"]!)
        // Set center point in MapView.
        mapView.setCenter(center, animated: true)
        
        // Generate long-press UIGestureRecognizer.
        let myLongPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
        myLongPress.addTarget(self, action: #selector(recognizeLongPress(_:)))
        
        // Added UIGestureRecognizer to MapView.
        mapView.addGestureRecognizer(myLongPress)
        
        
    }
    
    // MARK: - Adding New Pins
    
    // A method called when long press is detected.
    @objc private func recognizeLongPress(_ sender: UILongPressGestureRecognizer) {
        // Do not generate pins many times during long press.
        if sender.state != UIGestureRecognizer.State.began {
            return
        }

        // Get the coordinates of the point you pressed long.
        let location = sender.location(in: mapView)

        // Convert location to CLLocationCoordinate2D.
        let myCoordinate: CLLocationCoordinate2D = mapView.convert(location, toCoordinateFrom: mapView)

        // Generate pins.
        let myPin: MKPointAnnotation = MKPointAnnotation()

        // Set the coordinates.
        myPin.coordinate = myCoordinate

        // Set the title.
        myPin.title = "Lat(\(myCoordinate.latitude)) Lon(\(myCoordinate.longitude))"
        //myPin.subtitle = "subtitle"
        
        // store to the core Data
        let newPin = Pin(context: dataController.viewContext)
        newPin.lat = myCoordinate.latitude
        newPin.lon = myCoordinate.longitude
        try? dataController.viewContext.save()

        // Added pins to MapView.
        mapView.addAnnotation(myPin)
    }
    
    /// Adds a new notebook to the end of the `notebooks` array
//    func addPin(name: String) {
//        let notebook = Notebook(context: dataController.viewContext)
//        notebook.name = name
//        notebook.creationDate = Date()
//        try? dataController.viewContext.save()
//    }
    
    

}

// MARK: - MapViewController:MKMapViewDelegate - Delegate class

extension MapViewController: MKMapViewDelegate {
        
    // Tells the delegate that the region displayed by the map view just changed.
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated: Bool) {
        debugPrint("mapView regionDidChangeAnimated called")
        let center = mapView.centerCoordinate
        
        let newMapCenter = [
            "lat": center.latitude,
            "lon": center.longitude
        ]
        UserDefaults.standard.set(newMapCenter, forKey: ProjectCustomKeys.mapDefaultKey.rawValue)
    }
    
    // Delegate method called when addAnnotation is done.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let myPinIdentifier = "PinAnnotationIdentifier"
        
        // Generate pins.
        let myPinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: myPinIdentifier)
        
        // Add animation.
        myPinView.animatesDrop = true
        
        // Display callouts.
        myPinView.canShowCallout = false
        
        // Set annotation.
        myPinView.annotation = annotation
        
        print("latitude: \(annotation.coordinate.latitude), longitude: \(annotation.coordinate.longitude)")
        
        return myPinView
    }
    
    
    
}

