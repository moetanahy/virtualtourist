//
//  UIViewController+Extensions.swift
//  VirtualTourist
//
//  Created by Moe El Tanahy on 26/04/2020.
//  Copyright © 2020 Bright Creations. All rights reserved.
//

import Foundation

import UIKit

extension UIViewController {
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.modalPresentationStyle = .overFullScreen
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
}
