//Created on 9/23/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import Foundation
import CoreData
import FirebaseFirestore
import FirebaseAuth
import FirebaseAnalytics
import FBSDKCoreKit

//MARK: - Shop view model
protocol ShopVMProtocol {
    var onPurchasesLoaded: (() -> ())? { get set }
    var onCartError: (() -> ())? { get set }
    var onCartSuccess: (() -> ())? { get set }
    var onIAPError: (() -> ())? { get set }
    var onEmptySelection: (() -> ())? { get set }
    
    var sections: [ExpandableSectionProtocol] { get }
    var uSelectionService: UserSelectionServiceProtocol { get }
    var purchases: [String] { get }
    var cartItems: [String] { get }
    var serverItems: [String] { get }
    var totalPrice: Float { get }
    
    func setSections()
    func changeSectionExpand(section: Int)
    func getSelectedString(indexPath: IndexPath) -> String
    func loadPurchases()
    func clearCart()
    func appendElementToCart(elementName: String, serverName: String, disciplineName: String)
    func removeElementFromCart(elementName: String, serverName: String, disciplineName: String)
    func saveCartToServer()
    func getPurchaseUrl() -> String
    func purchaseCartAtAppstore()
    func refreshAppStorePurchases()
    func tryFetchPurchases()
    func getAgreementUrl() -> String
    func getLocalizedCurrency() -> String
    func getFullPrice(productName: String) -> String
    func registerPurchaseEvent(placeOfPurchase: String)
    func setPurchaseObservers()
    func removePurchaseObservers()
}

final class ShopVM: ShopVMProtocol {
    private let keyPurchasedProducts = "purchasedProducts"
    
    var onCartError: (() -> ())?
    var onCartSuccess: (() -> ())?
    var onPurchasesLoaded: (() -> ())?
    var onIAPError: (() -> ())?
    var onEmptySelection: (() -> ())?
    
    var sections: [ExpandableSectionProtocol] {
        get {
            return allSections
        }
    }
    var uSelectionService: UserSelectionServiceProtocol {
        get {
            return usersSelectionService
        }
    }
    
    private var allSections = [ExpandableSectionProtocol] ()
    private var pricesService: PricesServiceProtocol
    private var usersSelectionService: UserSelectionServiceProtocol
//    private var iapService: IAPServiceProtocol
    
    var purchases: [String] = [String]()
    var cartItems: [String] = [String]()
    var serverItems: [String] = [String]()
    var totalPrice: Float = 0.0
    
    init() {
        pricesService = PricesService()
        pricesService.loadPricesFromCoreData(needFirebaseLoad: true)
        usersSelectionService = UserSelectionService()
        usersSelectionService.loadUserSelection()
        
//        iapService = IAPService()
//        iapService.onIAPError = { [weak self] in
//            self?.onIAPError?()
//        }
//        iapService.onPurchaseCompleted = { [weak self] (productID) in
//            self?.restorePurchasedFirebaseTable(tableName: IAPRouter.purchaseId(id: productID).firebaseTableName)
//            self?.onPurchasesLoaded?()
//        }
    }
    
    func setPurchaseObservers() {
        IAP.shared.onIAPError = { [weak self] in
            self?.onIAPError?()
        }
        IAP.shared.onPurchaseCompleted = { [weak self] productID in
            self?.restorePurchasedFirebaseTable(tableName: IAPRouter.purchaseId(id: productID).firebaseTableName)
            self?.onPurchasesLoaded?()
        }
    }
    
    func removePurchaseObservers() {
        IAP.shared.onIAPError = nil
        IAP.shared.onPurchaseCompleted = nil
    }
    
    func setSections() {
        allSections.removeAll()
        usersSelectionService.loadUserSelection()
        let selections = usersSelectionService.getAllSelectedCourses()
        let sortedKeys = selections.keys.sorted { $0 < $1 }
        for key in sortedKeys {
            allSections.append(ExpandableSection(titleObject: key, sectionsObjects: selections[key]!))
        }
        if selections.count == 0 {
            onEmptySelection?()
        }
    }
    
