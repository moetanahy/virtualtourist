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
    var dataController: DataController!
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
        
        dataController = DataController.getInstance()
        
        setupMapView()
        
        
        collectionView.dataSource = self
        collectionView.delegate = self
        self.view.isUserInteractionEnabled = true
        collectionView.isUserInteractionEnabled = true
        collectionView.allowsSelection = true
        
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
            uiLoadingData(loading: false)
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
    
    // trying a million ways to try and get this working
    // final solution - got it working using a weird statement which gets the correct number of records
    // https://fangpenlin.com/posts/2016/04/29/uicollectionview-invalid-number-of-items-crash-issue/
    // https://stackoverflow.com/questions/19199985/invalid-update-invalid-number-of-items-on-uicollectionview/19202953#19202953
    @IBAction func removeAllPhotos() {
        removeAllPhotosWithLoop()
//        removeAllPhotosWithBatchDeleteRequestUsingObjectID()
//        removeAllPhotosWIthBatchDeleteRequestQuery()
//        removeAllPhotosThroughModel()
        
    }
    
    func removeAllPhotosWithBatchDeleteRequestUsingObjectID() {
        
        if let photos = fetchedResultsController.fetchedObjects {
            var objectIds:[NSManagedObjectID] = []
            
            for photo in photos {
//                print(photo.objectID)
                objectIds.append(photo.objectID)
//                self.collectionView.clear
//                self.dataController.viewContext.performAndWait {
//                    self.removePhoto(photo: photo)
//                }
            }
            
            let delAllReqVar = NSBatchDeleteRequest(objectIDs: objectIds)
            
            do {
                try dataController.viewContext.execute(delAllReqVar)
            } catch {
                print(error)
            }
        }
        self.collectionView.reloadData()
        
    }
    
    func removeAllPhotosWIthBatchDeleteRequestQuery() {
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
//            let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
            let predicate = NSPredicate(format: "pin == %@", self.pin)
            fetchRequest.predicate = predicate
    
            let delAllReqVar = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try dataController.viewContext.execute(delAllReqVar)
                try dataController.viewContext.save()
            } catch {
                print(error)
    
            }
        
        }
    
    func removeAllPhotosWithFetchRequestIndividual() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", self.pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do
        {
            let results = try dataController.viewContext.fetch(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                dataController.viewContext.delete(managedObjectData)
            }
        } catch let error as NSError {
            print("Detele all data in error : \(error) \(error.userInfo)")
        }
    }
    
    func removeAllPhotosWithLoop() {
        if let photos = fetchedResultsController.fetchedObjects {
            print(photos.count)
//            var count:Int = 0
            for photo in photos {
                print(photo.url)
                self.dataController.viewContext.performAndWait {
                    self.removePhoto(photo: photo)
                }
            }
        }
        self.collectionView.reloadData()
        collectionView!.numberOfItems(inSection: 0) //<-- This code is no used, but it will let UICollectionView synchronize number of items, so it will not crash in following code.
        loadDataFromNetwork(forceRefresh: true)
    }
    
    func removeAllPhotosThroughModel() {
        self.pin.removePhotos(context: dataController.viewContext)
        self.collectionView.reloadData()
    }
    
    
    // resets photos for this location
    //    @IBAction func resetPhotos(_ sender: Any) {
    //        // I think this causes a problem as this means I'm deleting from
    //        // the values in the set while traversing it
    //        //        if let photos = pin.photos {
    //        //            for photo in photos  {
    //        //                var thisPhoto = photo as! Photo
    //        //                dataController.viewContext.delete(thisPhoto)
    //        //                do {
    //        //                    try dataController.viewContext.save()
    //        //                } catch {
    //        //                    print("Error saving")
    //        //                }
    //        //            }
    //        //        }
    //        print("resetPhotos being called")
    //        if let photos = fetchedResultsController.fetchedObjects {
    //            print(photos.count)
    //            for photo in photos {
    //                print(photo.url)
    ////                removePhoto(photo: photo)
    //                dataController.viewContext.delete(photo)
    ////                break
    ////                collectionView.reloadData()
    //            }
    //            do {
    //                try dataController.viewContext.save()
    //            } catch {
    //                print(error)
    //                print("Error - Cannot remove photo")
    //            }
    //        }
    //        print("End of the clearing issue")
    ////        collectionView.reloadData()
    ////        collectionView.reloadData()
    ////        //        setupFetchedResultsController()
    ////        loadDataFromNetwork(forceRefresh: true)
    //    }
    
    func handlePhotoResults(success: Bool?, error: Error?) {
        print("handlePhotoResults")
        if !success! {
            DispatchQueue.main.async {
                self.showAlert(message: "Unable to load data - \(error)")
            }
            return
        } else {
            // data has already been updated by API at this point
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        self.uiLoadingData(loading:false)
        
    }
    
    // MARK: - UI Manipulation
    
    func uiLoadingData(loading: Bool) {
        // lets the UI know we're loading data
        self.newCollectionButton.isEnabled = !loading
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
        
        DispatchQueue.main.async {
            switch type {
            case .insert:
                print("Insert item into collectionView")
                self.collectionView.insertItems(at: [newIndexPath!])
                break
            case .delete:
                print("Delete item from collectionView")
                break
//            case .update:
//                print("Update case with \(indexPath)")
//                self.collectionView.deleteItems(at: [indexPath!])
//                break
//            case .move:
//                print("Update move with \(indexPath)")
//                break
            default: ()
            }
            
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
        
        if (numberOfItems == 0) {
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
