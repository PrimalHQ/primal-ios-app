//
//  PrimalWalletRequest.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.10.23..
//

import Combine
import GenericJSON
import Foundation

struct AdditionalDepositInfo {
    var satoshi: Int
    var description: String
}

struct PrimalWalletRequest {
    enum RequestType {
        case isUser
        case balance
        case transactions(until: Int? = nil, since: Int? = nil)
        case send(target: String, amount: String, note: String)
        case deposit(AdditionalDepositInfo? = nil)
        
        var requestContent: String {
            switch self {
            case .isUser:
                return "[\"is_user\",{\"pubkey\":\"\(IdentityManager.instance.userHexPubkey)\"}]"
            case .balance:
                return "[\"balance\",{\"subwallet\":1}]"
            case .deposit(let info):
                if let info {
                    if info.satoshi > 0 {
                        return "[\"deposit\",{\"subwallet\":1,\"amount_btc\":\"\(info.satoshi.satsToBitcoinString())\",\"description\":\"\(info.description)\"}]"
                    }
                    return "[\"deposit\",{\"subwallet\":1,\"description\":\"\(info.description)\"}]"
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
            case let .send(target, amount, note):
                return """
                ["withdraw",{"subwallet":1, "target_lud16":"\(target)","amount_btc":"\(amount)","note_for_recipient":"\(note)","note_for_self":""}]
                """
            }
        }
    }
    
    let type: RequestType
    
    private let pendingResult: WalletRequestResult = .init()
    
    func publisher() -> AnyPublisher<WalletRequestResult, Never> {
        Future { promise in
            Connection.instance.requestWallet(type.requestContent) { result in
                result.compactMap { $0.arrayValue?.last?.objectValue } .forEach { handleWalletEvent($0) }
                result.compactMap { $0.arrayValue?.last?.stringValue } .forEach { handleMessage($0) }
                
                promise(.success(pendingResult))
            }
        }.eraseToAnyPublisher()
    }
}

private extension PrimalWalletRequest {
    func handleMessage(_ message: String) {
        pendingResult.message = message
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

            pendingResult.balance = balance
        case .WALLET_DEPOSIT_INVOICE:
            guard let data = try? JSONDecoder().decode(InvoiceInfo.self, from: Data(contentString.utf8)) else {
                print("1Error decoding: \(kind) to json")
                return
            }
            pendingResult.invoiceInfo = data
        case .WALLET_DEPOSIT_LNURL:
            print("UNHANDLED KIND: \(kind)")
            guard let data = try? JSONDecoder().decode(DepositInfo.self, from: Data(contentString.utf8)) else {
                print("1Error decoding: \(kind) to json")
                return
            }
            pendingResult.depositInfo = data
        case .WALLET_TRANSACTIONS:
//            let array = try! JSONDecoder().decode([WalletTransaction].self, from: Data(contentString.utf8))
            guard let array = try? JSONDecoder().decode([WalletTransaction].self, from: Data(contentString.utf8))
            else {
                print("1Error decoding: \(kind) to json")
                return
            }
            
            pendingResult.transactions = array
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
            pendingResult.kycLevel = kycLevel
        case .WALLET_USER_INFO:
            print("UNHANDLED KIND: \(kind)")
        }
    }
}
