//
//  ShopVC.swift
//  ZielStk
//
//  Created by Roman Voinitchi on 9/18/19.
//  Copyright © 2019 Roman Voinitchi. All rights reserved.
//

import UIKit

class ShopVC: UIViewController, PreloaderOpennerProtocol, AlertOpennerProtocol {
    
    @IBOutlet weak var shopMoneyLabel: UILabel!
    @IBOutlet weak var shopCollegesTable: UITableView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var noSelectionView: UIView!
    @IBOutlet weak var restoreBtn: UIButton!
    
    private var colleges = [ExpandableSectionProtocol] ()
    private var viewModel: ShopVMProtocol! {
        didSet {
            self.viewModel.onPurchasesLoaded = { [weak self] in
                self?.hidePreloader()
            }
            self.viewModel.onCartSuccess = { [weak self] in
                self?.setCartCompleteAction()
            }
            self.viewModel.onCartError = { [weak self] in
                self?.setCartErrorMessage()
            }
            self.viewModel.onEmptySelection = { [weak self] in
                self?.hidePreloader()
                self?.noSelectionView.isHidden = false
            }
            self.viewModel.onIAPError = { [weak self] in
                self?.hidePreloader()
                let title = NSLocalizedString("ErrorTitle", comment: "")
                let message = NSLocalizedString("IAPErrorMessage", comment: "")
                self?.showAlert(title: title, message: message)
            }
        }
    }
    
    var needBackBtn = false
    
    override func viewDidLoad() {
        viewModel = ShopVM()
        super.viewDidLoad()
        shopCollegesTable.tableFooterView = UIView(frame: .zero)
        
        backBtn.isHidden = !needBackBtn
        titleLabel.isHidden = needBackBtn
        
        showPreloader()
        showCurrentPrice()
        
        IAP.shared.delegate = self
        restoreBtn.setTitle(NSLocalizedString("IAP_Restore", comment: ""), for: .normal)
        restoreBtn.addTarget(self, action: #selector(handle_Restore), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        noSelectionView.isHidden = true
        viewModel.loadPurchases()
        viewModel.tryFetchPurchases()
        viewModel.setSections()
        viewModel.refreshAppStorePurchases()
        viewModel.setPurchaseObservers()
        shopCollegesTable.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.removePurchaseObservers()
    }
    
    @IBAction func onSelectCoursesTap(_ sender: Any) {
        performSegue(withIdentifier: Constants.Segues.ChooseCourses, sender: self)
    }
    
    @IBAction func onShopByTap(_ sender: Any) {
        if viewModel.cartItems.count > 0 {
//            setSelectionAlert()
            self.viewModel.registerPurchaseEvent(placeOfPurchase: "AppStore")
            self.viewModel.purchaseCartAtAppstore()
        }
    }
    
    @IBAction func onShopCancelTap(_ sender: Any) {
        clearCart()
        showCurrentPrice()
    }
    
    @IBAction func onBackTap(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onAgreemantTap(_ sender: Any) {
        let url = URL(string: viewModel.getAgreementUrl())!
        UIApplication.shared.open(url)
    }
    
    private func showCurrentPrice() {
        shopMoneyLabel.text = "\(viewModel.totalPrice) \(viewModel.getLocalizedCurrency())"
    }
    
    private func setCartCompleteAction() {
        hidePreloader()
        if let url = URL(string: viewModel.getPurchaseUrl()) {
            clearCart()
            showCurrentPrice()
            UIApplication.shared.open(url)
        } else {
            setCartErrorMessage()
        }
    }
    
    private func setCartErrorMessage() {
        hidePreloader()
        let title = NSLocalizedString("ErrorTitle", comment: "")
        let message = NSLocalizedString("CartErrorMessage", comment: "")
        showAlert(title: title, message: message)
    }
    
}

//MARK: - Table
extension ShopVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        goToSubShop(indexPath: indexPath)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].sectionsObjects.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(Constants.Cells.ShopHeaderHeight)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if viewModel.sections[indexPath.section].isExpanded {
            return CGFloat(Constants.Cells.ShopMainHeight)
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = ShopHeaderView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: CGFloat(Constants.Cells.ShopHeaderHeight))) as ShopHeaderViewProtocol
        headerView.setHeaderData(nameOfCollege: viewModel.sections[section].titleObject as! String, sectionNumber: section, delegate: self)
        return headerView.mainView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let commonCell = tableView.dequeueReusableCell(withIdentifier: "CourseSelectionCell", for: indexPath) as! CourseSelectionCellProtocol
        commonCell.setData(courseName: viewModel.sections[indexPath.section].sectionsObjects[indexPath.row] as! String, courseIndex: indexPath, delegate: self)
        return commonCell
    }
}

//MARK: - protocols for cells
extension ShopVC: HeaderExpandDelegate, CourseSelectionDelegate {
    func goToSubShop(indexPath: IndexPath) {
        let selectionString = viewModel.getSelectedString(indexPath: indexPath)
        performSegue(withIdentifier: Constants.Segues.SecondShop, sender: selectionString)
    }
    
    func expandSection(section: Int) {
        viewModel.changeSectionExpand(section: section)
        
        shopCollegesTable.beginUpdates()
        for i in 0 ..< viewModel.sections[section].sectionsObjects.count {
            shopCollegesTable.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
        }
        shopCollegesTable.endUpdates()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let subShopVC = segue.destination as? SecondShopVC {
            subShopVC.shopDelegate = self
            if let selectedCourse = sender as? String {
                subShopVC.selectedShopString = selectedCourse
            }
        }
    }
}

protocol HeaderExpandDelegate: UIViewController {
    func expandSection(section: Int)
}

protocol CourseSelectionDelegate: UIViewController {
    func goToSubShop(indexPath: IndexPath)
}

