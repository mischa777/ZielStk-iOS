// Created by Roman Voinitchi on 10/6/20
// Copyright © 2020 Roman Voinitchi. All rights reserved.


import Foundation
import CoreData
import FirebaseFirestore

protocol StructServiceProtocol {
    var onError: (() -> ())? { get set }
    var onStructLoaded: (() -> ())? { get set }
    var allStructs: [StructDataModelProtocol] { get }
    
    func loadStructFromCoreData()
    func getThemeChalangesCount(nameOfChalange: String) -> (total: Int, exams: Int)?
}

final class StructService: StructServiceProtocol {
    
    var onError: (() -> ())?
    var onStructLoaded: (() -> ())?
    var allStructs: [StructDataModelProtocol] {
        get {
            return self.structs
        }
    }
    
    private let StructAppVersionKey = "struct_app_version"
    private let StructConfigVersionKey = "struct_config_version"
    private var structs = [StructDataModelProtocol]()
    
    func loadStructFromCoreData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: StructDataModel.StructDataEntityKey)
        request.returnsObjectsAsFaults = false

        do {
            let result = try CoreDataManager.shared.context.fetch(request)
            let objects = result as! [NSManagedObject]
            if objects.count > 0 {
                parseCoreDataStructs(objects: objects)
            } else {
                loadStructsFromFirebase(mustThrowError: true)
            }
        } catch {
            loadStructsFromFirebase(mustThrowError: true)
        }
    }
    
    private func parseCoreDataStructs(objects: [NSManagedObject]) {
        structs.removeAll()
        for data in objects {
            structs.append(StructDataModel(coreDataObject: data))
        }
        if structs.count > 0 {
            onStructLoaded?()
            checkStructUpdates()
        } else {
            loadStructsFromFirebase(mustThrowError: true)
        }
    }
    
    private func checkStructUpdates() {
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
            if !self.structIsActual(firebaseDic: docSnapshot.data() as! [String : NSNumber]) {
                DispatchQueue.main.async {
                    self.loadStructsFromFirebase(mustThrowError: false)
                }
            }
        }
    }
    
    private func structIsActual(firebaseDic: [String : NSNumber]) -> Bool {
        let currentAppVersion = UserDefaults.standard.value(forKey: StructAppVersionKey) as? Int
        let currentConfigVersion = UserDefaults.standard.value(forKey: StructConfigVersionKey) as? Int

        let serverAppVersion = Int(truncating: firebaseDic["app_version"] ?? 0)
        let serverConfigVersion = Int(truncating: firebaseDic["config_version"] ?? 0)

        if currentAppVersion == nil || currentConfigVersion == nil {
            UserDefaults.standard.set(serverAppVersion, forKey: StructAppVersionKey)
            UserDefaults.standard.set(serverConfigVersion, forKey: StructConfigVersionKey)
            return false
        } else {
            if currentAppVersion! < serverAppVersion || currentConfigVersion! < serverConfigVersion {
                UserDefaults.standard.set(serverAppVersion, forKey: StructAppVersionKey)
                UserDefaults.standard.set(serverConfigVersion, forKey: StructConfigVersionKey)
                return false
            } else {
                return true
            }
        }
    }
    
    private func loadStructsFromFirebase(mustThrowError: Bool) {
        let db = Firestore.firestore()
        let structsRef = db.collection(Constants.FirebaseTables.Struct)
        structsRef.getDocuments(completion: { [weak self] (querySnapshot, error) in
            if error == nil {
                if !(querySnapshot!.isEmpty) {
                    self?.parseFirebaseStructs(snapshot: querySnapshot!.documents)
                }
            } else if error != nil && mustThrowError {
                self?.onError?()
            }
        })
    }
    
    private func parseFirebaseStructs(snapshot: [QueryDocumentSnapshot]) {
        DispatchQueue.global(qos: .background).async {
            self.structs.removeAll()
            for oneSnap in snapshot {
                for (key, values) in oneSnap.data() {
                    if let values = values as? [String : Any] {
                        let structModel = StructDataModel(firebaseDic: values, uid: key)
                        structModel.saveToCoreData()
                        self.structs.append(structModel)
                    }
                }
            }
            DispatchQueue.main.async {
                self.onStructLoaded?()
            }
        }
    }
    
    func getThemeChalangesCount(nameOfChalange: String) -> (total: Int, exams: Int)? {
        for structProtocol in structs {
            if structProtocol.name == nameOfChalange {
                return (structProtocol.total, structProtocol.exam)
            }
        }
        return nil
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