    func changeSectionExpand(section: Int) {
        allSections[section].isExpanded = !allSections[section].isExpanded
    }
    
    func getSelectedString(indexPath: IndexPath) -> String {
        let section = allSections[indexPath.section]
        return "\(section.titleObject)\(Constants.Values.StringSeparator)\(section.sectionsObjects[indexPath.row])"
    }
    
    func getPurchaseUrl() -> String {
        if let currentLang = Locale.current.languageCode {
            if currentLang == "ru" {
                return "https://zielstudienkolleg-pay-ru.web.app/"
            }
        }
        return "https://zielstudienkolleg-pay.web.app/"
    }
    
    func getAgreementUrl() -> String {
//        if let currentLang = Locale.current.languageCode {
//            if currentLang == "ru" {
//                return "https://firebasestorage.googleapis.com/v0/b/ziel-studienkolleg.appspot.com/o/Documents%2FNutzungvertrag.pdf?alt=media&token=2e3cf866-3fe8-4d7a-9512-872939a09248"
//            }
//        }
        return "https://firebasestorage.googleapis.com/v0/b/ziel-studienkolleg.appspot.com/o/Documents%2FNutzungvertrag.pdf?alt=media&token=2e3cf866-3fe8-4d7a-9512-872939a09248"
    }
    
    //MARK: - Firebase
    func loadPurchases() {
        if let userId = Auth.auth().currentUser?.uid {
            let db = Firestore.firestore()
            let userPurchasesRef = db.collection(Constants.FirebaseTables.Users).document(userId).collection(Constants.FirebaseTables.Purchases)
            userPurchasesRef.getDocuments(completion: { [weak self] (querySnapshot, error) in
                if error != nil {
                    self?.onPurchasesLoaded?()
                } else {
                    if let documents = querySnapshot?.documents{
                        self?.parseUserData(userDocuments: documents)
                    }
                    self?.onPurchasesLoaded?()
                }
            })
        } else {
            onPurchasesLoaded?()
        }
    }
    
    private func parseUserData(userDocuments: [QueryDocumentSnapshot]) {
        for document in userDocuments {
            for (key, _) in document.data() {
                purchases.append(key.removingPercentEncoding!)
            }
        }
    }
    
    func clearCart() {
        cartItems.removeAll()
        serverItems.removeAll()
        totalPrice = 0.00
    }
    
    func appendElementToCart(elementName: String, serverName: String, disciplineName: String) {
        cartItems.append(elementName)
        serverItems.append(serverName)
        totalPrice += IAP.shared.getFloatPrice(productName: elementName)
//        if let prices = pricesService.prices {
//        totalPrice += prices.getPriceForDiscipline(disciplineName: disciplineName)
//
//        }
//        totalPrice = Float(round(100 * totalPrice) / 100)
    }
    
    func removeElementFromCart(elementName: String, serverName: String, disciplineName: String) {
        cartItems = cartItems.filter { $0 != elementName }
        serverItems = serverItems.filter { $0 != serverName }
        totalPrice -= IAP.shared.getFloatPrice(productName: elementName)
//        if let prices = pricesService.prices {
////            totalPrice -= prices.getPriceForDiscipline(disciplineName: disciplineName)
//        }
//        totalPrice = Float(round(100 * totalPrice) / 100)
    }
    
    func saveCartToServer() {
        if let userId = Auth.auth().currentUser?.uid {
            let db = Firestore.firestore()
            let userCartRef = db.collection(Constants.FirebaseTables.Users).document(userId).collection("Cart").document("Shop")
            userCartRef.setData(["Cart" : serverItems], completion: { error in
                if error != nil {
                    self.onCartError?()
                } else {
                    self.onCartSuccess?()
                }
            })
        } else {
            onCartError?()
        }
    }
    
