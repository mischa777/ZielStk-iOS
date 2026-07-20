//Created on 9/28/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import Foundation
import CoreData

protocol UserDataModelProtocol {
    
    var uid: String { get }
    var payment_token: String { get }
    var is_verified: Bool { get }
    
    init(firebaseDic: [String : Any], uid: String)
    init(coreDataObject: NSManagedObject)
    
    func saveToCoreData()
}

final class UserDataModel: UserDataModelProtocol {
    
    static let UserDataEntityKey = "UserData"
    static let UserUidKey = "uid"
    
    var uid: String
    var payment_token: String
    var is_verified: Bool
    
    init(firebaseDic: [String : Any], uid: String) {
        self.uid = uid
        payment_token = firebaseDic["PaymentToken"] as! String
        is_verified = firebaseDic["IsVerified"] as! Bool
    }
    
    init(coreDataObject: NSManagedObject) {
        uid = coreDataObject.value(forKey: "uid") as! String
        payment_token = coreDataObject.value(forKey: "payment_token") as! String
        is_verified = coreDataObject.value(forKey: "is_verified") as! Bool
        
        print("COREDATA \(uid) \(payment_token) \(is_verified)")
    }
    
    func saveToCoreData() {
        let entity = NSEntityDescription.entity(forEntityName: UserDataModel.UserDataEntityKey, in: CoreDataManager.shared.context)
        let newUserObject = NSManagedObject(entity: entity!, insertInto: CoreDataManager.shared.context)
        
        newUserObject.setValue(uid, forKey: "uid")
        newUserObject.setValue(payment_token, forKey: "payment_token")
        newUserObject.setValue(is_verified, forKey: "is_verified")
        
        CoreDataManager.shared.saveContext()
    }

}
