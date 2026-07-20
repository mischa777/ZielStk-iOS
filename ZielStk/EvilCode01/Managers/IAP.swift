//
//  IAP.swift
//  ZielStk
//
//  Created by Alexandru on 06.09.2021.
//  Copyright В© 2021 Roman Voinitchi. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

protocol IAPDelegate: AnyObject {
    func IAP_Purchased(purchase: PurchaseDetails)
    func IAP_Restored(result: RestoreResults)
    func IAP_Receipt(receipt: ReceiptInfo)
}

struct PurchaseDetails {
    let productID: String
    let purchaseDate: Date
    let transactionID: UInt64
}

struct RestoreResults {
    let restoredProductIDs: [String]
}

struct ReceiptItem {
    let productId: String
    let originalPurchaseDate: Date
}

typealias ReceiptInfo = [ReceiptItem]

final class IAP: NSObject {
    static let shared = IAP()

    weak var delegate: IAPDelegate?
    var onIAPError: (() -> ())?
    var onPurchaseCompleted: ((String) -> ())?

    private var productIDs = Set<String>()
    private var productsByID: [String: Product] = [:]
    private var updatesTask: Task<Void, Never>?

    private override init() {
        super.init()
    }

    func setupPurchases(products: [String]) {
        productIDs = Set(products)
        startTransactionListenerIfNeeded()
        fetchProducts(force: true)
    }

    func fetchProducts(force: Bool = false) {
        Task {
            await loadProductsIfNeeded(force: force)
        }
    }

    func purchase(productID: String) {
        Task {
            await performPurchase(productID: productID)
        }
    }

    func purchase(productIDs: [String]) {
        Task {
            for productID in productIDs {
                await performPurchase(productID: productID)
            }
        }
    }

    func restore() {
        lockUI()

        Task { @MainActor in
            defer { unlockUI() }

            do {
                try await AppStore.sync()
                let restoredProductIDs = await loadReceiptItems().map(\.productId)

                if restoredProductIDs.isEmpty {
                    IAP.alert(title: nil, message: NSLocalizedString("IAP_NothingRestore", comment: ""), buttonTitle: "OK", completion: nil)
                } else {
                    delegate?.IAP_Restored(result: RestoreResults(restoredProductIDs: restoredProductIDs))
                }
            } catch {
                print("[IAP] restore failed: \(error.localizedDescription)")
                onIAPError?()
                IAP.alert(title: "Error", message: error.localizedDescription, buttonTitle: "OK", completion: nil)
            }
        }
    }

    func verifyReceipt(_ loader: Bool = true) {
        if !loader {
            lockUI()
        }

        Task { @MainActor in
            let receipt = await loadReceiptItems()
            delegate?.IAP_Receipt(receipt: receipt)

            if !loader {
                unlockUI()
            }
        }
    }

    func getLocalizedCurrency() -> String {
        Locale.autoupdatingCurrent.currencySymbol ?? ""
    }

    func getFullPrice(productName: String) -> String {
        let productID = IAPRouter.tableName(name: productName).productID
        return productsByID[productID]?.displayPrice ?? "0"
    }

    func getFloatPrice(productName: String) -> Float {
        let productID = IAPRouter.tableName(name: productName).productID
        guard let price = productsByID[productID]?.price else { return 0 }
        return NSDecimalNumber(decimal: price).floatValue
    }

    private func product(for productID: String) async -> Product? {
        await loadProductsIfNeeded(force: false)
        return productsByID[productID]
    }

    @MainActor
    private func performPurchase(productID: String) async {
        lockUI()
        defer { unlockUI() }

        guard let product = await product(for: productID) else {
            onIAPError?()
            IAP.alert(title: "Error", message: "The product is not available in the current storefront")
            return
        }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()

                let purchase = PurchaseDetails(
                    productID: transaction.productID,
                    purchaseDate: transaction.purchaseDate,
                    transactionID: transaction.id
                )

                onPurchaseCompleted?(transaction.productID)
                delegate?.IAP_Purchased(purchase: purchase)
            case .userCancelled:
                break
            case .pending:
                IAP.alert(title: nil, message: NSLocalizedString("IAP_Pending", comment: ""), buttonTitle: "OK")
            @unknown default:
                onIAPError?()
            }
        } catch {
            print("[IAP] purchase failed: \(error.localizedDescription)")
            onIAPError?()
            IAP.alert(title: "Error", message: error.localizedDescription, buttonTitle: "OK", completion: nil)
        }
    }

    private func loadProductsIfNeeded(force: Bool) async {
        if !force && !productsByID.isEmpty {
            return
        }

        do {
            let products = try await Product.products(for: Array(productIDs))
            let sortedProducts = products.sorted {
                NSDecimalNumber(decimal: $0.price).doubleValue > NSDecimalNumber(decimal: $1.price).doubleValue
            }

            await MainActor.run {
                self.productsByID = Dictionary(uniqueKeysWithValues: sortedProducts.map { ($0.id, $0) })
            }
        } catch {
            print("[IAP] product fetch failed: \(error.localizedDescription)")
        }
    }

    private func loadReceiptItems() async -> ReceiptInfo {
        var itemsByProductID: [String: ReceiptItem] = [:]

        for await result in Transaction.all {
            guard
                let transaction = try? checkVerified(result),
                productIDs.contains(transaction.productID),
                transaction.revocationDate == nil
            else {
                continue
            }

            let item = ReceiptItem(
                productId: transaction.productID,
                originalPurchaseDate: transaction.purchaseDate
            )

            if let existingItem = itemsByProductID[transaction.productID] {
                if item.originalPurchaseDate < existingItem.originalPurchaseDate {
                    itemsByProductID[transaction.productID] = item
                }
            } else {
                itemsByProductID[transaction.productID] = item
            }
        }

        return itemsByProductID.values.sorted { $0.productId < $1.productId }
    }

    private func startTransactionListenerIfNeeded() {
        guard updatesTask == nil else { return }

        updatesTask = Task(priority: .background) {
            for await update in Transaction.updates {
                guard let transaction = try? self.checkVerified(update) else { continue }
                await transaction.finish()
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let signedType):
            return signedType
        case .unverified(_, _):
            throw StoreError.failedVerification
        }
    }

    private lazy var lockView: UIView = { LockView() }()

    private func lockUI() {
        guard lockView.superview == nil else { return }
        guard let keyWindow = UIApplication.shared.activeKeyWindow else { return }
        keyWindow.addSubview(lockView)
    }

    private func unlockUI() {
        guard lockView.superview != nil else { return }
        lockView.removeFromSuperview()
    }
}

extension IAP {
    static func alert(title: String? = nil, message: String? = nil, buttonTitle: String = "OK", completion: (() -> Void)? = nil) {
        if var topController = UIApplication.shared.activeKeyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }

            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let cancelBtn = UIAlertAction(title: buttonTitle, style: .cancel) { _ in
                completion?()
            }

            ac.addAction(cancelBtn)
            topController.present(ac, animated: true, completion: nil)
        }
    }
}

private enum StoreError: Error {
    case failedVerification
}

fileprivate final class LockView: UIView {
    init() {
        super.init(frame: UIScreen.main.bounds)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = UIColor(white: 0, alpha: 0.5)

        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.startAnimating()

        addSubview(indicator)

        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        indicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
}
