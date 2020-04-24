//
//  DataController.swift
//  Mooskine
//
//  Created by Moe Tanahy
//  Copyright © 2020 Bright Creations. All rights reserved.
//  Copied from Udacity Mooskine Application
//

import Foundation
import CoreData

// MARK: - DataController
// Given class by Udacity course for managing the CoreData
// Made slight modifications to make this a singleton

class DataController {
        
    let persistentContainer:NSPersistentContainer
    
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    let backgroundContext:NSManagedObjectContext!
    
    // MARK: - Constructor (Private now) & Singleton Management
    
    // dictionary of datacontrollers (one for each Data Model "modelName")
    static var dataControllers:[String:DataController] = [:]
    
    private init(modelName:String) {
        persistentContainer = NSPersistentContainer(name: modelName)
        backgroundContext = persistentContainer.newBackgroundContext()
    }
    
    // we send back the instance if we have it, otherwise create a new one for this modelname
    static func getInstance(modelName: String) -> DataController {
                
        if dataControllers[modelName] == nil {
            dataControllers[modelName] = DataController(modelName: modelName)
        }
        return dataControllers[modelName]!
        
    }
    
    // gets the default instance
    static func getInstance() -> DataController {
        // this is the default model name
        return getInstance(modelName: "VirtualTourist")
    }
    
    // MARK: - Contexts and loading stores
    
    func configureContexts() {
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            self.configureContexts()
            completion?()
        }
    }
}

// MARK: - Autosaving

extension DataController {
    func autoSaveViewContext(interval:TimeInterval = 30) {
        print("autosaving")
        
        guard interval > 0 else {
            print("cannot set negative autosave interval")
            return
        }
        
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}
