//
//  WalletManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.10.23..
//

import Combine
import GenericJSON
import Foundation

extension UserDefaults {
    var howManyZaps: Int { // Tracks how many zaps happened
        get { integer(forKey: .howManyZapsKey) }
        set { setValue(newValue, forKey: .howManyZapsKey) }
    }
    
    var minimumZapValue: Int { // Minimum zap value to show
        get { max(1, integer(forKey: .minimumZapValueKey)) }
        set { setValue(newValue, forKey: .minimumZapValueKey) }
    }
    
    var minimumNotificationValue: Int {
        get { max(minimumZapValue, integer(forKey: .minimumNotificationValueKey)) }
        set { setValue(newValue, forKey: .minimumNotificationValueKey)}
    }
}

private extension String {
    static let howManyZapsKey = "howManyZapsKey"
    static let oldWalletAmountKey = "oldWalletAmountKey"
    static let oldTransactionsKey = "oldTransactionsKey"
    static let minimumZapValueKey = "minimumZapValueKey"
    static let minimumNotificationValueKey = "minimumNotificationValueKey"
}

struct CodableParsedTransaction: Codable {
    var transaction: WalletTransaction
    var user: CodableParsedUser
    
    func toTuple() -> (WalletTransaction, ParsedUser) { (transaction, user.parsed) }
}

private extension UserDefaults {
    var oldWalletAmount: [String: Int] {
        get { string(forKey: .oldWalletAmountKey)?.decode() ?? [:] }
        set { setValue(newValue.encodeToString(), forKey: .oldWalletAmountKey) }
    }
    
    var oldTransactions: [String: [CodableParsedTransaction]] {
        get { string(forKey: .oldTransactionsKey)?.decode() ?? [:] }
        set { setValue(newValue.encodeToString(), forKey: .oldTransactionsKey) }
    }
}

enum WalletError: Error {
    case serverError(String)
    case inAppPurchaseServerError
    case noLud
    
    var message: String {
        switch self {
        case .noLud:
            return "Your account doesn't have lud6 or lud16 set up."
        case .serverError(let message):
            return message
        case .inAppPurchaseServerError:
            return "We were not able to send sats to your wallet. Please contact us at support@primal.net and we will assist you."
        }
    }
}

typealias ParsedTransaction = (WalletTransaction, ParsedUser)

final class WalletManager {
    static let instance = WalletManager()
    
    var cancellables = Set<AnyCancellable>()
    @Published var userHasWallet: Bool?
    @Published var updatedAt: Double?
    @Published var balance: Int = 0
    @Published var maxBalance: Int = 0
    @Published var transactions: [WalletTransaction] = []
    @Published var isLoadingWallet = true
    @Published var didJustCreateWallet = false
    @Published private var userZapped: [String: Int] = [:]
    @Published var btcToUsd: Double = 44022
    
    private var update: ContinousConnection?
    
    var userData: [String: ParsedUser] = [:]
    
    @Published var parsedTransactions: [ParsedTransaction] = []
    
    private var isLoadingTransactions = false
    
    private init() {
        setupPublishers()
        
        DispatchQueue.main.async {
            self.loadNewExchangeRate()
        }
    }
    
    func reset(_ pubkey: String) {
        parsedTransactions = []     // Required because of the notification code, otherwise a notification would show when switching accounts
        
        let oldBalance = UserDefaults.standard.oldWalletAmount[pubkey] ?? 0
        balance = oldBalance
        userHasWallet = oldBalance > 0 ? true : nil
        
        let oldTransactions = (UserDefaults.standard.oldTransactions[pubkey] ?? []).map { $0.toTuple() }
        transactions = oldTransactions.map { $0.0 }
        parsedTransactions = oldTransactions
        userZapped = [:]
        isLoadingWallet = oldTransactions.isEmpty
    }
    
    func hasZapped(_ eventId: String) -> Bool { userZapped[eventId, default: 0] > 0 }
    
    func extraZapAmount(_ eventId: String) -> Int {
        let val = userZapped[eventId, default: 0]
        return val == 1 ? 0 : val
    }
    
    func setZapUnknown(_ eventId: String) {
        userZapped[eventId] = 1
    }
    
    func addZap(_ eventId: String, amount: Int) {
        userZapped[eventId, default: 0] += amount
    }
    
    func removeZap(_ eventId: String, amount: Int) {
        userZapped[eventId] = max(0, userZapped[eventId, default: 0] - amount)
    }
    
    func refreshTransactions() {
        isLoadingTransactions = true
        
        PrimalWalletRequest(type: .transactions()).publisher()
            .sink(receiveValue: { [weak self] val in
                guard let self else { return }
                self.transactions = val.transactions
                self.isLoadingTransactions = false
            })
            .store(in: &cancellables)
    }
    
