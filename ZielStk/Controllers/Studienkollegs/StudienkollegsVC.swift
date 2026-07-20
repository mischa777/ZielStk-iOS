//
//  StudienkollegsVC.swift
//  ZielStk
//
//  Created by Roman Voinitchi on 9/11/19.
//  Copyright © 2019 Roman Voinitchi. All rights reserved.
//

import UIKit

class StudienkollegsVC: UIViewController, PreloaderOpennerProtocol, AlertOpennerProtocol {
    
    @IBOutlet weak var studiensTable: UITableView!
    @IBOutlet weak var noCoursesView: UIView!
    
    private var viewModel: StudienkollegsVMProtocol! {
        didSet {
            self.viewModel.onUserStksLoaded = { [weak self] in
                self?.setLoadedStks()
            }
//            self.viewModel.onVerificationSent = { [weak self] in
//                let title = NSLocalizedString("AttentionTitle", comment: "")
//                let message = NSLocalizedString("VerificationNotification", comment: "")
//                self?.showAlert(title: title, message: message)
//            }
        }
    }
    private var shopModel: ShopVMProtocol!
    private var heightsOfCells = [CGFloat]()
    
    override func viewDidLoad() {
        viewModel = StudienkollegsVM()
        shopModel = ShopVM()
        super.viewDidLoad()
        studiensTable.tableFooterView = UIView(frame: .zero)
//        viewModel.checkVerification()
        Profile.shared.sync()
        IAP.shared.delegate = self
        handle_Restore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        noCoursesView.isHidden = true
        showPreloader()
        viewModel.loadUserStks()
        checkPosted()
    }
    
    private func checkPosted() {
        let ud = UserDefaults(suiteName: "group.com.CTestGroup")
        ud?.synchronize()
        if let postedString = ud?.value(forKey: Constants.Values.KeyPostedString) as? String {
            if !postedString.isEmpty {
                ud!.removeObject(forKey: Constants.Values.KeyPostedString)
                ud!.synchronize()
                performSegue(withIdentifier: Constants.Segues.CTestFromBase, sender: postedString)
            }
        }
    }
    
    private func setLoadedStks() {
        hidePreloader()
        if viewModel.userStks.count == 0 {
            noCoursesView.isHidden = false
        } else {
            heightsOfCells.removeAll()
            for _ in viewModel.userStks {
                heightsOfCells.append(CGFloat(Constants.Cells.StudienCollegsCellHeight))
            }
        }
        studiensTable.reloadData()
    }
    
    @IBAction func onEditCoursesTap(_ sender: Any) {
        performSegue(withIdentifier: Constants.Segues.ChooseCourses, sender: self)
    }
    
}

//MARK: - Tableview delegate
extension StudienkollegsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightsOfCells[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.userStks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudienCollgeCell", for: indexPath) as! StudienCollgeCellProtocol
        cell.setCellData(cellIndex: indexPath.row, stk: viewModel.userStks[indexPath.row], tapsDelegate: self)
        return cell
    }
    
}

//MARK: - Protocols
extension StudienkollegsVC: StudienCellDelegateProtocol {
    
    func selectRowAt(index: Int) {
        for indexOfElement in 0 ..< heightsOfCells.count {
            heightsOfCells[indexOfElement] = CGFloat(Constants.Cells.StudienCollegsCellHeight)
        }
        heightsOfCells[index] = CGFloat(Constants.Cells.StudienCollegsCellHeight) + CGFloat(Constants.Cells.StudienCollegsInfoViewHeight)
        studiensTable.beginUpdates()
        studiensTable.endUpdates()
    }
    
    func showLabelRowAt(index: Int, labelHeight: CGFloat) {
        heightsOfCells[index] = CGFloat(Constants.Cells.StudienCollegsCellHeight) + CGFloat(Constants.Cells.StudienCollegsInfoViewHeight) + labelHeight
        studiensTable.beginUpdates()
        studiensTable.endUpdates()
    }
    
    func gotToStudienCourses(rowIndex: Int) {
        performSegue(withIdentifier: Constants.Segues.CollegsTest, sender: viewModel.userStks[rowIndex].stk_name)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navVC = segue.destination as? UINavigationController {
            if let testsVC = navVC.viewControllers.first as? CollegTestsVC {
                if let stkName = sender as? String {
                    testsVC.stkName = stkName
                }
            }
        }
        if let deutchTestVC = segue.destination as? DeutchCompilerVC {
            if let postedString = sender as? String {
                deutchTestVC.postedString = postedString
            }
        }
    }
    
    func showStarAlert(stringToShow: String) {
        let title = NSLocalizedString("NoteString", comment: "")
        showAlert(title: title, message: stringToShow)
    }
    
}

protocol StudienCellDelegateProtocol: StudienkollegsVC {
    func selectRowAt(index: Int)
    func showLabelRowAt(index: Int, labelHeight: CGFloat)
    func gotToStudienCourses(rowIndex: Int)
    func showStarAlert(stringToShow: String)
}


// MARK: - Restore

import StoreKit
import FirebaseAuth
import FirebaseFirestore

extension StudienkollegsVC {
    
    private func handle_Restore() {
        
        guard !Profile.shared.subsDeleted else { return }
        IAP.shared.verifyReceipt(false)
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
                    self.shopModel.uSelectionService.loadUserSelection()
                    self.shopModel.loadPurchases()
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

extension StudienkollegsVC: IAPDelegate {
    
    func IAP_Purchased(purchase: PurchaseDetails) {
        IAP.shared.verifyReceipt()
    }
    func IAP_Restored(result: RestoreResults) {
        IAP.shared.verifyReceipt()
    }

    func IAP_Receipt(receipt: ReceiptInfo) {
        for item in receipt {
            restorePurchasedFirebaseTable(
                tableName: IAPRouter.purchaseId(id: item.productId).firebaseTableName,
                originalPurchaseDate: item.originalPurchaseDate
            )
        }
    }
}
