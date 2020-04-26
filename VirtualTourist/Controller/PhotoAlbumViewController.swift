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
        setupDataCollection()
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
    
    fileprivate func setupDataCollection() {
        
        print("setupDataCollection")
        
        // Different Scenarios
        // 1. Pin has locations
        // 2. Pin has No Locations and API returns new data
        // 3. Pin has No Locations and API returns NO data
        
        print (pin.photos!.count)
        if pin.photos!.count == 0 {
            // load what's in the pin collection
            print("No Pin Photos - load from API")
            FlickrClient.searchPhotos(pin: pin, completion: self.handlePhotoResults(count: searchPhotoResponse: error:))
        } else {
            // have some pins
            // load from the API
            
        }
        
    }
    
    func handlePhotoResults(count: Int, searchPhotoResponse: SearchPhotoResponse?, error: Error?) {
        print("handlePhotoResults")
        print("Count of \(count)")
        // do something here
        guard let searchPhotoResponse = searchPhotoResponse else {
            // there is an error here
            // was unable to load photos
            print("had some form of issue")
            self.displayNoPhotosFound()
            showAlert(message: error?.localizedDescription ?? "")
            return
        }
        
//        searchPhotoResponse.decide
        
        
    }
    
    func displayNoPhotosFound() {
        
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
