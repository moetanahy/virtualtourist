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
    
    private let itemsPerRow: CGFloat = 2
    private let insets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    
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
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pin-\(pin.creationDate!)-photos")
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
        
        // we have two scenarios
        // 1. The binary image which this image uses has already been downloaded
        // 2. It hasn't been downloaded yet, so this is a chance to download it
        
        if let photoBinaryImage = aPhoto.image {
            cell.imageView.image = UIImage(data: photoBinaryImage)
            
        } else if let photoURL = aPhoto.url {
            guard let url = URL(string: photoURL) else {
                print("collectionView - url could not be converted for some reason")
                return cell
            }
            // set the placeholder image until I get the real data
            cell.imageView.image = UIImage(named: "ImagePlaceholder")
            // need to download something here
            FlickrClient.getFileData(from: url) { (data, urlResponse, error) in
                // set the image in the object
                guard let data = data else {
                    print("no data returned for file")
                    return
                }
                aPhoto.image = data
                cell.imageView.image = UIImage(data: data)
                try? self.dataController.viewContext.save()
            }
            
//            getFileData
            
            
//            cell.imageView.image.setImage(with: url, placeholder: UIImage(named: "ImagePlaceholder"), options: nil, progressBlock: nil) { (img, err, cacheType, url) in
//                if ((err) != nil) {
//
//                } else {
//                    aPhoto.data = img?.pngData()
//                    try? self.dataController.viewContext.save()
//                }
//            }
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        // an image has been clicked
        
    }
    
}

extension PhotoAlbumViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = insets.right * (itemsPerRow + 1)
        let availableWidth = view.frame.width - padding
        let widthOfItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthOfItem, height: widthOfItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return insets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return insets.right
    }
}
