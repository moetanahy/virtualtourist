//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Moe El Tanahy on 24/04/2020.
//  Copyright © 2020 Bright Creations. All rights reserved.
//

import Foundation

// MARK: - FlickrClient

// Flickr Client
// Using Documentation = https://www.flickr.com/services/api/
class FlickrClient: Client {

    // MARK: - Endpoints and URLs
    
    static let apiKey = "0f3eb8495ce8927e7269312105ccba09"
    static let apiSecret = "05788caf73c72d7c"
    
    enum Endpoints {
        static let base = "https://www.flickr.com/services/rest/"
        static let apiKeyParam = "&api_key=\(FlickrClient.apiKey)"
        
        case getPhotoInfo(String)
        case searchPhotos(Double, Double)
        
        var stringValue: String {
            switch self {
            case .getPhotoInfo(let photoId):
                // get a single photo details
                // Docs - https://www.flickr.com/services/api/flickr.photos.getInfo.html
                // API Explorer - https://www.flickr.com/services/api/explore/flickr.photos.getInfo
                // URL Example - https://www.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=0f3eb8495ce8927e7269312105ccba09&photo_id=49810994811&format=json&nojsoncallback=1
                let toReturn = Endpoints.base + "?method=flickr.photos.getInfo" + Endpoints.apiKeyParam + "&photo_id=\(photoId)" + "&format=json&nojsoncallback=1"
                print("Calling for photo")
                print(toReturn)
                return toReturn
            case .searchPhotos(let lat, let lon):
                // search for photos given a specific lat and long
                // Docs - https://www.flickr.com/services/api/flickr.photos.search.htm
                // API Explorer - https://www.flickr.com/services/api/explore/flickr.photos.search
                // example url                 https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=0f3eb8495ce8927e7269312105ccba09&lat=30.0517014&lon=31.1966411&format=json&nojsoncallback=1&per_page=10
                return Endpoints.base + "?method=flickr.photos.search" + Endpoints.apiKeyParam + "&lat=\(lat)&lon=\(lon)&format=json&nojsoncallback=1"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
        
    }
    
    // MARK: - API Calls & Requests
    
    // search photos on Flickr for a given PIN Latitude and Longitude
    class func searchAndSavePhotos(pin: Pin, completion: @escaping (Bool?, Error?) -> Void) {
        
        taskForGETRequest(url: Endpoints.searchPhotos(pin.lat, pin.lon).url, responseType: SearchPhotoResponse.self) { (response, error) in
            // do something here
            if let response = response {
                var hasAtLeastOneImage = false
                print("searchPhotos - retrieved valid response")
                let dataController = DataController.getInstance()
                // for each photo, create a new field and save to pin
                print("Number of photos found in API - \(response.photos.photo.count)")
                for photoDTO in response.photos.photo {
                    // convert from PhotoItemResponse to Photo (DataStore)
                    // TODO: Find a way to make this the same object (no DTO and Object separate)
                    let photo = Photo(context: dataController.viewContext)
                    photo.id = photoDTO.id
                    photo.creationDate = Date()
                    photo.url = photoDTO.generatedFileUrl
                    photo.pin = pin
                    hasAtLeastOneImage = true
                }
                try? dataController.viewContext.save()
                // save them all in one go
                
                // search photos retrieved - keep in mind Photo information is not full
                completion(hasAtLeastOneImage, nil)
            } else {
                print("searchPhotos - response errored out")
                print(error)
                // we need to figure out how we want to handle this
                completion(false, error)
            }
        }
    }
    
    // gets a single photo
    // TODO: Not complete, discovered this was not required - can use another method to download photos
    class func getPhotoInfo(photoId: String, completion: @escaping (PhotoDetailsResponse?, Error?) -> Void) {
        print("getPhotoInfo called")
        taskForGETRequest(url: Endpoints.getPhotoInfo(photoId).url, responseType: PhotoDetailsResponse.self) { (response, error) in
            print("getPhotoInfo: returned from get request")
            if let response = response {
                print("getPhotoInfo - has response")
                completion(response, nil)
            } else {
                print("getPhotoInfo - has no response")
                print(error)
                completion(nil, error)
            }
        }       
    }
    
    class func getFileData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    
}
