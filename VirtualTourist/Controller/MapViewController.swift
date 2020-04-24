//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Moe El Tanahy on 24/04/2020.
//  Copyright © 2020 Bright Creations. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    // MARK: - Properties
    
    // MARK: Variables
    
    let mapDefaultKey = Keys.mapDefaultKey.rawValue
    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Functions
    
    // MARK: Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupMapView()
        
    }
    
    // MARK: Setting up the Map
    
    // sets up the map the way we want it to be
    fileprivate func setupMapView() {
        
        // set the delegate
        mapView.delegate = self
        
        // Designate center point.
        let center: CLLocationCoordinate2D = UserDefaults.standard.value(forKey: self.mapDefaultKey)
        
        
        
    }
    
//    // A method called when long press is detected.
//    // https://medium.com/@calmone/ios-mapkit-in-swift-4-drop-the-pin-at-the-point-of-long-press-2bed878fdf93
//    @objc private func recognizeLongPress(_ sender: UILongPressGestureRecognizer) {
//        // Do not generate pins many times during long press.
//        if sender.state != UIGestureRecognizer.State.began {
//            return
//        }
//
//        // Get the coordinates of the point you pressed long.
//        let location = sender.location(in: _mapView)
//
//        // Convert location to CLLocationCoordinate2D.
//        let myCoordinate: CLLocationCoordinate2D = _mapView.convert(location, toCoordinateFrom: _mapView)
//
//        // Generate pins.
//        let myPin: MKPointAnnotation = MKPointAnnotation()
//
//        // Set the coordinates.
//        myPin.coordinate = myCoordinate
//
//        // Set the title.
//        myPin.title = "title"
//
//        // Set subtitle.
//        myPin.subtitle = "subtitle"
//
//        // Added pins to MapView.
//        _mapView.addAnnotation(myPin)
//    }

}

// MARK: MapViewController:MKMapViewDelegate - Delegate class

extension MapViewController: MKMapViewDelegate {
    
        
    
}