//MARK: - ShopDelegate
extension ShopVC: MainShopDelegate {
    
    func getFullPrice(productName: String) -> String {
        return viewModel.getFullPrice(productName: productName)
    }
    
    var totalPrice: Float {
        return viewModel.totalPrice
    }
    
    var purchasedItems: [String] {
        return viewModel.purchases
    }
    
    var cartItems: [String] {
        return viewModel.cartItems
    }
    
    func appendToCart(itemName: String, serverName: String, disciplineName: String) {
        viewModel.appendElementToCart(elementName: itemName, serverName: serverName, disciplineName: disciplineName)
        showCurrentPrice()
    }
    
    func removeFromCart(itemName: String, serverName: String, disciplineName: String) {
        viewModel.removeElementFromCart(elementName: itemName, serverName: serverName, disciplineName: disciplineName)
        showCurrentPrice()
    }
    
    func clearCart() {
        viewModel.clearCart()
        showCurrentPrice()
    }
    
    func saveCartToServer() {
//        setSelectionAlert()
        self.viewModel.registerPurchaseEvent(placeOfPurchase: "AppStore")
        self.viewModel.purchaseCartAtAppstore()
    }
    
    func refreshPurchases() {
        showPreloader()
        viewModel.refreshAppStorePurchases()
    }
    
    func getLocalizedCurrency() -> String {
        return viewModel.getLocalizedCurrency()
    }
    
//    private func setSelectionAlert() {
//        let title = NSLocalizedString("AttentionTitle", comment: "")
//        let message = NSLocalizedString("SelectShopMessage", comment: "")
//        let siteBtnTitle = NSLocalizedString("SiteShop", comment: "")
//        let appStoreBtnTitle = NSLocalizedString("AppStoreShop", comment: "")
//
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: appStoreBtnTitle, style: .default, handler: { alertAction in
////            self.showPreloader()
//            self.viewModel.registerPurchaseEvent(placeOfPurchase: "AppStore")
//            self.viewModel.purchaseCartAtAppstore()
//        }))
//        alert.addAction(UIAlertAction(title: siteBtnTitle, style: .default, handler: { alertAction in
//            self.showPreloader()
//            self.viewModel.registerPurchaseEvent(placeOfPurchase: "Сайт")
//            self.viewModel.saveCartToServer()
//        }))
//
//        self.present(alert, animated: true, completion: nil)
//
////        self.viewModel.purchaseCartAtAppstore()
//    }
    
}

protocol MainShopDelegate: UIViewController {
    var purchasedItems: [String] { get }
    var cartItems: [String] { get }
    var totalPrice: Float { get }
    
    func appendToCart(itemName: String, serverName: String, disciplineName: String)
    func removeFromCart(itemName: String, serverName: String, disciplineName: String)
    func clearCart()
    func saveCartToServer()
    func refreshPurchases()
    func getLocalizedCurrency() -> String
    func getFullPrice(productName: String) -> String
}

// MARK: - Restore

import StoreKit
import FirebaseAuth
import FirebaseFirestore

extension ShopVC {
    
    @objc private func handle_Restore() {
        
        HAPTIC_FEEDBACK(type: .hard)
        
        if Profile.shared.subsDeleted {
            showAlertMess(title: NSLocalizedString("Copyright_Abuze", comment: ""), message: nil, buttonTitle: "OK", completion: nil)
            return
        }
    
        IAP.shared.restore()
    }
    private func restorePurchasedFirebaseTable(tableName: String, originalPurchaseDate: Date) {

        print("PURCHASES try record to firebase \(tableName)")
        if let userId = Auth.auth().currentUser?.uid {
            let documentName = IAPRouter.tableName(name: tableName).purchaseTableName
            let db = Firestore.firestore()
            let purchasesRef = db.collection(Constants.FirebaseTables.Users).document(userId).collection("Purchases").document(documentName)
            let nextYearDate = Calendar.current.date(byAdding: .year, value: 1, to: originalPurchaseDate)!
            purchasesRef.setData([tableName : nextYearDate], merge: true, completion: { error in
                if error != nil {
                    print("PURCHASES firebase fail \(tableName)")
                    self.addPurchasedProductToMemeory(tableName: tableName)
                } else {
                    print("PURCHASES firebase success \(tableName)")
                    self.viewModel.uSelectionService.loadUserSelection()
                    self.viewModel.loadPurchases()
                }
            })
        } else {
            print("PURCHASES user id fail \(tableName)")
            self.addPurchasedProductToMemeory(tableName: tableName)
        }
    }
    private func addPurchasedProductToMemeory(tableName: String) {
        let keyPurchasedProducts = "purchasedProducts";
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
}

extension ShopVC: IAPDelegate {
    
    func IAP_Purchased(purchase: PurchaseDetails) {
        IAP.shared.verifyReceipt()
    }
    func IAP_Restored(result: RestoreResults) {
        IAP.shared.verifyReceipt()
    }

    func IAP_Receipt(receipt: ReceiptInfo) {
        guard !receipt.isEmpty else {
            self.showAlertMess(title: nil, message: NSLocalizedString("IAP_NothingRestore", comment: ""), buttonTitle: "OK", completion: nil)
            return
        }

        HAPTIC_FEEDBACK(type: .success)
        for item in receipt {
            print("[PURCHASED] => [\(item.productId)] => \(item.originalPurchaseDate)")
            restorePurchasedFirebaseTable(
                tableName: IAPRouter.purchaseId(id: item.productId).firebaseTableName,
                originalPurchaseDate: item.originalPurchaseDate
            )
        }
        self.showAlertMess(title: "Success!", message: "Items (\(receipt.count))", buttonTitle: "OK", completion: nil)
    }
}
