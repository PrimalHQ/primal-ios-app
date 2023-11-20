//
//  WalletRequestResult.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.10.23..
//

import Foundation

class WalletRequestResult {
    var kycLevel: KYCLevel?
    var balance: WalletBalance?
    
    var message: String?
    
    var depositInfo: DepositInfo?
    var invoiceInfo: InvoiceInfo?
    
    var transactions: [WalletTransaction] = []
    
    var newAddress: String?
    var quote: WalletQuote?
    
    var parsedLNURL: ParsedLNURL?
    var parsedLNInvoice: ParsedLNInvoice?
}

enum WalletResponseType: Int {
    case WALLET_OPERATION = 10_000_300
    case WALLET_BALANCE = 10_000_301
    case WALLET_DEPOSIT_INVOICE = 10_000_302
    case WALLET_DEPOSIT_LNURL = 10_000_303
    case WALLET_TRANSACTIONS = 10_000_304
    case WALLET_EXCHANGE_RATE = 10_000_305
    case WALLET_IS_USER = 10_000_306
    case WALLET_USER_INFO = 10_000_307
    case WALLET_IN_APP_PURCHASE_QUOTE = 10_000_308
    case WALLET_IN_APP_PURCHASE = 10_000_309
    case WALLET_ACTIVATION_CODE = 10_000_310
    case WALLET_ACTIVATION = 10_000_311
    case WALLET_PARSED_LNURL = 10_000_312
    case WALLET_PARSED_LNINVOICE = 10_000_313
}

struct WalletQuote: Codable {
    let quote_id: String
    let apple_user_currency: String
    let apple_user_currency_amount: String
    let amount_btc: String
}

struct WalletActivation: Codable {
    let lud16: String
}

enum KYCLevel: Int {
    case none = 0
    case email = 1
    case idDocument = 2
}

struct WalletBalance: Codable {
    var amount: String
    var currency: String
}

struct ParsedLNURL: Codable {
    var min_sendable: String?
    var max_sendable: String?
    var description: String?
    var target_pubkey: String?
    var target_lud16: String?
}

struct ParsedLNInvoice: Codable {
    var lninvoice: Data
    var pubkey: String?
    
    struct Data: Codable {
        var amount_msat: Int
        var description: String?
    }
}

struct DepositInfo: Codable {
    var lnurl: String
    var lud16: String
}

struct InvoiceInfo: Codable {
    var lnInvoice: String
    var description: String?
}

struct WalletTransaction: Codable {    
    var type: String
    var id: String
    var state: String
    var completed_at: Int?
    var created_at: Int
    
    var is_zap: Bool
    
    var amount_btc: String
    var amount_usd: String?
    
    var note: String?
    
    var pubkey_1: String
    var pubkey_2: String?
    var subindex_1: String
    var subindex_2: String?
    var lud16_1: String?
    var lud16_2: String?
    
    var zap_request: String?
}
