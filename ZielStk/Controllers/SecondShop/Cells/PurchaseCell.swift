//Created on 9/23/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import UIKit

protocol PurchaseCellProtocol: UITableViewCell {
    func setData(indexPath: IndexPath, nameOfTest: String, cartItems: [String], purchasedItems: [String], stringOfCount: String?, delegate: TestPurchaseDelegate)
}

class PurchaseCell: UITableViewCell, PurchaseCellProtocol {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var purchaseSwitch: UISwitch!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    
    private unowned var testPuchaseDelegate: TestPurchaseDelegate!
    private var delegateSetted = false
    private var indexOfCell = IndexPath()
    
    func setData(indexPath: IndexPath, nameOfTest: String, cartItems: [String], purchasedItems: [String], stringOfCount: String?, delegate: TestPurchaseDelegate) {
        self.indexOfCell = indexPath
        if let stringOfCount = stringOfCount {
            self.counterLabel.text = stringOfCount
        } else {
            counterLabel.text = NSLocalizedString("NoDataCountText", comment: "")
        }
        
        var isPurchased = purchasedItems.contains(nameOfTest)
        if !isPurchased {
            for itemName in purchasedItems {
                if nameOfTest.lowercased() == itemName.lowercased() {
                    isPurchased = true
                    break
                }
            }
        }
        
        purchaseSwitch.isEnabled = !isPurchased
        purchaseSwitch.isOn = isPurchased
        nameLabel.textColor = isPurchased ? UIColor.systemGreen : UIColor.darkGray
        nameLabel.text = nameOfTest
        if cartItems.contains(nameOfTest) {
            purchaseSwitch.isOn = true
        }
        testPuchaseDelegate = delegate
        delegateSetted = true
        priceLabel.text = testPuchaseDelegate.getFullPrice(productName: nameOfTest)
    }
    
    @IBAction func onPurchaseChanged(_ sender: Any) {
        if delegateSetted {
            testPuchaseDelegate.onTestPurchaseChange(nameOfItem: nameLabel.text!, indexOfItem: indexOfCell, setedToCart: purchaseSwitch.isOn)
        }
    }
    
    
}
