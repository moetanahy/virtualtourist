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
    // MARK: Variables
    let dataController: DataController = DataController.getInstance()
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    var pin: Pin!
    
    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Lifecycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupFetchedResultsController()
        loadDataFromNetwork(forceRefresh: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    // MARK: - Set Up for the View, Fetching Controller & Getting Data
    
    fileprivate func setupMapView() {
        
        // set the delegate
        mapView.delegate = self
        
        // Designate center point.
        let center: CLLocationCoordinate2D = pin!.coordinate
        // Set center point in MapView.
        mapView.setCenter(center, animated: true)
        self.mapView.addAnnotation(pin)
        
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", self.pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pin-\(pin.creationDate)-photos")
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    // Reloads data from the network
    // @forceRefresh allows us to know if would like to force it
    // if True - will refresh even if there is data
    // if False - will ONLY refresh if there is no data
    fileprivate func loadDataFromNetwork(forceRefresh: Bool = false) {
        
        if (forceRefresh) {
            // asked to reload new data
            uiLoadingData(loading: true)
            FlickrClient.searchAndSavePhotos(pin: pin, completion: self.handlePhotoResults(success: error:))
        } else if pin.photos!.count == 0 {
            // we don't have any photos, please refresh
            uiLoadingData(loading: true)
            FlickrClient.searchAndSavePhotos(pin: pin, completion: self.handlePhotoResults(success: error:))
        }
        // else do nothing, keep data as-is
        
    }
    
    func uiLoadingData(loading: Bool) {
        // lets the UI know we're loading data
        self.newCollectionButton.isEnabled = loading
    }
    
    
    func handlePhotoResults(success: Bool?, error: Error?) {
        print("handlePhotoResults")
        // do something here
//        guard let searchPhotoResponse = searchPhotoResponse else {
//            // there is an error here
//            // was unable to load photos
//            print("had some form of issue")
//            self.displayNoPhotosFound()
//            showAlert(message: error?.localizedDescription ?? "")
//            return
//        }
        
        
        
//        searchPhotoResponse.decide
        
    }
    
    func displayNoPhotosFound() {
        
    }
    
}

// this is needed for the results controller
extension PhotoAlbumViewController:NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
            break
        case .delete:
            collectionView.deleteItems(at: [newIndexPath!])
            break
        case .update:
            collectionView.reloadItems(at: [indexPath!])
        case .move:
            collectionView.moveItem(at: indexPath!, to: newIndexPath!)
        }
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

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    // MARK: Collection View Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let photos = self.pin.photos {
            return photos.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        let aPhoto = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionCell", for: indexPath) as! PhotoCollectionViewCell
        
        // Configure cell
        if let photoData = aPhoto.data {
            cell.imageView.image = UIImage(data: photoData)
        } else if let photoURL = aPhoto.url {
            guard let url = URL(string: photoURL) else {
                print("no!")
                return cell
            }
            cell.imageView.kf.setImage(with: url, placeholder: UIImage(named: "Placeholder"), options: nil, progressBlock: nil) { (img, err, cacheType, url) in
                if ((err) != nil) {
                    
                } else {
                    aPhoto.data = img?.pngData()
                    try? self.dataController.viewContext.save()
                }
            }
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        // an image has been clicked
        
    }
    
}
