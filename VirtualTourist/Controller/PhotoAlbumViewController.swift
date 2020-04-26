//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Moe El Tanahy on 24/04/2020.
//  Copyright © 2020 Bright Creations. All rights reserved.
//

import UIKit
import MapKit
import CoreData

// MARK: - PhotoAlbumViewController

class PhotoAlbumViewController: UIViewController {

    // MARK: - Properties
    
    let dataController: DataController = DataController.getInstance()
    
    var pin: Pin!
    
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - LifeCycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        
    }
    
    fileprivate func setupMapView() {
        
        // set the delegate
        mapView.delegate = self
        
        // Designate center point.
        let center: CLLocationCoordinate2D = pin!.coordinate
        // Set center point in MapView.
        mapView.setCenter(center, animated: true)
        self.mapView.addAnnotation(pin)
        
    }
    
}

extension PhotoAlbumViewController: MKMapViewDelegate {
    
    // Delegate method called when addAnnotation is done.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
}
