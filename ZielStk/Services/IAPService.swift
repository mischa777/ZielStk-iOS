//
//  IAPService.swift
//  ZielStk
//
//  Created by Roman Voinitchi on 12/3/19.
//  Copyright В© 2019 Roman Voinitchi. All rights reserved.
//

import Foundation

protocol IAPServiceProtocol {
    var onIAPError: (() -> ())? { get set }
    var onPurchaseCompleted: ((String) -> ())? { get set }

    func fetchProducts()
    func purchase(productID: String)
    func getLocalizedCurrency() -> String
    func getFullPrice(productName: String) -> String
    func getFloatPrice(productName: String) -> Float
}

final class IAPService: IAPServiceProtocol {
    var onIAPError: (() -> ())? {
        didSet { IAP.shared.onIAPError = onIAPError }
    }

    var onPurchaseCompleted: ((String) -> ())? {
        didSet { IAP.shared.onPurchaseCompleted = onPurchaseCompleted }
    }

    func fetchProducts() {
        IAP.shared.fetchProducts()
    }

    func purchase(productID: String) {
        IAP.shared.purchase(productID: productID)
    }

    func getLocalizedCurrency() -> String {
        IAP.shared.getLocalizedCurrency()
    }

    func getFullPrice(productName: String) -> String {
        IAP.shared.getFullPrice(productName: productName)
    }

    func getFloatPrice(productName: String) -> Float {
        IAP.shared.getFloatPrice(productName: productName)
    }
}
