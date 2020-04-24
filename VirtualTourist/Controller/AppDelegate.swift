//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Moe El Tanahy on 24/04/2020.
//  Copyright © 2020 Bright Creations. All rights reserved.
//

import UIKit
import MapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Data Controller Definition (CoreData)
    
    let dataController = DataController(modelName: "VirtualTourist")
    
    // MARK: - Run this when first time launched
    
    func checkIfFirstLaunch() {
        if UserDefaults.standard.bool(forKey: ProjectCustomKeys.hasLaunchedBefore.rawValue) {
            print("App has launched before")
        } else {
            print("This is the first launch ever!")
            UserDefaults.standard.set(true, forKey: ProjectCustomKeys.hasLaunchedBefore.rawValue)
            // Cairo Default is:
            // Latitude - 30.044420
            // Longitude - 31.235712
            let cairoLat = 30.044420
            let cairoLon = 31.235712
            let defaultMapCenter = [
                "lat": cairoLat,
                "lon": cairoLon
            ]
            UserDefaults.standard.set(defaultMapCenter, forKey: ProjectCustomKeys.mapDefaultKey.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // check if this is the first time the app launches
        // if so, load the location of Cairo, Egypt as the user defaults
        // this avoids me having to check user location and ask for privileges
//        UserDefaults.standard.set(false, forKey: "HasLaunchedBefore")
        checkIfFirstLaunch()
        
        // load the CoreData Stack Data Controller
        dataController.load()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

