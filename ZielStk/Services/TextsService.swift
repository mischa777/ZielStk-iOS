// Created by Roman Voinitchi on 10/21/20
// Copyright © 2020 Roman Voinitchi. All rights reserved.


import Foundation
import CoreData
import FirebaseFirestore
import FirebaseAuth

protocol TextsServiceProtocol {
    var onError: (() -> ())? { get set }
    var onTextsLoaded: (() -> ())? { get set }
    var allTexts: [TextDataModel] { get }
    
    func loadTextsFromCoreData()
}

final class TextsService: TextsServiceProtocol {
    
    var onError: (() -> ())?
    var onTextsLoaded: (() -> ())?
    var allTexts: [TextDataModel] {
        get {
            return self.texts
        }
    }
    
    private let TextsAppVersionKey = "texts_app_version"
    private let TextsConfigVersionKey = "texts_config_version"
    private var texts = [TextDataModel]()
    
    func loadTextsFromCoreData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: TextDataModel.TextsDataEntityKey)
        request.returnsObjectsAsFaults = false

        do {
            let result = try CoreDataManager.shared.context.fetch(request)
            let objects = result as! [NSManagedObject]
            if objects.count > 0 {
                parseCoreDataTexts(objects: objects)
            } else {
                loadTextsFromFirebase(mustThrowError: true)
            }
        } catch {
            loadTextsFromFirebase(mustThrowError: true)
        }
    }
    
    private func parseCoreDataTexts(objects: [NSManagedObject]) {
        texts.removeAll()
        for data in objects {
            texts.append(TextDataModel(coreDataObject: data))
        }
        if texts.count > 0 {
            onTextsLoaded?()
            checkTextsUpdates()
        } else {
            loadTextsFromFirebase(mustThrowError: true)
        }
    }
    
    private func checkTextsUpdates() {
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
            if !self.textsIsActual(firebaseDic: docSnapshot.data() as! [String : NSNumber]) {
                DispatchQueue.main.async {
                    self.loadTextsFromFirebase(mustThrowError: false)
                }
            }
        }
    }
    
    private func textsIsActual(firebaseDic: [String : NSNumber]) -> Bool {
        let currentAppVersion = UserDefaults.standard.value(forKey: TextsAppVersionKey) as? Int
        let currentConfigVersion = UserDefaults.standard.value(forKey: TextsConfigVersionKey) as? Int

        let serverAppVersion = Int(truncating: firebaseDic["app_version"] ?? 0)
        let serverConfigVersion = Int(truncating: firebaseDic["config_version"] ?? 0)

        if currentAppVersion == nil || currentConfigVersion == nil {
            UserDefaults.standard.set(serverAppVersion, forKey: TextsAppVersionKey)
            UserDefaults.standard.set(serverConfigVersion, forKey: TextsConfigVersionKey)
            return false
        } else {
            if currentAppVersion! < serverAppVersion || currentConfigVersion! < serverConfigVersion {
                UserDefaults.standard.set(serverAppVersion, forKey: TextsAppVersionKey)
                UserDefaults.standard.set(serverConfigVersion, forKey: TextsConfigVersionKey)
                return false
            } else {
                return true
            }
        }
    }
    
    private func loadTextsFromFirebase(mustThrowError: Bool) {
        let db = Firestore.firestore()
        let textsRef = db.collection(Constants.FirebaseTables.Deutch).document(Constants.FirebaseTables.CTest)
        textsRef.getDocument { [weak self] snapshot, error in
            if error == nil && snapshot != nil {
                self?.parseFirebaseTexts(snapshot: snapshot!, mustThrowError: mustThrowError)
            } else if error != nil && mustThrowError {
                print(error!)
                self?.onError?()
            }
        }
    }
    
    private func parseFirebaseTexts(snapshot: DocumentSnapshot, mustThrowError: Bool) {
        DispatchQueue.global(qos: .background).async {
            self.texts.removeAll()
            guard let textsDic = snapshot.data(), let loadedTexts = textsDic["Tasks"] as? [[String : String]] else {
                if mustThrowError {
                    DispatchQueue.main.async {
                        self.onError?()
                    }
                }
                return
            }
            
            for text in loadedTexts {
                let textsModel = TextDataModel(firebaseDic: text)
                textsModel.saveToCoreData()
                self.texts.append(textsModel)
            }
            
            DispatchQueue.main.async {
                self.onTextsLoaded?()
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
