// Created by Roman Voinitchi on 10/6/20
// Copyright © 2020 Roman Voinitchi. All rights reserved.


import Foundation
import CoreData

protocol StructDataModelProtocol {
    
    var name: String { get }
    var exam: Int { get }
    var total: Int { get }
   
    init(firebaseDic: [String : Any], uid: String)
    init(coreDataObject: NSManagedObject)
    
    func saveToCoreData()
}

final class StructDataModel: StructDataModelProtocol {
    
    static let StructDataEntityKey = "StructData"
    static let StructUidKey = "name"
    
    var name: String
    var exam: Int
    var total: Int
    
    init(firebaseDic: [String : Any], uid: String) {
        self.name = uid
        exam = firebaseDic["exam"] as! Int
        total = firebaseDic["total"] as! Int
        
//        print("Struct firebase init \(name) \(exam) \(total)")
    }
    
    init(coreDataObject: NSManagedObject) {
        name = coreDataObject.value(forKey: "name") as! String
        exam = coreDataObject.value(forKey: "exam") as! Int
        total = coreDataObject.value(forKey: "total") as! Int
        
//        print("Coredata firebase init \(name) \(exam) \(total)")
    }
    
    func saveToCoreData() {
        let entity = NSEntityDescription.entity(forEntityName: StructDataModel.StructDataEntityKey, in: CoreDataManager.shared.context)
        let newUserObject = NSManagedObject(entity: entity!, insertInto: CoreDataManager.shared.context)
        
        newUserObject.setValue(name, forKey: "name")
        newUserObject.setValue(exam, forKey: "exam")
        newUserObject.setValue(total, forKey: "total")
        
        CoreDataManager.shared.saveContext()
    }

}
