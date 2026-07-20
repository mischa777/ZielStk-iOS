//Created on 10/13/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import Foundation
import CoreData

protocol TargetModelProtocol {
    var stk_data: String { get }
    var test_data: String { get }
    var target_index: Int32 { get }
    
    init (stkData: String, testData: String, targetIndex: Int32, userId: String)
    init(coreDataObject: NSManagedObject)
    
    func saveTarget()
    func updateTarget(newTargetIndex: Int32)
}

final class TargetModel: TargetModelProtocol {
    
    static let TargetsEntityKey = "Targets"
    static let TestDataKey = "test_data"
    static let UserUidKey = "uid"
    
    var stk_data: String
    var test_data: String
    var target_index: Int32
    var uid: String
    
    init (stkData: String, testData: String, targetIndex: Int32, userId: String) {
        stk_data = stkData
        test_data = testData
        target_index = targetIndex
        uid = userId
    }
    
    init(coreDataObject: NSManagedObject) {
        stk_data = coreDataObject.value(forKey: "stk_data") as! String
        test_data = coreDataObject.value(forKey: "test_data") as! String
        uid = coreDataObject.value(forKey: "uid") as! String
        target_index = coreDataObject.value(forKey: "target_index") as! Int32
    }
    
    func saveTarget() {
        let entity = NSEntityDescription.entity(forEntityName: TargetModel.TargetsEntityKey, in: CoreDataManager.shared.context)
        let newUserObject = NSManagedObject(entity: entity!, insertInto: CoreDataManager.shared.context)
        
        newUserObject.setValue(uid, forKey: "uid")
        newUserObject.setValue(test_data, forKey: "test_data")
        newUserObject.setValue(target_index, forKey: "target_index")
        newUserObject.setValue(stk_data, forKey: "stk_data")
        
        CoreDataManager.shared.saveContext()
    }
    
    func updateTarget(newTargetIndex: Int32) {
        target_index = newTargetIndex
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: TargetModel.TargetsEntityKey)
        let subPredicate1 = NSPredicate(format: "(\(TargetModel.UserUidKey) = %@)", uid)
        let subPredicate2 = NSPredicate(format: "(\(TargetModel.TestDataKey) = %@)", test_data)
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [subPredicate1, subPredicate2])
        request.predicate = compoundPredicate
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try CoreDataManager.shared.context.fetch(request)
            let objects = result as! [NSManagedObject]
            if objects.count > 0 {
                objects.first!.setValue(target_index, forKey: "target_index")
            } else {
                print("Target not found")
            }
        } catch {
            print("Error while saving")
        }
        CoreDataManager.shared.saveContext()
    }
}
