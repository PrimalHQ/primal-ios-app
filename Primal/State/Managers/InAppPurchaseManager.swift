//
//  InAppPurchaseManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 16.10.23..
//

import Foundation
import StoreKit

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
    private override init() { }
    
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
    
    func fetchAvailableProducts(completion: @escaping (([SKProduct])->Void)){
        fetchProductCompletion = completion
                
        productsRequest = SKProductsRequest(productIdentifiers: productIds)
        productsRequest.delegate = self
        productsRequest.start()
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
