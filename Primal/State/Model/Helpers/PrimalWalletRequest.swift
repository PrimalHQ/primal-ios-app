//
//  PrimalWalletRequest.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.10.23..
//

import Combine
import GenericJSON
import Foundation
import StoreKit

struct AdditionalDepositInfo {
  var satoshi: Int
  var description: String
}

struct PrimalPaymentTransaction : Encodable {
  let transactionId: String
  let productId: String
  let date: Date
}

struct PrimalWalletRequest {
    enum RequestType {
        case isUser
        case balance
        case transactions(until: Int? = nil, since: Int? = nil)
        case send(target: String, pubkey: String, amount: String, note: String, zap: NostrObject?)
        case deposit(AdditionalDepositInfo? = nil)
        case inAppPurchase(transactionId: String, quote: String)
        case quote(productId: String, countryCode: String)
        case activationCode(name: String, email: String)
        case activate(code: String)
        
        var requestContent: String {
            switch self {
            case .isUser:
                return "[\"is_user\",{\"pubkey\":\"\(IdentityManager.instance.userHexPubkey)\"}]"
            case .balance:
                return "[\"balance\",{\"subwallet\":1}]"
            case .deposit(let info):
                if let info {
                    let description = info.description.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
                    if info.satoshi > 0 {
                        let amount = info.satoshi.satsToBitcoinString()
                        return "[\"deposit\",{\"subwallet\":1,\"amount_btc\":\"\(amount)\",\"description\":\"\(description)\"}]"
                    }
                    return "[\"deposit\",{\"subwallet\":1,\"description\":\"\(description)\"}]"
                }
                return "[\"deposit\",{\"subwallet\":1}]"
            case .transactions(let until, let since):
                if let until {
                    return "[\"transactions\",{\"subwallet\":1,\"limit\":50, \"until\":\(until)}]"
                }
                if let since {
                    return "[\"transactions\",{\"subwallet\":1,\"limit\":50, \"since\":\(since)}]"
                }
                return "[\"transactions\",{\"subwallet\":1,\"limit\":50}]"
            case let .send(target, pubkey, amount, note, zap):
                guard
                    let zapJSON = zap?.toJSON(),
                    let zapData = try? JSONEncoder().encode(zapJSON),
                    let zapString = String(data: zapData, encoding: .utf8)
                else {
                    return """
                    ["withdraw",{"subwallet":1, "target_lud16":"\(target)", "target_pubkey":"\(pubkey)", "amount_btc":"\(amount)", "note_for_recipient":"\(note)", "note_for_self":"\(note)"}]
                    """.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                return """
                ["withdraw",{"subwallet":1, "target_lud16":"\(target)", "target_pubkey":"\(pubkey)", "amount_btc":"\(amount)", "note_for_recipient":"\(note)","note_for_self":"\(note)", "zap_request": \(zapString)}]
                """.trimmingCharacters(in: .whitespacesAndNewlines)
            case .inAppPurchase(let transactionId, let quote):
                return "[\"in_app_purchase\", {\"transaction_id\":\"\(transactionId)\", \"quote_id\": \"\(quote)\"}]"
            case .quote(let productId, let region):
                let additionalParameter = Bundle.main.appStoreReceiptURL?.absoluteString ?? ""
                return "[\"in_app_purchase_quote\", {\"product_id\": \"\(productId)\", \"region\": \"\(region)\", \"bundle_app_store_receipt_url\": \"\(additionalParameter)\"}]"
            case let .activationCode(name, email):
                return "[\"get_activation_code\", {\"name\": \"\(name)\", \"email\": \"\(email)\"}]"
            case let .activate(code):
                return "[\"activate\", {\"activation_code\": \"\(code)\"}]"
            }
      }
  }
  
  let type: RequestType
  
  private let pendingResult: WalletRequestResult = .init()
  
    func publisher() -> AnyPublisher<WalletRequestResult, Never> {
        Future { promise in
            Connection.instance.requestWallet(type.requestContent) { result in
                result.compactMap { $0.arrayValue?.last?.objectValue } .forEach { pendingResult.handleWalletEvent($0) }
                result.compactMap { $0.arrayValue?.last?.stringValue } .forEach { pendingResult.handleMessage($0) }
        
                promise(.success(pendingResult))
            }
        }.eraseToAnyPublisher()
    }
}

private extension WalletRequestResult {
    func handleMessage(_ message: String) {
        self.message = message
    }
  
    func handleWalletEvent(_ payload: [String: JSON]) {
        guard
            let kind = WalletResponseType(rawValue: Int(payload["kind"]?.doubleValue ?? -1337)),
            let contentString = payload["content"]?.stringValue
        else {
            if Int(payload["kind"]?.doubleValue ?? 0) == 10_000_113 {
            // Do nothing
            } else {
                print("UNKNOWN KIND")
            }
            return
        }
        
        switch kind {
        case .WALLET_OPERATION:
            print("UNHANDLED KIND: \(kind)")
        case .WALLET_BALANCE:
            guard let balance = try? JSONDecoder().decode(WalletBalance.self, from: Data(contentString.utf8)) else {
                print("Error decoding WALLET_BALANCE to json")
                return
            }
            
            self.balance = balance
        case .WALLET_DEPOSIT_INVOICE:
            guard let data = try? JSONDecoder().decode(InvoiceInfo.self, from: Data(contentString.utf8)) else {
                print("Error decoding: \(kind) to json")
                return
            }
            invoiceInfo = data
        case .WALLET_DEPOSIT_LNURL:
            print("UNHANDLED KIND: \(kind)")
            guard let data = try? JSONDecoder().decode(DepositInfo.self, from: Data(contentString.utf8)) else {
                print("Error decoding: \(kind) to json")
                return
            }
            depositInfo = data
        case .WALLET_TRANSACTIONS:
            guard let array = try? JSONDecoder().decode([WalletTransaction].self, from: Data(contentString.utf8))
            else {
                print("Error decoding: \(kind) to json")
                return
            }
            
            transactions = array
        case .WALLET_EXCHANGE_RATE:
            print("UNHANDLED KIND: \(kind)")
        case .WALLET_IS_USER:
            guard
                let number = Int(contentString),
                let kycLevel = KYCLevel(rawValue: number)
            else {
                print("Unable to handle WALLET_IS_USER")
                return
            }
            self.kycLevel = kycLevel
        case .WALLET_USER_INFO:
            print("UNHANDLED KIND: \(kind)")
        case .WALLET_IN_APP_PURCHASE_QUOTE:
            guard let quote = try? JSONDecoder().decode(WalletQuote.self, from: Data(contentString.utf8)) else {
                print("Unable to handle WALLET_QUOTE")
                return
            }
            self.quote = quote
        case .WALLET_ACTIVATION:
            guard let activation = try? JSONDecoder().decode(WalletActivation.self, from: Data(contentString.utf8)) else {
                print("Unable to handle WALLET_QUOTE")
                return
            }
            
            self.newAddress = activation.lud16
        case .WALLET_IN_APP_PURCHASE, .WALLET_ACTIVATION_CODE:
            return // NO ACTION
        }
    }
}
