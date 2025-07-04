//
//  InAppPurchaseManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 16.10.23..
//

import Foundation
import StoreKit
import GenericJSON

enum IAPHandlerAlertType {
    case disabled
    case purchased
    case failed
    
    var message: String{
        switch self {
        case .disabled:     return "Purchases are disabled in your device!"
        case .purchased:    return "You've successfully bought this purchase!"
        case .failed:       return "Purchase has failed"
        }
    }
}

final class InAppPurchaseManager: NSObject {
    static let shared = InAppPurchaseManager()
    private override init() {
        
        let transactions = Transaction.all
        
        print(transactions)
    
        
        Task { @MainActor in
            
            for await transaction in Transaction.currentEntitlements {
                print(transaction)
            }
            
            print("END")
            
            for await result in Transaction.updates {
                switch result {
                case .verified(let transaction):
                    print(transaction)
                    break
                    // Deliver the purchased content
                case .unverified(let transaction, let error):
                    print(transaction)
                    print(error)
                    break
                    // Handle the error
                }
            }
        }
    }
    
    static let monthlyPremiumId = "monthlyPremium"
    static let yearlyPremiumId = "yearlyPremium"
    static let monthlyProId = "monthlyProSub"
    static let yearlyProId = "yearlyProSub"
    
    //MARK: - Private
    fileprivate let productIds: Set<String> = ["MINSATS"]

    fileprivate var productID = ""
    fileprivate var productsRequest = SKProductsRequest()
    fileprivate var fetchProductCompletion: (([SKProduct])->Void)?
    
    fileprivate var productToPurchase: SKProduct?
    fileprivate var purchaseProductCompletion: ((IAPHandlerAlertType, SKProduct?, SKPaymentTransaction?)->Void)?
    
    //MARK: - Public
    func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
    
    func purchase(product: SKProduct, completion: @escaping ((IAPHandlerAlertType, SKProduct?, SKPaymentTransaction?)->Void)) {
        purchaseProductCompletion = completion
        productToPurchase = product

        guard canMakePurchases() else {
            completion(IAPHandlerAlertType.disabled, nil, nil)
            return
        }
     
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
        
        productID = product.productIdentifier
    }
    
    func purchase(product: Product, completion: @escaping ((Product.PurchaseResult?) -> Void)) {
        guard canMakePurchases() else {
            completion(nil)
            return
        }
       
        Task { @MainActor in
            do {
                let result = try await product.purchase()
                
                completion(result)

                switch result {
                case .success(let verification):
                    switch verification {
                    case .verified(let transaction):
                        // Handle successful purchase
                        await transaction.finish()
                        print("Purchase successful: \(transaction.id)")
                    case .unverified(_, let error):
                        print("Purchase error: \(error)")
                    }
                case .userCancelled:
                    print("User cancelled the purchase.")
                case .pending:
                    print("Transaction pending.")
                @unknown default:
                    break
                }
            } catch {
                completion(nil)
                print("Purchasing error \(error)")
            }
        }
    }
    
    func fetchWalletProducts(completion: @escaping (([SKProduct])->Void)){
        fetchProductCompletion = completion
                
        productsRequest = SKProductsRequest(productIdentifiers: productIds)
        productsRequest.delegate = self
        productsRequest.start()
        
//        let productIds = productIds
//        Task { @MainActor in
//            do {
//                let products = try await Product.products(for: productIds)
//                for product in products {
//                    print("Product: \(product.displayName), Price: \(product.displayPrice)")
//                }
//            } catch {
//                print("Failed to fetch products: \(error)")
//            }
//        }
    }
    
    func fetchPremiumSubscriptions(completion: @escaping (([StoreKit.Product])->Void)) {
        let productIds = [Self.monthlyPremiumId, Self.yearlyPremiumId, Self.monthlyProId, Self.yearlyProId]
        
        Task { @MainActor in
            do {
                let products = try await Product.products(for: productIds)
                completion(products)
            } catch {
                completion([])
                print("Failed to fetch products: \(error)")
            }
        }
    }
    
    func checkSubscriptionStatus() async -> Bool {
        do {
            for await transaction in Transaction.currentEntitlements {
                return true
            }
        } catch {
            print("Failed to check subscription: \(error)")
        }
        return false
    }
}

extension InAppPurchaseManager: SKProductsRequestDelegate, SKPaymentTransactionObserver{
    func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        for invalidIdentifier in response.invalidProductIdentifiers {
            print("Invalid identifier: \(invalidIdentifier)")
        }
        
        DispatchQueue.main.async {
            self.fetchProductCompletion?(response.products)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                
                DispatchQueue.main.async {
                    self.purchaseProductCompletion?(IAPHandlerAlertType.purchased, self.productToPurchase, transaction)
                }
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                
                DispatchQueue.main.async {
                    self.purchaseProductCompletion?(IAPHandlerAlertType.failed, self.productToPurchase, transaction)
                }
            default:
                break
            }
        }
    }
}
