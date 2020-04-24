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
    
    var pin: Pin?
    
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - LifeCycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        organiseMap
        
    }

}
