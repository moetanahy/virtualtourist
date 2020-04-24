//
//  SearchPhotosResponse.swift
//  VirtualTourist
//
//  Created by Moe El Tanahy on 24/04/2020.
//  Copyright © 2020 Bright Creations. All rights reserved.
//

import Foundation

struct SearchPhotoResponse: Codable {
    
    let stat: String
    let photos: PhotoInfoResponse
    
    struct PhotoInfoResponse: Codable {
        let page: Int
        let pages: Int
        let perpage: Int
        let total: String
        let photo: [PhotoItem]
    }
    
    struct PhotoItem: Codable {
        
        let id: String
        let owner: String
        let secret: String
        let server: String
        let farm: Int
        let title: String
        let ispublic: Int
        let isfriend: Int
        let isfamily: Int
        
    }
    
}
