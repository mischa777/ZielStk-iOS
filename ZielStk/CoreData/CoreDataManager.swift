//Created on 9/25/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import Foundation
import CoreData

protocol CoreDataManagerProtocol {
    static var shared: CoreDataManagerProtocol { get }
    var context: NSManagedObjectContext { get }
    
    func saveContext()
}

final class CoreDataManager: CoreDataManagerProtocol {
    
    static var shared: CoreDataManagerProtocol = CoreDataManager()
    
    var context: NSManagedObjectContext {
        get {
            let context = persistentContainer.viewContext
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            return context
        }
    }
    
    // MARK: - Core Data appdelegate stack

    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ZielStkData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Container coredata error \(error) \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
//                print("Coredata saved")
            } catch {
                let nserror = error as NSError
                print("Error while saving coredata \(nserror) \(nserror.userInfo)")
            }
        }
    }
}
