//
//  PhotoDetailsResponseTestCase.swift
//  VirtualTourist
//
//  Created by Moe El Tanahy on 26/04/2020.
//  Copyright © 2020 Bright Creations. All rights reserved.
//

import XCTest
@testable import VirtualTourist

// https://paul-samuels.com/blog/2019/01/07/swift-codable-testing/
class PhotoDetailsResponseTestCase: XCTestCase {

//    override func setUp() {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
    
    private let getPhotoDetailsJSONResponse = Data("""
        {
            "photo": {
                "id": "49819538982",
                "secret": "0ff394dc0e",
                "server": "65535",
                "farm": 66,
                "dateuploaded": "1587856500",
                "isfavorite": 0,
                "license": "0",
                "safety_level": "0",
                "rotation": 0,
                "originalsecret": "7b3c101fc4",
                "originalformat": "jpg",
                "owner": {
                    "nsid": "162016075@N05",
                    "username": "jonnydontstopliving",
                    "realname": "Jonny Blair",
                    "location": "Warszawa, Poland",
                    "iconserver": "4702",
                    "iconfarm": 5,
                    "path_alias": "jonnydontstopliving"
                },
                "title": {
                    "_content": "IMG_20191222_124708"
                },
                "description": {
                    "_content": "btr"
                },
                "visibility": {
                    "ispublic": 1,
                    "isfriend": 0,
                    "isfamily": 0
                },
                "dates": {
                    "posted": "1587856500",
                    "taken": "2019-12-22 12:47:09",
                    "takengranularity": "0",
                    "takenunknown": "0",
                    "lastupdate": "1587856522"
                },
                "views": "0",
                "editability": {
                    "cancomment": 0,
                    "canaddmeta": 0
                },
                "publiceditability": {
                    "cancomment": 1,
                    "canaddmeta": 0
                },
                "usage": {
                    "candownload": 1,
                    "canblog": 0,
                    "canprint": false,
                    "canshare": 1
                },
                "comments": {
                    "_content": "0"
                },
                "notes": {
                    "note": []
                },
                "people": {
                    "haspeople": 0
                },
                "tags": {
                    "tag": []
                },
                "location": {
                    "latitude": "30.034519",
                    "longitude": "31.219986",
                    "accuracy": "16",
                    "context": "0",
                    "locality": {
                        "_content": "Ad Duqqī"
                    },
                    "neighbourhood": {
                        "_content": ""
                    },
                    "region": {
                        "_content": "Giza"
                    },
                    "country": {
                        "_content": "Egypt"
                    }
                },
                "geoperms": {
                    "ispublic": 1,
                    "iscontact": 0,
                    "isfriend": 0,
                    "isfamily": 0
                },
                "urls": {
                    "url": [
                        {
                            "type": "photopage",
                            "_content": "https://www.flickr.com/photos/jonnydontstopliving/49819538982/"
                        }
                    ]
                },
                "media": "photo"
            },
            "stat": "ok"
        }
        """.utf8)
    

    private let decodedPhoto = PhotoDetailsResponse(
                id: "49819538982",
                latitude: "30.034519",
                longitude: "31.219986",
                url: URL(string: "https://www.flickr.com/photos/jonnydontstopliving/49819538982/")!
    )
    
    func testDecodePhotoDetailsResponseSuccess() {
        
        XCTAssertEqual(decodedPhoto, try JSONDecoder().decode(PhotoDetailsResponse.self, from: getPhotoDetailsJSONResponse))
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
