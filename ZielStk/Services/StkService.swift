//Created on 9/29/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import Foundation
import CoreData
import FirebaseFirestore

protocol StkServiceProtocol {
    var onError: (() -> ())? { get set }
    var onStksLoaded: (() -> ())? { get set }
    var allStks: [StkModelProtocol] { get }
    
    func loadStksFromCoreData()
}

final class StkService: StkServiceProtocol {
    
    var onError: (() -> ())?
    var onStksLoaded: (() -> ())?
    var allStks: [StkModelProtocol] {
        get {
            return self.stks
        }
    }
    
    private let StksAppVersionKey = "stks_app_versio"
    private let StksConfigVersionKey = "stks_config_version"
    private var stks = [StkModelProtocol]()
    
    func loadStksFromCoreData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: StkModel.StksEntityKey)
        request.returnsObjectsAsFaults = false

        do {
            let result = try CoreDataManager.shared.context.fetch(request)
            let objects = result as! [NSManagedObject]
            if objects.count > 0 {
                parseCoreDataStks(objects: objects)
            } else {
                loadStksFromFirebase()
            }
        } catch {
            loadStksFromFirebase()
        }
    }
    
    private func parseCoreDataStks(objects: [NSManagedObject]) {
        stks.removeAll()
        for data in objects {
            if let oneStk = StkModel(coreDataObject: data) {
                stks.append(oneStk)
            }
        }
        if stks.count > 0 {
            onStksLoaded?()
            checkStksUpdates()
        } else {
            loadStksFromFirebase()
        }
    }
    
    private func checkStksUpdates() {
        let db = Firestore.firestore()
        let configRef = db.collection(Constants.FirebaseTables.Config).document(Constants.FirebaseTables.ConfigVersions)
        configRef.getDocument(completion: { [weak self] (docSnapshot, error) in
            if error == nil {
                self?.checkIfNeedUpdate(docSnapshot: docSnapshot!)
            }
        })
    }
    
    private func checkIfNeedUpdate(docSnapshot: DocumentSnapshot) {
        DispatchQueue.global(qos: .background).async {
            if !self.stksIsActual(firebaseDic: docSnapshot.data() as! [String : NSNumber]) {
                DispatchQueue.main.async {
                    self.loadStksFromFirebase()
                }
            }
        }
    }
    
    private func stksIsActual(firebaseDic: [String : NSNumber]) -> Bool {
        let currentAppVersion = UserDefaults.standard.value(forKey: StksAppVersionKey) as? Int
        let currentConfigVersion = UserDefaults.standard.value(forKey: StksConfigVersionKey) as? Int
        
        let serverAppVersion = Int(truncating: firebaseDic["app_version"] ?? 0)
        let serverConfigVersion = Int(truncating: firebaseDic["config_version"] ?? 0)
        
        if currentAppVersion == nil || currentConfigVersion == nil {
            UserDefaults.standard.set(serverAppVersion, forKey: StksAppVersionKey)
            UserDefaults.standard.set(serverConfigVersion, forKey: StksConfigVersionKey)
            return false
        } else {
            if currentAppVersion! < serverAppVersion || currentConfigVersion! < serverConfigVersion {
                UserDefaults.standard.set(serverAppVersion, forKey: StksAppVersionKey)
                UserDefaults.standard.set(serverConfigVersion, forKey: StksConfigVersionKey)
                return false
            } else {
                return true
            }
        }
    }
    
    private func loadStksFromFirebase() {
        let db = Firestore.firestore()
        let pricesRef = db.collection(Constants.FirebaseTables.Stk)
        pricesRef.getDocuments(completion: { [weak self] (querySnapshot, error) in
            if error == nil {
                if !(querySnapshot!.isEmpty) {
                    self?.parseFirebaseStks(snapshot: querySnapshot!.documents)
                }
            }
        })
    }
    
    private func parseFirebaseStks(snapshot: [QueryDocumentSnapshot]) {
        DispatchQueue.global(qos: .background).async {
            self.stks.removeAll()
            for oneSnap in snapshot {
                let stkModel = StkModel(firebaseDic: oneSnap.data())
                stkModel.saveToCoreData()
                self.stks.append(stkModel)
            }
            DispatchQueue.main.async {
                self.onStksLoaded?()
            }
        }
    }
    
//        private func clearCoreData() {
//            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: StkModel.StksEntityKey)
//            fetchRequest.includesPropertyValues = false
//
//            do {
//                let stks = try CoreDataManager.shared.context.fetch(fetchRequest) as! [NSManagedObject]
//
//                for stk in stks {
//                    CoreDataManager.shared.context.delete(stk)
//                }
//                try CoreDataManager.shared.saveContext()
//                print("REMOVED")
//
//            } catch {
//                print("Error while removing")
//            }
//        }
}