    func recheckTransactions() {
        isLoadingTransactions = true
        
        PrimalWalletRequest(type: .transactions()).publisher()
            .sink(receiveValue: { [weak self] val in
                guard let self else { return }
                var transactions = self.transactions
                
                let old = val.transactions.filter { new in transactions.contains(where: { $0.id == new.id }) }
                let new = val.transactions.filter { new in
                    !transactions.contains(where: { $0.id == new.id }) && new.created_at > transactions.first?.created_at ?? 0
                }
                
                for transaction in old {
                    guard let index = transactions.firstIndex(where: { $0.id == transaction.id }) else { continue }
                    transactions[index] = transaction
                }
                
                transactions.insert(contentsOf: new, at: 0)
                
                self.transactions = transactions
                self.isLoadingTransactions = false
            })
            .store(in: &cancellables)
    }
    
    func refreshHasWallet() {
        PrimalWalletRequest(type: .isUser).publisher()
            .sink { [weak self] val in
                self?.isLoadingWallet = false
                self?.userHasWallet = val.kycLevel == KYCLevel.email || val.kycLevel == KYCLevel.idDocument
            }
            .store(in: &cancellables)
    }
    
    func refreshBalance() {
        PrimalWalletRequest(type: .balance).publisher()
            .sink(receiveValue: { [weak self] val in
                guard let balance = val.balance else { return }
                
                let doubleMax = (Double(balance.max_amount) ?? 0) * .BTC_TO_SAT
                self?.maxBalance = Int(doubleMax)
                    
                let double = (Double(balance.amount) ?? 0) * .BTC_TO_SAT
                self?.balance = Int(double)
                UserDefaults.standard.oldWalletAmount[ICloudKeychainManager.instance.userPubkey] = Int(double)
            })
            .store(in: &cancellables)
    }
    
    func loadNewTransactions() {
        PrimalWalletRequest(type: .transactions(since: transactions.first?.created_at)).publisher()
           .sink { [weak self] res in
               let trans = res.transactions.filter { new in self?.transactions.contains(where: { old in old.id == new.id }) != true }
               if !trans.isEmpty {
                   self?.transactions = trans + (self?.transactions ?? [])
               }
           }
           .store(in: &cancellables)
    }
    
    func loadNewExchangeRate() {
        PrimalWalletRequest(type: .exchangeRate).publisher()
            .sink { [weak self] res in
                guard let price = res.bitcoinPrice else { return }
                self?.btcToUsd = price
            }
            .store(in: &cancellables)
    }
    
    func loadMoreTransactions() {
        guard !isLoadingTransactions else { return }
        
        isLoadingTransactions = true
     
        PrimalWalletRequest(type: .transactions(until: transactions.last?.created_at)).publisher()
            .sink { [weak self] res in
                if !res.transactions.isEmpty {
                    self?.transactions += res.transactions
                    self?.isLoadingTransactions = false
                }
            }
            .store(in: &cancellables)
    }
    
    func requestAsync(_ request: PrimalWalletRequest.RequestType) async throws {
        return try await withCheckedThrowingContinuation({ continuation in
            PrimalWalletRequest(type: request).publisher()
                .sink { res in
                    if let errorMessage = res.message {
                        continuation.resume(throwing: WalletError.serverError(errorMessage))
                    } else {
                        continuation.resume()
                    }
                }
                .store(in: &cancellables)
        })
    }
    
    func sendLNInvoice(_ lninvoice: String, satsOverride: Int?, messageOverride: String?) async throws {
        try await requestAsync(.payInvoice(lnInvoice: lninvoice, amountOverride: satsOverride?.satsToBitcoinString(), noteOverride: messageOverride))
    }
    
    func sendLNURL(lnurl: String, pubkey: String?, sats: Int, note: String, zap: NostrObject? = nil) async throws {
        try await requestAsync(.send(.lnurl, target: lnurl, pubkey: pubkey, amount: sats.satsToBitcoinString(), note: note, zap: zap))
    }
    
    func sendLud16(_ lud: String, sats: Int, note: String, pubkey: String? = nil, zap: NostrObject? = nil) async throws {
        try await requestAsync(.send(.lud16, target: lud, pubkey: pubkey, amount: sats.satsToBitcoinString(), note: note, zap: zap))
    }
    
    func send(user: PrimalUser, sats: Int, note: String, zap: NostrObject? = nil) async throws {
        let lud16 = user.lud16
        if lud16.isEmpty {
            let lud06 = user.lud06
            
            if lud06.isEmpty { throw WalletError.noLud }
            
            return try await requestAsync(.send(.lud06, target: lud06, pubkey: user.pubkey, amount: sats.satsToBitcoinString(), note: note, zap: zap))
        }
            
        try await sendLud16(lud16, sats: sats, note: note, pubkey: user.pubkey, zap: zap)
    }
    
    func sendOnchain(_ btcAddress: String, tier: String, sats: Int, note: String) async throws {
        try await requestAsync(.send(.onchain(tier: tier), target: btcAddress, pubkey: nil, amount: sats.satsToBitcoinString(), note: note, zap: nil))
    }
    
    func zap(post: ParsedContent, sats: Int, note: String) async throws {
        do {
            addZap(post.post.id, amount: sats)
            try await send(user: post.user.data, sats: sats, note: note, zap: NostrObject.zapWallet(note, sats: sats, post: post))
        } catch {
            removeZap(post.post.id, amount: sats)
            throw error
        }
    }
}

