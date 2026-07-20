//Created on 9/28/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import Foundation
import FirebaseFirestore
import FirebaseAuth
import CoreData

protocol UserPurchasesServiceProtocol {
    var onPurchasesLoaded: (() -> ())? { get set }
    var onPurchasesError: (() -> ())? { get set }
    var userDataModel: UserDataModelProtocol? { get }
    
    func loadUserData()
}

final class UserPurchasesService: UserPurchasesServiceProtocol {
    
    var onPurchasesLoaded: (() -> ())?
    var onPurchasesError: (() -> ())?
    var userDataModel: UserDataModelProtocol?
    
    func loadUserData() {
        if let userId = Auth.auth().currentUser?.uid {
            let db = Firestore.firestore()
            let userRef = db.collection(Constants.FirebaseTables.Users).document(userId)
            userRef.getDocument(completion: { [weak self] (docSnapshot, error) in
                if error == nil {
                    self?.saveModelToCoreData(docSnapshot: docSnapshot!)
                } else {
                    self?.loadFromCoreData()
                }
            })
        } else {
            loadFromCoreData()
        }
    }
    
    private func saveModelToCoreData(docSnapshot: DocumentSnapshot) {
        if let userUid = Auth.auth().currentUser?.uid {
            userDataModel = UserDataModel(firebaseDic: docSnapshot.data()!, uid: userUid)
            userDataModel!.saveToCoreData()
            onPurchasesLoaded?()
        }
    }
    
    private func loadFromCoreData() {
        if let userUid = Auth.auth().currentUser?.uid {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: UserDataModel.UserDataEntityKey)
            request.predicate = NSPredicate(format: "\(UserDataModel.UserUidKey) == %@", userUid)
            request.returnsObjectsAsFaults = false
            
            do {
                let result = try CoreDataManager.shared.context.fetch(request)
                let objects = result as! [NSManagedObject]
                if objects.count > 0 {
                    userDataModel = UserDataModel(coreDataObject: objects.first!)
                    onPurchasesLoaded?()
                } else {
                    onPurchasesError?()
                }
            } catch {
                onPurchasesError?()
            }
        } else {
            onPurchasesError?()
        }
    }
}
