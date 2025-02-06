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

struct PrimalWalletNewNWCResponse: Codable {
    let nwc_pubkey: String
    let uri: String
}

struct PrimalWalletNWCConnection: Codable, Hashable {
    let nwc_pubkey: String
    let appname: String
    let daily_budget_btc: String?
    let remaining_daily_budget_btc: String?
}

enum WalletTransactionNetwork: String {
    case lightning, onchain
}

struct PrimalWalletRequest {
    enum SendRequestType {
        case lnurl, lud16, lud06, onchain(tier: String)
    }
    
    enum RequestType {
        case isUser
        case balance
        case transactions(until: Int? = nil, since: Int? = nil)
        case send(SendRequestType, target: String, pubkey: String?, amount: String, note: String, zap: NostrObject?)
        case payInvoice(lnInvoice: String, amountOverride: String?, noteOverride: String?)
        case deposit(WalletTransactionNetwork, AdditionalDepositInfo? = nil)
        case inAppPurchase(transactionId: String, quote: String)
        case quote(productId: String, countryCode: String)
        case activationCode(firstName: String, lastName: String, email: String, date: Date, country: String, state: String?)
        case activate(code: String)
        case parseLNURL(String)
        case exchangeRate
        case onchainPaymentTiers(address: String, amount: String)
        case nwcConnections
        case nwcConnect(name: String, amount: Int?)
        case nwc_rewoke(String)
        
        var requestContent: String {
            switch self {
            case .isUser:
                return "[\"is_user\",{\"pubkey\":\"\(IdentityManager.instance.userHexPubkey)\"}]"
            case .balance:
                return "[\"balance\",{\"subwallet\":1}]"
            case .deposit(let network, let info):
                var dic: [String: JSON] = [
                    "subwallet": 1,
                    "network": .string(network.rawValue)
                ]
                
                if let info {
                    let description = info.description.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
                    dic["description"] = .string(description)
                    if info.satoshi > 0 {
                        let amount = info.satoshi.satsToBitcoinString()
                        dic["amount_btc"] = .string(amount)
                    }
                }
                
                return #"["deposit", \#(dic.encodeToString() ?? "{}")]"#
            case .transactions(let until, let since):
                var dic: [String: JSON] = [
                    "subwallet": 1,
                    "limit": 50,
                    "min_amount_btc": .string(UserDefaults.standard.minimumZapValue.satsToBitcoinString())
                ]
                
                if let until {
                    dic["until"] = .number(Double(until))
                } else if let since {
                    dic["since"] = .number(Double(since))
                }
                return #"["transactions", \#(dic.encodeToString() ?? "{}")]"#
            case let .payInvoice(lnInvoice, amountOverride, noteOverride):
                if let amountOverride {
                    return "[\"withdraw\", {\"subwallet\":1, \"lnInvoice\": \"\(lnInvoice)\", \"amount_btc\":\"\(amountOverride)\", \"note_for_self\":\"\(noteOverride ?? "")\"}]"
                }
                return "[\"withdraw\", {\"subwallet\":1, \"lnInvoice\": \"\(lnInvoice)\"}]"
            case let .send(type, target, pubkey, amount, note, zap):
                var dic: [String: JSON] = [
                    "subwallet": 1,
                    "amount_btc": .string(amount),
                    "note_for_recipient": .string(note),
                    "note_for_self": .string(note)
                ]
                
                switch type {
                case .onchain(let tier):
                    dic["target_bcaddr"] = .string(target)
                    dic["onchain_tier"] = .string(tier)
                case .lnurl, .lud06:
                    dic["target_lnurl"] = .string(target)
                case .lud16:
                    dic["target_lud16"] = .string(target)
                }
                
                if let pubkey {
                    dic["target_pubkey"] = .string(pubkey)
                }
                
                if let zapJSON = zap?.toJSON() {
                    dic["zap_request"] = zapJSON
                }
                
                return #"["withdraw", \#(dic.encodeToString() ?? "{}")]"#
            case .inAppPurchase(let transactionId, let quote):
                return "[\"in_app_purchase\", {\"transaction_id\":\"\(transactionId)\", \"quote_id\": \"\(quote)\"}]"
            case .quote(let productId, let region):
                let additionalParameter = Bundle.main.appStoreReceiptURL?.absoluteString ?? ""
                return "[\"in_app_purchase_quote\", {\"product_id\": \"\(productId)\", \"region\": \"\(region)\", \"bundle_app_store_receipt_url\": \"\(additionalParameter)\"}]"
            case let .activationCode(firstName, lastName, email, date, country, state):
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "YYYY-MM-dd"
                let dateString = dateFormatter.string(from: date)
                return #"["get_activation_code_2", {"user_details": {"first_name": "\#(firstName)", "last_name": "\#(lastName)", "email": "\#(email)", "date_of_birth": "\#(dateString)", "country": "\#(country)", "state": "\#(state ?? "")"}}]"#
            case let .activate(code):
                return "[\"activate\", {\"activation_code\": \"\(code)\"}]"
            case .parseLNURL(let lnurl):
                if lnurl.lowercased().hasPrefix("lnurl") {
                    return "[\"parse_lnurl\", {\"target_lnurl\": \"\(lnurl)\"}]"
                }
                return "[\"parse_lninvoice\", {\"lninvoice\": \"\(lnurl)\"}]"
            case .exchangeRate:
                return #"["exchange_rate", {}]"#
            case .onchainPaymentTiers(let address, let amount):
                return #"["onchain_payment_tiers", {"target_bcaddr": "\#(address)", "amount_btc": "\#(amount)"}]"#
            case .nwcConnections:
                return #"["nwc_connections", {}]"#
            case .nwc_rewoke(let key):
                return #"["nwc_revoke", { "nwc_pubkey": "\#(key)" }]"#
            case .nwcConnect(let name, let amount):
                let btcString: String
                if let amount {
                    btcString = #""\#(amount.satsToBitcoinString())""#
                } else {
                    btcString = "null"
                }
                return #"["nwc_connect", { "appname": "\#(name)", "daily_budget_btc": \#(btcString) }]"#
            }
      }
  }
  