    //MARK: Appstore
    func tryFetchPurchases() {
        IAP.shared.fetchProducts()
    }
    
    func purchaseCartAtAppstore() {
        print("PURCHASES purchase cart \(cartItems)")
        let productIDs = cartItems.map { IAPRouter.tableName(name: $0).productID }
        IAP.shared.purchase(productIDs: productIDs)
//        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//            for item in cartItems {
//                print(item)
//                appDelegate.iapObserver.purchase(productID: IAPRouter.tableName(name: item).productID)
//            }
//        }
    }
    
    func refreshAppStorePurchases() {
        let existingPurchases = UserDefaults.standard.string(forKey: keyPurchasedProducts)
        print("PURCHASES before refresh \(existingPurchases ?? "nil")")
        if !(existingPurchases ?? "").isEmpty {
            let separatedString = existingPurchases!.components(separatedBy: Constants.Values.StringSeparator)
            UserDefaults.standard.removeObject(forKey: keyPurchasedProducts)
            for tableName in separatedString {
                print("PURCHASES refresh one table \(tableName)")
                restorePurchasedFirebaseTable(tableName: tableName)
            }
        }
    }
    
    private func restorePurchasedFirebaseTable(tableName: String) {
        
        print("PURCHASES try record to firebase \(tableName)")
        if let userId = Auth.auth().currentUser?.uid {
            let documentName = IAPRouter.tableName(name: tableName).purchaseTableName
            let db = Firestore.firestore()
            let purchasesRef = db.collection(Constants.FirebaseTables.Users).document(userId).collection("Purchases").document(documentName)
            let nextYearDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
            purchasesRef.setData([tableName : nextYearDate], merge: true, completion: { error in
                if error != nil {
                    print("PURCHASES firebase fail \(tableName)")
                    self.addPurchasedProductToMemeory(tableName: tableName)
                } else {
                    print("PURCHASES firebase success \(tableName)")
                    self.usersSelectionService.loadUserSelection()
                }
            })
        } else {
            print("PURCHASES user id fail \(tableName)")
            self.addPurchasedProductToMemeory(tableName: tableName)
        }
    }
    
    private func addPurchasedProductToMemeory(tableName: String) {
        let existingPurchases = UserDefaults.standard.string(forKey: keyPurchasedProducts)
        print("PURCHASES before record failure to memory \(tableName)")
        if (existingPurchases ?? "").isEmpty {
            UserDefaults.standard.setValue(tableName, forKey: keyPurchasedProducts)
            print("PURCHASES memory recorded \(tableName)")
        } else {
            var separatedString = existingPurchases!.components(separatedBy: Constants.Values.StringSeparator)
            separatedString.append(tableName)
            UserDefaults.standard.setValue(separatedString.joined(separator: Constants.Values.StringSeparator), forKey: keyPurchasedProducts)
            print("PURCHASES memory recorded \(separatedString.joined(separator: Constants.Values.StringSeparator))")
        }
    }
    
    func registerPurchaseEvent(placeOfPurchase: String) {
        let priceString = "\(totalPrice)\(getLocalizedCurrency()). \(placeOfPurchase)"
        Analytics.logEvent("event_click_go_to_shop", parameters: [
            "Id" : 100 as NSObject,
            "Details" : priceString as NSObject
        ])
        
        let parameters = [
            AppEvents.ParameterName("amount").rawValue: NSNumber(value: totalPrice),
            AppEvents.ParameterName("currency").rawValue: getLocalizedCurrency(),
            AppEvents.ParameterName("shop").rawValue: placeOfPurchase
        ] as [String : Any]
        
        AppEvents.logEvent(.init("event_click_go_to_shop"), parameters: parameters)
    }
    
    func getLocalizedCurrency() -> String {
        IAP.shared.getLocalizedCurrency()
    }
    
    func getFullPrice(productName: String) -> String {
        IAP.shared.getFullPrice(productName: productName)
    }
    
}
