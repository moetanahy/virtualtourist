//
//  Pin+Extensions.swift
//  VirtualTourist
//
//  Created by Moe El Tanahy on 24/04/2020.
//  Copyright © 2020 Bright Creations. All rights reserved.
//

import Foundation
import CoreData
import MapKit

// Extending the MKAnnotation Protocol to save the Pins as MKAnnotations directly
// TODO: Missing setting the coordinate value properly - needs something here
extension Pin: MKAnnotation {
        
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
    
    public var coordinate: CLLocationCoordinate2D {
        let lat = CLLocationDegrees(self.lat)
        let lon = CLLocationDegrees(self.lon)
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        return coordinate
    }
    
}
