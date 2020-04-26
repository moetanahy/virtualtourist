//
//  PhotoResponse.swift
//  VirtualTourist
//
//  Created by Moe El Tanahy on 26/04/2020.
//  Copyright © 2020 Bright Creations. All rights reserved.
//

import Foundation

// Working with Codable
// and restructing the data = https://matteomanferdini.com/codable/
struct PhotoDetailsResponse {
    
    var id: String
    var latitude: String
    var longitude: String
    var url: URL
    
    init(id: String, latitude: String, longitude: String, url: URL) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.url = url
    }
    
}

extension PhotoDetailsResponse: Decodable {
    
    enum CodingKeys: String, CodingKey {
        
        case photo
        
        enum PhotoKeys: String, CodingKey {
            
            case id = "id"
            case location
            case urls
            
            enum LocationKeys: String, CodingKey {
                case latitude = "latitude"
                case longitude = "longitude"
            }
            
            enum UrlsKeys: String, CodingKey {
                case url
            }
            
        }
        
    }
    
    struct PhotoResponseURL: Decodable {
        
        let type: String
        let urlString: String
        
        enum CodingKeys: String, CodingKey {
            case type = "type"
            case urlString = "_content"
        }
        
    }
        
    // manually overwrote the decoder for this
    init(from decoder: Decoder) throws {
        
        // the top level photo container
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // the id
        let photoContainer = try container.nestedContainer(keyedBy: CodingKeys.PhotoKeys.self, forKey: .photo)
        id = try photoContainer.decode(String.self, forKey: .id)
        
        // get the lat and long
        let locationContainer = try photoContainer.nestedContainer(keyedBy: CodingKeys.PhotoKeys.LocationKeys.self, forKey: .location)
        latitude = try locationContainer.decode(String.self, forKey: .latitude)
        longitude = try locationContainer.decode(String.self, forKey: .longitude)
        
        // url info on the image
        let urlsContainer = try photoContainer.nestedContainer(keyedBy: CodingKeys.PhotoKeys.UrlsKeys.self, forKey: .urls)
        // decode the hard one which is very deep in the JSON file
        let urls = try urlsContainer.decode([PhotoResponseURL].self, forKey: .url)
        self.url = !urls.isEmpty
            ? URL(string: urls.dropFirst().reduce("\(urls[0].urlString)", { $0 + ", \($1.urlString)" }))!
            : URL(string: "")!
        
        
//        let payloads = try secondStageContainer.decode([Payload].self, forKey: .payloads)
//        self.payloads = !payloads.isEmpty
//            ? payloads.dropFirst().reduce("\(payloads[0].name)", { $0 + ", \($1.name)" })
//            : ""
        
        
        
//        let urlContainer = try urlsContainer.nestedContainer(keyedBy: CodingKeys.PhotoKeys.UrlsKeys.UrlKeys.self, forKey: .url)
        //        url = try urlContainer.decode(URL.self, forKey: .url)
        
//        url = URL(string: "www.google.com")!
        
        
    }
}

// Used for testing to check equality
// https://developer.apple.com/documentation/swift/equatable
extension PhotoDetailsResponse: Equatable {
    
    static func == (lhs: PhotoDetailsResponse, rhs: PhotoDetailsResponse) -> Bool {
        return
            lhs.id == rhs.id &&
                lhs.latitude == rhs.latitude &&
                lhs.longitude == rhs.longitude &&
                lhs.url == rhs.url
    }
    
}
