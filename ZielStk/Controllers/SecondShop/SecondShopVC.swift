//Created on 9/22/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import UIKit

class SecondShopVC: UIViewController, PreloaderOpennerProtocol {
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var shopMoneyLabel: UILabel!
    @IBOutlet weak var coursesTable: UITableView!
    
    private var viewModel: SecondShopVMProtocol! {
        didSet {
            self.viewModel.onStkTestsLoaded = { [weak self] in
                self?.hidePreloader()
                self?.coursesTable.reloadData()
            }
        }
    }
    var selectedShopString = ""
    unowned var shopDelegate: MainShopDelegate!
    
    override func viewDidLoad() {
        viewModel = SecondShopVM()
        super.viewDidLoad()
        coursesTable.tableFooterView = UIView(frame: .zero)
        backBtn.setTitle(selectedShopString, for: .normal)
        
        showPreloader()
        viewModel.loadStksDisciplineAndTests(stkString: selectedShopString)
        showCurrentPrice()
    }
    
    @IBAction func onBackTap(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onRefreshTap(_ sender: Any) {
        onBackTap(self)
        shopDelegate.refreshPurchases()
    }
    
    @IBAction func onShopOkTap(_ sender: Any) {
        if shopDelegate.cartItems.count > 0 {
            onBackTap(self)
            shopDelegate.saveCartToServer()
        }
    }
    
    @IBAction func onShopCancelTap(_ sender: Any) {
        shopDelegate.clearCart()
        coursesTable.reloadData()
        showCurrentPrice()
    }
    
    @IBAction func onAgreemantTap(_ sender: Any) {
        let url = URL(string: viewModel.getAgreementUrl())!
        UIApplication.shared.open(url)
    }
    
    private func showCurrentPrice() {
        shopMoneyLabel.text = "\(shopDelegate.totalPrice) \(shopDelegate.getLocalizedCurrency())"
    }
    
}

//MARK: Table
extension SecondShopVC: UITableViewDelegate, UITableViewDataSource {
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
            return 65
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
        let commonCell = tableView.dequeueReusableCell(withIdentifier: "PurchaseCell", for: indexPath) as! PurchaseCellProtocol
        let nameOfTest = viewModel.sections[indexPath.section].sectionsObjects[indexPath.row] as! String
        commonCell.setData(indexPath: indexPath, nameOfTest: nameOfTest, cartItems: shopDelegate.cartItems, purchasedItems: shopDelegate.purchasedItems, stringOfCount: viewModel.totalExamsArray[nameOfTest], delegate: self)
        return commonCell
    }
    
}

//MARK: - Protocols for cells
extension SecondShopVC: TestPurchaseDelegate, HeaderExpandDelegate {
    
    func getFullPrice(productName: String) -> String {
        return shopDelegate.getFullPrice(productName: productName)
    }
    
    func expandSection(section: Int) {
        viewModel.changeSectionExpand(section: section)
        
        coursesTable.beginUpdates()
        for i in 0 ..< viewModel.sections[section].sectionsObjects.count {
            coursesTable.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
        }
        coursesTable.endUpdates()
    }
    
    func onTestPurchaseChange(nameOfItem: String, indexOfItem: IndexPath, setedToCart: Bool) {
        let sectionString = viewModel.sections[indexOfItem.section].titleObject as! String
        let testString = viewModel.sections[indexOfItem.section].sectionsObjects[indexOfItem.row] as! String
        let serverString = viewModel.getStkName(sectionName: sectionString, testName: testString)
        if setedToCart {
            shopDelegate.appendToCart(itemName: nameOfItem, serverName: serverString, disciplineName: sectionString)
        } else {
            shopDelegate.removeFromCart(itemName: nameOfItem, serverName: serverString, disciplineName: sectionString)
        }
        showCurrentPrice()
    }
    
}

protocol TestPurchaseDelegate: UIViewController {
    func onTestPurchaseChange(nameOfItem: String, indexOfItem: IndexPath, setedToCart: Bool)
    func getFullPrice(productName: String) -> String
}