  let type: RequestType
  
  private let pendingResult: WalletRequestResult = .init()
  
    func publisher() -> AnyPublisher<WalletRequestResult, Never> {
        Connection.wallet.autoConnectReset()
        
        return Deferred {
            Future { promise in
                Connection.wallet.requestWallet(type.requestContent) { result in
                    
                    if case .isUser = type {
                        print(result)
                    }
                    
                    result.compactMap { $0.objectValue } .forEach { pendingResult.handleWalletEvent($0) }
                    result.compactMap { $0.stringValue } .forEach { pendingResult.handleMessage($0) }
                    
                    promise(.success(pendingResult))
                }
            }
        }
        .waitForConnection(.wallet)
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
            balance = contentString.decode()
        case .WALLET_DEPOSIT_INVOICE:
            guard let data = try? JSONDecoder().decode(InvoiceInfo.self, from: Data(contentString.utf8)) else {
                print("Error decoding: \(kind) to json")
                return
            }
            invoiceInfo = data
        case .WALLET_DEPOSIT_LNURL:
            guard let data = try? JSONDecoder().decode(DepositInfo.self, from: Data(contentString.utf8)) else {
                print("Error decoding: \(kind) to json")
                return
            }
            depositInfo = data
        case .WALLET_TRANSACTIONS:
            transactions = contentString.decode() ?? transactions
        case .WALLET_EXCHANGE_RATE:
            guard let dic:[String:String] = contentString.decode(), let rateString = dic["rate"], let rate = Double(rateString) else {
                print("Error decoding: \(kind)")
                return
            }
            
            bitcoinPrice = rate
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
            
            newAddress = activation.lud16
        case .WALLET_PARSED_LNURL:
            guard let parsed = try? JSONDecoder().decode(ParsedLNURL.self, from: Data(contentString.utf8)) else {
                print("Unable to handle WALLET_PARSED_LNURL")
                return
            }
            parsedLNURL = parsed
        case .WALLET_PARSED_LNINVOICE:
            guard let parsed = try? JSONDecoder().decode(ParsedLNInvoice.self, from: Data(contentString.utf8)) else {
                print("Unable to handle WALLET_PARSED_LNINVOICE")
                return
            }
            parsedLNInvoice = parsed
        case .WALLET_PARSED_ONCHAIN:
            guard let parsed: [String: String] = contentString.decode() else {
                print("Unable to decode WALLET_PARSED_ONCHAIN")
                return
            }
            onchainAddress = parsed["onchainAddress"]
        case .WALLET_ONCHAIN_TIERS:
            guard let parsed: [OnchainTransactionTier] = contentString.decode() else {
                print("Unable to decode WALLET_ONCHAIN_TIERS")
                return
            }
            tiers = parsed
        case .WALLET_NEW_NWC:
            guard let json: PrimalWalletNewNWCResponse = contentString.decode() else {
                print("Unable to decode WALLET_NEW_NWC")
                return
            }
            newNWC = json
        case .WALLET_NWC:
            guard let json: [PrimalWalletNWCConnection] = contentString.decode() else {
                print("Unable to decode WALLET_NWC")
                return
            }
            nwcs = json
        case .WALLET_IN_APP_PURCHASE, .WALLET_ACTIVATION_CODE:
            return // NO ACTION
        }
    }
}
