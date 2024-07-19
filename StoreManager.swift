//
//  StoreManager.swift
//  FrugalFoodie
//
//  Created by Adam Gumm on 6/18/23.
//

import Foundation
import StoreKit

class StoreManager: NSObject, ObservableObject, SKPaymentQueueDelegate {
    static let shared = StoreManager()

    // Product identifiers for the premium feature
    private let premiumProductIdentifier = "PremiumAppFeatures1"

    // StoreKit variables
    private var products: [SKProduct] = []
    private var paymentQueue: SKPaymentQueue

    // Purchase status
    @Published var isPremiumUnlocked = false

    private override init() {
        paymentQueue = SKPaymentQueue.default()
        super.init()
        paymentQueue.add(self)
    }

    // Request products from the App Store
    func requestProducts() {
        let productIdentifiers: Set<String> = [premiumProductIdentifier]
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }

    // Initiate the purchase process for the premium feature
    func purchasePremium() {
        guard let premiumProduct = products.first else { return }
        let payment = SKPayment(product: premiumProduct)
        paymentQueue.add(payment)
    }
}

//class StoreManager: NSObject, ObservableObject {
//    @Published var isPremiumUnlocked = false
//
//    private var productIdentifier: String = "PremiumAppFeatures1"
//
//    private var paymentQueue: SKPaymentQueue {
//        SKPaymentQueue.default()
//    }
//
//    override init() {
//        super.init()
//        paymentQueue.add(self)
//    }
//
//    deinit {
//        paymentQueue.remove(self)
//    }
//
//    func purchasePremium() {
//        guard let productIdentifier = productIdentifier else {
//            print("Error: Product identifier is not set.")
//            return
//        }
//
//        let payment = SKPayment(product: productIdentifier)
//        paymentQueue.add(payment)
//    }
//}

// MARK: - StoreKit Delegates

extension StoreManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Product request failed with error: \(error.localizedDescription)")
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
            // Handle direct purchases initiated from the App Store payment sheet
        return true
    }
}

extension StoreManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                // Unlock premium feature
                isPremiumUnlocked = true
                print("purchased success")
                DataController().savePremiumPurchase()
                // Finish the transaction
                queue.finishTransaction(transaction)
            case .failed:
                // Handle failed transactions
                if let error = transaction.error {
                    print("Transaction failed with error: \(error.localizedDescription)")
                }
                queue.finishTransaction(transaction)
            case .restored:
                // Handle restored transactions
                isPremiumUnlocked = true
                print("purchase restored")
                DataController().savePremiumPurchase()
                queue.finishTransaction(transaction)
            case .deferred:
                // Do nothing for deferred or purchasing transactions
                print("nothing: deferred:  \(transaction.transactionState.rawValue)")
            case .purchasing:
                print("purchasing stuck and pending")
                break
            @unknown default:
                break
            }
        }
    }
}
