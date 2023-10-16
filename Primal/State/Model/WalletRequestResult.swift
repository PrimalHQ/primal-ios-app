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
    /*
         - key : "zap_request"
         ▿ value : "{\"id\":\"f6ceb54ca7f3518a98a76b8f7e4df5ca2286c14f35b79703140db4c839d7344e\",\"pubkey\":\"c70735fa4b01f77f953883a6e671982e31bd7d906b2b6111a6f518555bed1b1a\",\"created_at\":1696847402,\"kind\":9734,\"tags\":[[\"p\",\"88cc134b1a65f54ef48acc1df3665063d3ea45f04eab8af4646e561c5ae99079\"],[\"e\",\"6c1658c571d56acc867c9e7763333bf48c44621e980ca246d04a8b3bf2b887f4\"],[\"relays\",\"wss://relay.primal.net\",\"wss://relay.current.fyi\",\"wss://nostr21.com\",\"wss://nostr.oxtr.dev\"]],\"content\":\"Spread the love. Zap love@current.tips\",\"sig\":\"62bd3774709054ed19f3b606a10c16028f91ac5d979d4dbbc2000c603bff3cbab66303089427fb145254aa2e615157645f8673b7b1215e1788ec267a2e7fead5\"}"
           - string : "{\"id\":\"f6ceb54ca7f3518a98a76b8f7e4df5ca2286c14f35b79703140db4c839d7344e\",\"pubkey\":\"c70735fa4b01f77f953883a6e671982e31bd7d906b2b6111a6f518555bed1b1a\",\"created_at\":1696847402,\"kind\":9734,\"tags\":[[\"p\",\"88cc134b1a65f54ef48acc1df3665063d3ea45f04eab8af4646e561c5ae99079\"],[\"e\",\"6c1658c571d56acc867c9e7763333bf48c44621e980ca246d04a8b3bf2b887f4\"],[\"relays\",\"wss://relay.primal.net\",\"wss://relay.current.fyi\",\"wss://nostr21.com\",\"wss://nostr.oxtr.dev\"]],\"content\":\"Spread the love. Zap love@current.tips\",\"sig\":\"62bd3774709054ed19f3b606a10c16028f91ac5d979d4dbbc2000c603bff3cbab66303089427fb145254aa2e615157645f8673b7b1215e1788ec267a2e7fead5\"}"
       ▿ 5 : 2 elements
     */
}
