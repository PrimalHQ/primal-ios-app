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
    private override init() { }
    
    static let monthlyPremiumId = "monthlyPremium"
    static let yearlyPremiumId = "yearlyPremium"
    
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
    
    func fetchPremiumSubscriptions(completion: @escaping (([SKProduct])->Void)) {
        fetchProductCompletion = completion
        productsRequest = SKProductsRequest(productIdentifiers: [Self.monthlyPremiumId, Self.yearlyPremiumId])
        productsRequest.delegate = self
        productsRequest.start()
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

extension SKPaymentTransaction {
    func encodeToString() -> String? {
        guard let productIdentifier = payment.productIdentifier as String?,
              let transactionIdentifier = transactionIdentifier,
              let transactionDate = transactionDate else {
            return nil
        }
        
        // Convert the transaction state to a string
        let encodedTransactionState: String
        switch transactionState {
        case .purchased: encodedTransactionState = "purchased"
        case .failed: encodedTransactionState = "failed"
        case .restored: encodedTransactionState = "restored"
        case .deferred: encodedTransactionState = "deferred"
        case .purchasing: encodedTransactionState = "purchasing"
        @unknown default: encodedTransactionState = "unknown"
        }

        // Error details
        let errorDescription = error?.localizedDescription

        // Original transaction info for restored purchases
        let originalTransactionIdentifier = original?.transactionIdentifier
        let originalTransactionDate = original?.transactionDate?.timeIntervalSince1970
        
        // Additional payment details
        let quantity = payment.quantity
        let applicationUsername = payment.applicationUsername
        let requestData = payment.requestData?.base64EncodedString() // Base64 encode requestData if present

        // Create a dictionary with all transaction details
        var transactionInfo: [String: JSON] = [
            "productIdentifier": .string(productIdentifier),
            "transactionIdentifier": .string(transactionIdentifier),
            "transactionDate": .number(transactionDate.timeIntervalSince1970),
            "transactionState": .string(encodedTransactionState),
            "quantity": .number(Double(quantity))
        ]
        
        // Conditionally add optional fields if available
        if let errorDescription = errorDescription {
            transactionInfo["errorDescription"] = .string(errorDescription)
        }
        
        if let originalTransactionIdentifier = originalTransactionIdentifier {
            transactionInfo["originalTransactionIdentifier"] = .string(originalTransactionIdentifier)
        }
        
        if let originalTransactionDate = originalTransactionDate {
            transactionInfo["originalTransactionDate"] = .number(originalTransactionDate)
        }

        if let applicationUsername = applicationUsername {
            transactionInfo["applicationUsername"] = .string(applicationUsername)
        }
        
        if let requestData = requestData {
            transactionInfo["requestData"] = .string(requestData)
        }
        
        return transactionInfo.encodeToString()
    }
}
