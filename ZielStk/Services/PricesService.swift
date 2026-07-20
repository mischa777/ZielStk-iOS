//Created on 9/28/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.


import Foundation
import CoreData
import FirebaseFirestore

protocol PricesServiceProtocol {
    var prices: PriceModelProtocol? { get }
    var discounts: PriceModelProtocol? { get }
    
    func loadPricesFromCoreData(needFirebaseLoad: Bool)
}

final class PricesService: PricesServiceProtocol {
    
    private let ShopAppVersionKey = "shop_app_versio"
    private let ShopConfigVersionKey = "shop_config_version"
    
    var prices: PriceModelProtocol?
    var discounts: PriceModelProtocol?
    
    func loadPricesFromCoreData(needFirebaseLoad: Bool) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: PriceModel.PriceEntityKey)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try CoreDataManager.shared.context.fetch(request)
            let objects = result as! [NSManagedObject]
            if objects.count > 0 {
                parseCoreDataPrices(objects: objects)
            } else {
                if needFirebaseLoad {
                    loadFirebasePrices()
                }
            }
        } catch {
            if needFirebaseLoad {
                loadFirebasePrices()
            }
        }
    }
    
    private func parseCoreDataPrices(objects: [NSManagedObject]) {
        DispatchQueue.global(qos: .background).async {
            for data in objects {
                let onePriceModel = PriceModel(coreDataObject: data)
                if onePriceModel.is_discounts {
                    self.discounts = onePriceModel
                } else {
                    self.prices = onePriceModel
                }
            }
            DispatchQueue.main.async {
                self.checkPriceUpdates()
            }
        }
    }
    
    private func checkPriceUpdates() {
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
            if !self.pricesIsActual(firebaseDic: docSnapshot.data() as! [String : NSNumber]) {
                DispatchQueue.main.async {
                    self.loadFirebasePrices()
                }
            }
        }
    }
    
    private func pricesIsActual(firebaseDic: [String : NSNumber]) -> Bool {
        let currentAppVersion = UserDefaults.standard.value(forKey: ShopAppVersionKey) as? Int
        let currentConfigVersion = UserDefaults.standard.value(forKey: ShopConfigVersionKey) as? Int
        
        let serverAppVersion = Int(truncating: firebaseDic["app_version"] ?? 0)
        let serverConfigVersion = Int(truncating: firebaseDic["config_version"] ?? 0)
        
        if currentAppVersion == nil || currentConfigVersion == nil {
            UserDefaults.standard.set(serverAppVersion, forKey: ShopAppVersionKey)
            UserDefaults.standard.set(serverConfigVersion, forKey: ShopConfigVersionKey)
            return false
        } else {
            if currentAppVersion! < serverAppVersion || currentConfigVersion! < serverConfigVersion {
                UserDefaults.standard.set(serverAppVersion, forKey: ShopAppVersionKey)
                UserDefaults.standard.set(serverConfigVersion, forKey: ShopConfigVersionKey)
                return false
            } else {
                return true
            }
        }
    }
    
    //MARK: - Firebase module
    private func loadFirebasePrices() {
        let db = Firestore.firestore()
        let pricesRef = db.collection(Constants.FirebaseTables.Prices)
        pricesRef.getDocuments(completion: { [weak self] (querySnapshot, error) in
            if error == nil {
                if !(querySnapshot!.isEmpty) {
                    self?.parseFirebasePrices(snapshot: querySnapshot!.documents)
                }
            }
        })
    }
    
    private func parseFirebasePrices(snapshot: [QueryDocumentSnapshot]) {
        DispatchQueue.global(qos: .background).async {
            for document in snapshot {
                let onPriceObject: PriceModelProtocol = PriceModel(
                    firebaseDic: document.data() as! [String : NSNumber],
                    type: document.documentID)
                onPriceObject.saveToCoreData()
            }
            DispatchQueue.main.async {
                self.loadPricesFromCoreData(needFirebaseLoad: false)
            }
        }
    }
    
    //MARK: - Temp clear coredata method
    //    private func clearCoreData() {
    //        UserDefaults.standard.set(0, forKey: ShopAppVersionKey)
    //        UserDefaults.standard.set(0, forKey: ShopConfigVersionKey)
    //
    //        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: PriceModel.PriceEntityKey)
    //        fetchRequest.includesPropertyValues = false
    //
    //        do {
    //            let prices = try CoreDataManager.shared.context.fetch(fetchRequest) as! [NSManagedObject]
    //
    //            for price in prices {
    //                CoreDataManager.shared.context.delete(price)
    //            }
    //            try CoreDataManager.shared.saveContext()
    //            print("REMOVED")
    //
    //        } catch {
    //            print("Error while removing")
    //        }
    //    }
}