private extension WalletManager {
    func setupPublishers() {
        let pubkeyPublisher = ICloudKeychainManager.instance.$userPubkey
            .removeDuplicates()
        let onlyPubkey = pubkeyPublisher.filter({ !$0.isEmpty })
        
        let complexPublisher = Publishers.Merge(pubkeyPublisher.first(), onlyPubkey.debounce(for: 1, scheduler: RunLoop.main)).removeDuplicates()
        
        complexPublisher
            .sink(receiveValue: { [weak self] pubkey in
                self?.reset(pubkey)
                self?.refreshHasWallet()
            })
            .store(in: &cancellables)
        
        $userHasWallet
            .filter { $0 == true }
            .flatMap { [weak self] _ in
                self?.isLoadingWallet = true
                return Publishers.Zip(
                    PrimalWalletRequest(type: .balance).publisher(),
                    PrimalWalletRequest(type: .transactions()).publisher()
                )
            }
            .sink(receiveValue: { [weak self] balanceRes, transactionsRes in
                self?.isLoadingWallet = false
                
                guard let string = balanceRes.balance?.amount else { return }
                
                let double = (Double(string) ?? 0) * .BTC_TO_SAT
                
                self?.transactions = transactionsRes.transactions
                self?.balance = Int(double)
            })
            .store(in: &cancellables)
        
        $updatedAt
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.refreshBalance()
                self?.recheckTransactions()
            }
            .store(in: &cancellables)
        
        $transactions
            .receive(on: DispatchQueue.main)
            .flatMap { [weak self] transactions in
                let flatPubkeys: [String] = transactions.flatMap { [$0.pubkey_1] + ($0.pubkey_2 == nil ? [] : [$0.pubkey_2!]) }
                
                var set = Set<String>()
                
                for pubkey in flatPubkeys {
                    if self?.userData[pubkey] == nil {
                        set.insert(pubkey)
                    }
                }
                
                if set.isEmpty {
                    return Just(PostRequestResult()).eraseToAnyPublisher()
                }
                
                return SocketRequest(name: "user_infos", payload: .object([
                    "pubkeys": .array(set.map { .string($0) })
                ])).publisher().eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }
                for (key, value) in result.users {
                    self.userData[key] = result.createParsedUser(value)
                }
                
                let parsed = self.transactions.map { (
                    $0,
                    self.userData[$0.pubkey_2 ?? $0.pubkey_1] ?? result.createParsedUser(.init(pubkey: $0.pubkey_2 ?? $0.pubkey_1))
                ) }
                
                self.parsedTransactions = parsed
                
                if !parsed.isEmpty {
                    UserDefaults.standard.oldTransactions[IdentityManager.instance.userHexPubkey] = parsed.prefix(10).map { .init(transaction: $0.0, user: .init($0.1)) }
                }
            }
            .store(in: &cancellables)
        
        $parsedTransactions.withPrevious()
            .compactMap { oldTransactions, newTransactions -> ParsedTransaction? in
                guard
                    let newTransaction = newTransactions.first,
                    let oldTransaction = oldTransactions.first,
                    // Only notify if there is a new transaction
                    newTransaction.0.id != oldTransaction.0.id,
                    // Only if it's a deposit
                    newTransaction.0.isDeposit,
                    let amountBTC = Double(newTransaction.0.amount_btc),
                    // Only if the amount is larger than minimumNotificationValue
                    amountBTC * .BTC_TO_SAT >= Double(UserDefaults.standard.minimumNotificationValue)
                else { return nil }
                
                return newTransaction
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] transaction in
                self?.notifyTransactionIfNecessary(transaction)
            }
            .store(in: &cancellables)

        Connection.wallet.$isConnected.removeDuplicates().filter { $0 }
            .sink { [weak self] _ in
                guard let event = NostrObject.wallet("{\"subwallet\":1}") else { return }
                
                let pubkey = event.pubkey
                
                self?.update = Connection.wallet.requestCacheContinous(name: "wallet_monitor_2", request: ["operation_event": event.toJSON()]) { result in
                    guard
                        pubkey == ICloudKeychainManager.instance.userPubkey,
                        let content = result.arrayValue?.last?.objectValue?["content"]?.stringValue,
                        let json: [String: JSON] = content.decode()
                    else { return }
                    
                    if let updatedAt = json["updated_at"]?.doubleValue {
                        self?.updatedAt = updatedAt
                    }
                    
                    if let amount = json["amount"]?.doubleValue {
                        let balance = Int(amount * .BTC_TO_SAT)
                        if self?.balance != balance {
                            UserDefaults.standard.oldWalletAmount[ICloudKeychainManager.instance.userPubkey] = balance
                            
                            self?.balance = balance
                            self?.updatedAt = Date().timeIntervalSince1970
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func notifyTransactionIfNecessary(_ transaction: ParsedTransaction) {
        guard
            let mainTab: MainTabBarController = RootViewController.instance.findInChildren(),
            mainTab.currentTab != .wallet || mainTab.wallet.viewControllers.count > 1
        else { return }
        
        RootViewController.instance.showNewTransaction(transaction)
    }
}
