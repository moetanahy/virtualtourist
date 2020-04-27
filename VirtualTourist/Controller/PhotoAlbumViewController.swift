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
        
        collectionView.dataSource = self
        collectionView.delegate = self
        self.view.isUserInteractionEnabled = true
        collectionView.isUserInteractionEnabled = true
        collectionView.allowsSelection = true
        
//        let tap = UITapGestureRecognizer(target: self, action:Selector("dismissKeyboard"))
//        view.addGestureRecognizer(tap)

//        tap.cancelsTouchesInView = false
        
        //
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
//        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
//        tap.cancelsTouchesInView = false
//        collectionView.addGestureRecognizer(tap)
        
        setupFetchedResultsController()
        loadDataFromNetwork(forceRefresh: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    deinit {
        mapView.delegate = nil
        mapView = nil
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
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pin-\(pin.objectID)-photos")
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
        print("loadDataFromNetwork called")
        print(pin.photos!.count)
        if (forceRefresh) {
            // asked to reload new data
            print("loadDataFromNetwork - forceRefresh = true - CALLING API")
            uiLoadingData(loading: true)
            FlickrClient.searchAndSavePhotos(pin: pin, completion: self.handlePhotoResults(success: error:))
        } else if pin.photos!.count == 0 {
            // we don't have any photos, please refresh
            print("loadDataFromNetwork - forceRefresh = false - count is 0, so CALLING API")
            uiLoadingData(loading: true)
            FlickrClient.searchAndSavePhotos(pin: pin, completion: self.handlePhotoResults(success: error:))
        } else {
            // else do nothing, keep data as-is
            print("loadDataFromNetwork - forceRefresh = false - count > 0, Doing nothing")
        }
        
    }
    
    // MARK: - Data Manipulation
    
    func removePhoto(photo: Photo) {
        dataController.viewContext.delete(photo)
        do {
            try dataController.viewContext.save()
        } catch {
            print(error)
            print("Error - Cannot remove photo")
        }
    }
    
    // resets photos for this location
    @IBAction func resetPhotos(_ sender: Any) {
        // I think this causes a problem as this means I'm deleting from
        // the values in the set while traversing it
        //        if let photos = pin.photos {
        //            for photo in photos  {
        //                var thisPhoto = photo as! Photo
        //                dataController.viewContext.delete(thisPhoto)
        //                do {
        //                    try dataController.viewContext.save()
        //                } catch {
        //                    print("Error saving")
        //                }
        //            }
        //        }
        print("resetPhotos being called")
        if let photos = fetchedResultsController.fetchedObjects {
            print(photos.count)
            for photo in photos {
                print(photo.url)
                removePhoto(photo: photo)
//                break
            }
        }
        print("Got here")
//        collectionView.reloadData()
//        //        setupFetchedResultsController()
//        loadDataFromNetwork(forceRefresh: true)
    }
    
    func handlePhotoResults(success: Bool?, error: Error?) {
        print("handlePhotoResults")
        if !success! {
            DispatchQueue.main.async {
                self.uiLoadingData(loading:false)
                self.showAlert(message: "Unable to load data - \(error)")
            }
            return
        } else {
            // data has already been updated by API at this point
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.uiLoadingData(loading:false)
            }
        }
        
    }
    
    // MARK: - UI Manipulation
    
    func uiLoadingData(loading: Bool) {
        // lets the UI know we're loading data
        self.newCollectionButton.isEnabled = loading
    }
    
    func displayNoPhotosMessage() {
        let message = "No photos found."
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.collectionView.bounds.size.width, height: self.collectionView.bounds.size.height))
        messageLabel.text = message
        messageLabel.textAlignment = .center;
        messageLabel.sizeToFit()
        self.collectionView.backgroundView = messageLabel;
    }
    
    func removeNoPhotosMessage() {
        self.collectionView.backgroundView = nil
    }
    
    
}

// this is needed for the results controller
extension PhotoAlbumViewController:NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        print("controller function")
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
            break
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
            break
        default: ()
        }
//        switch type {
//        case .insert:
//            collectionView.insertItems(at: [newIndexPath!])
//            break
//        case .delete:
//            collectionView.deleteItems(at: [indexPath!])
//            break
//        default: ()
//
////        case .update:
////            collectionView.reloadItems(at: [indexPath!])
////        case .move:
////            collectionView.moveItem(at: indexPath!, to: newIndexPath!)
//        }
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
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
}

extension PhotoAlbumViewController: UICollectionViewDataSource {
    
    // MARK: Collection View Data Source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let numberOfItems:Int = fetchedResultsController.sections?[section].numberOfObjects ?? 0
        
        print("collectionView = numberOfItemsInSection - \(numberOfItems)")
        
        if (fetchedResultsController.sections?[section].numberOfObjects ?? 0 == 0) {
            // did it come to here
            print("It found 0 results")
            self.displayNoPhotosMessage()
        } else {
            print("It found 1 or more results")
            self.removeNoPhotosMessage()
        }
        
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
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
                
                DispatchQueue.main.async {
                    cell.imageView.image = UIImage(data: data)
                }
                aPhoto.image = data
                try? self.dataController.viewContext.save()
            }
        }
        return cell
        
    }
    
}

extension PhotoAlbumViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        print("Did Highlight")
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Image Clicked")
        let photo = fetchedResultsController.object(at: indexPath)
        self.removePhoto(photo: photo)
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
