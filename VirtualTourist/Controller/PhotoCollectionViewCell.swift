//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Moe El Tanahy on 26/04/2020.
//  Copyright © 2020 Bright Creations. All rights reserved.
//

import Foundation
import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Standard LIfe Cycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    
    
}
