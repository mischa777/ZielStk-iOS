//Created on 10/7/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import Foundation
import CoreData
import FirebaseAuth

protocol UserStksServiceProtocol {
    var onStksLoaded: (() -> ())? { get set }
    var userStks: [StkModelProtocol] { get }
    
    func loadUserSelections()
}

final class UserStksService: UserStksServiceProtocol {
    
    var onStksLoaded: (() -> ())?
    var userStks: [StkModelProtocol] {
        get {
            return allUserStks
        }
    }
    
    private var allUserStks = [StkModelProtocol]()
    private var userSelections: UserSelectionModel?
    private var stkService: StkService
    
    init() {
        stkService = StkService()
    }
    
    func loadUserSelections() {
        if let userUid = Auth.auth().currentUser?.uid {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: UserSelectionModel.UserSelectionEntityKey)
            request.predicate = NSPredicate(format: "\(UserSelectionModel.UserUidKey) == %@", userUid)
            request.returnsObjectsAsFaults = false
            
            do {
                let result = try CoreDataManager.shared.context.fetch(request)
                let objects = result as! [NSManagedObject]
                if objects.count > 0 {
                    if let coreDataSelections = UserSelectionModel(coreDataObject: objects.first!, uid: userUid) {
                        userSelections = coreDataSelections
                        loadAllStks()
                    } else {
                        onStksLoaded?()
                    }
                } else {
                    onStksLoaded?()
                }
            } catch {
                onStksLoaded?()
            }
        } else {
            onStksLoaded?()
        }
    }
    
    private func loadAllStks() {
        stkService.onError = { [weak self] in
            self?.onStksLoaded?()
        }
        stkService.onStksLoaded = { [weak self] in
            self?.filterStks()
        }
        stkService.loadStksFromCoreData()
    }
    
    private func filterStks() {
        allUserStks.removeAll()
        var stkNames = userSelections!.getStksNames()
        stkNames.sort { $0 < $1 }
        for oneName in stkNames {
            for oneStk in stkService.allStks {
                if oneName == oneStk.stk_name {
                    allUserStks.append(oneStk)
                    break
                }
            }
        }
        onStksLoaded?()
    }
    
//    private func clearCoreData() {
//        print("Try clear")
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: UserSelectionModel.UserSelectionEntityKey)
//        fetchRequest.includesPropertyValues = false
//
//        do {
//            let stks = try CoreDataManager.shared.context.fetch(fetchRequest) as! [NSManagedObject]
//
//            for stk in stks {
//                CoreDataManager.shared.context.delete(stk)
//            }
//            CoreDataManager.shared.saveContext()
//            print("REMOVED")
//
//        } catch {
//            print("Error while removing")
//        }
//    }
    
}
