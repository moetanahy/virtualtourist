//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Moe El Tanahy on 24/04/2020.
//  Copyright © 2020 Bright Creations. All rights reserved.
//

import UIKit
import MapKit
import CoreData

// MARK: - MapViewController:UIViewController - Main UI Class

class MapViewController: UIViewController {
    
    // MARK: - Variables
    
    let mapDefaultKey = ProjectCustomKeys.mapDefaultKey.rawValue
    
    var pins: [Pin] = []
    
    var dataController:DataController = DataController.getInstance()
    
//    let myLongPress: UILongPressGestureRecognizer!;
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupMapView()
        loadPins()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        mapView.removeGestureRecognizer(myLongPress)
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
        let  myLongPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
        myLongPress.addTarget(self, action: #selector(recognizeLongPress(_:)))
        
        // Added UIGestureRecognizer to MapView.
        mapView.addGestureRecognizer(myLongPress)
        
        
    }
    
    // MARK: - Loading Pins
    private func loadPins() {
        print("loadPins called")
        // this is how we get the data
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            pins = result
//            createAnnotations()
            self.mapView.addAnnotations(pins)
        }
        
    }
    
    // very similar to what I used with OnTheMap
    func createAnnotations() {
        
        var annotations = [MKPointAnnotation]()
        
        // The "locations" array is loaded with the sample data below. We are using the dictionaries
        // to create map annotations. This would be more stylish if the dictionaries were being
        // used to create custom structs. Perhaps StudentLocation structs.
        
        for location in self.pins {
            
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            let lat = CLLocationDegrees(location.lat)
            let long = CLLocationDegrees(location.lon)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "View Pics"
//            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        
        // When the array is complete, we add the annotations to the map.
        self.mapView.addAnnotations(annotations)
        
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
        myPin.title = "View Pics"
        //myPin.subtitle = "subtitle"
        
        // store to the Core Data
        let newPin = Pin(context: dataController.viewContext)
        newPin.title = "View Pics"
        newPin.lat = myCoordinate.latitude
        newPin.lon = myCoordinate.longitude
        try? dataController.viewContext.save()

        // Added pins to MapView.
        mapView.addAnnotation(newPin)
        // append pin to list
//        pins.append(newPin)
    }
    

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
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("calloutAccessoryControlTapped called!")
        // this is called when Call Out is clicked on the pin
        let myPin = view.annotation as! Pin
        
        // Segue - showPhotoAlbum
        let photoAlbumViewController = self.storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        photoAlbumViewController.pin = myPin
//        self.present(photoAlbumViewController, animated: true, completion: nil)
        self.navigationController?.pushViewController(photoAlbumViewController, animated: true)
        
    }
    
    
    
}

