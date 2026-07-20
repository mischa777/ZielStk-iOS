//Created on 10/14/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import Foundation
import CoreData
import FirebaseAuth

protocol TargetsVMProtocol {
    var onTargetsLoaded: (() -> ())? { get set }
    var targets: [TargetModelProtocol] { get }
    
    func loadTargets()
    func removeTargetAt(index: Int)
}

final class TargetsVM: TargetsVMProtocol {
    
    var onTargetsLoaded: (() -> ())?
    var targets: [TargetModelProtocol] {
        get {
            return userTargets
        }
    }
    
    private var userTargets = [TargetModelProtocol]()
    
    func loadTargets() {
        userTargets.removeAll()
        if let userUid = Auth.auth().currentUser?.uid {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: TargetModel.TargetsEntityKey)
            request.predicate = NSPredicate(format: "\(TargetModel.UserUidKey) == %@", userUid)
            request.returnsObjectsAsFaults = false
            
            do {
                let result = try CoreDataManager.shared.context.fetch(request)
                let objects = result as! [NSManagedObject]
                for obj in objects {
                    userTargets.append(TargetModel(coreDataObject: obj))
                }
                onTargetsLoaded?()
            } catch {
                onTargetsLoaded?()
            }
        } else {
            onTargetsLoaded?()
        }
    }
    
    func removeTargetAt(index: Int) {
        if let userUid = Auth.auth().currentUser?.uid {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: TargetModel.TargetsEntityKey)
            let subPredicate1 = NSPredicate(format: "(\(TargetModel.UserUidKey) = %@)", userUid)
            let subPredicate2 = NSPredicate(format: "(\(TargetModel.TestDataKey) = %@)", userTargets[index].test_data)
            let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [subPredicate1, subPredicate2])
            request.predicate = compoundPredicate
            request.returnsObjectsAsFaults = false
            
            do {
                let result = try CoreDataManager.shared.context.fetch(request)
                let objects = result as! [NSManagedObject]
                if objects.count > 0 {
                    CoreDataManager.shared.context.delete(objects.first!)
                    userTargets.remove(at: index)
                } else {
                    print("Not found")
                }
                onTargetsLoaded?()
            } catch {
                onTargetsLoaded?()
            }
        } else {
            onTargetsLoaded?()
        }
    }
}
