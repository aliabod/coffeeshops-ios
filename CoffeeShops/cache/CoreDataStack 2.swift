//  CoreDataStack.swift
//  CoffeeShops
//
//  Created by Ali Abod on 30/11/2019.
//  Copyright © 2019 Ali Abod. All rights reserved.
//
//  Reference: StackOverflow

import Foundation
import CoreData

class CoreDataStack {
    
    static var shared : CoreDataStack = CoreDataStack(modelName: "")
    
    private let modelName: String
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    internal lazy var storeContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores(completionHandler: { (StoreDescription, Error) in
            if let error = Error as NSError? {
                
                print("Unresolved error \(error), \(error.userInfo))")
            }
        })
        return container
    }()
    
    lazy var managedContext: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()
    
    func saveContext(_ completation: ((_ Saved : Bool)->())? = nil) {
        
        guard managedContext.hasChanges else {
            completation?(true)
            return
        }
        
        managedContext.perform {
            do {
                try self.managedContext.save()
                completation?(true)
            } catch let error as NSError {
                
                completation?(false)
                print("Unresolved error \(error), \(error.userInfo))")
            }
        }
    }
    
    func printThePathUrl() {
        if let path = Bundle.main.url(forResource: modelName, withExtension: "momd")
        { print(path) }
    }
    
    func Reset( PersistantStores : [String]? = nil, completionHandler : (()->())? = nil) {
        
        // create the delete request for the specified entity
        let entitiesDes = PersistantStores ?? storeContainer.managedObjectModel.entities.compactMap({$0.name})
        for entityDes in  entitiesDes {
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityDes)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            // perform the delete
            do {
                try managedContext.execute(deleteRequest)
                try managedContext.save()
                completionHandler?()
            } catch let error as NSError {
                print(error)
            }
        }
    }
    
    static func saveContext(inManagedContext  managedContext : NSManagedObjectContext, completionhandler : (()->())? = nil) {
        
        guard managedContext.hasChanges else { return }
        
        managedContext.perform {
            
            do {
                
                try managedContext.save()
                completionhandler?()
            } catch let error as NSError {
                
                print("Unresolved error \(error), \(error.userInfo))")
            }
        }
    }
}
