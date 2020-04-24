//
//  ErrorResponse.swift
//  VirtualTourist
//
//  Created by Moe El Tanahy on 24/04/2020.
//  Copyright © 2020 Bright Creations. All rights reserved.
//

import Foundation

struct ErrorResponse: Codable {
    
    let stat: String
    let code: Int
    let message: String
    
}

extension ErrorResponse: LocalizedError {

    var errorDescription: String? {
        return message
    }
    
}

