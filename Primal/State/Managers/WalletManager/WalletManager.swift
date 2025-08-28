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
    
    var useUSD: Bool {
        get { bool(forKey: .useUSDKey) }
        set { setValue(newValue, forKey: .useUSDKey) }
    }
    
    var oldWalletAmount: [String: Int] {
        get { string(forKey: .oldWalletAmountKey)?.decode() ?? [:] }
        set { setValue(newValue.encodeToString(), forKey: .oldWalletAmountKey) }
    }
    
    var oldTransactions: [String: [CodableParsedTransaction]] {
        get { string(forKey: .oldTransactionsKey)?.decode() ?? [:] }
        set { setValue(newValue.encodeToString(), forKey: .oldTransactionsKey) }
    }
    
    var nwcSettings: [String: String] {
        get { string(forKey: .nwcSettingsKey)?.decode() ?? [:] }
        set { setValue(newValue.encodeToString(), forKey: .nwcSettingsKey) }
    }
    
    var useNwcWallet: [String: Bool] {
        get { string(forKey: .useNWCKey)?.decode() ?? [:] }
        set { setValue(newValue.encodeToString(), forKey: .useNWCKey) }
    }
}

private extension String {
    static let howManyZapsKey = "howManyZapsKey"
    static let oldWalletAmountKey = "oldWalletAmountKey"
    static let oldTransactionsKey = "oldTransactionsKey"
    static let minimumZapValueKey = "minimumZapValueKey"
    static let useUSDKey = "walletUseUSDKey"
    static let nwcSettingsKey = "nwcSettingsKey"
    static let useNWCKey = "useNWCKey"
}

struct CodableParsedTransaction: Codable {
    var transaction: WalletTransaction
    var user: CodableParsedUser
    
    func toTuple() -> (WalletTransaction, ParsedUser) { (transaction, user.parsed) }
}

enum WalletError: Error {
    case serverError(String)
    case inAppPurchaseServerError
    case noLud
    case noWallet
    case notSupported
    case signingError
    
    var message: String {
        switch self {
        case .signingError:
            return "Unable to sign events"
        case .notSupported:
            return "That action is not supported by NWC"
        case .noWallet:
            return "Your wallet is not set up properly, go to Settings > Wallet to set it up."
        case .noLud:
            return "This account doesn't have lud06 or lud16 set up."
        case .serverError(let message):
            return message
        case .inAppPurchaseServerError:
            return "We were not able to send sats to your wallet. Please contact us at support@primal.net and we will assist you."
        }
    }
}

struct PremiumState: Codable {
    var pubkey: String
    var tier: String
    var name:  String
    var nostr_address: String
    var lightning_address: String
    var primal_vip_profile: String
    var used_storage: Double
    var max_storage: Double
    var cohort_1: String
    var cohort_2: String
    var recurring: Bool
    var expires_on: Double?
    var renews_on: Double?
    var class_id: String?
    var donated_btc: String?
}

typealias ParsedTransaction = (WalletTransaction, ParsedUser)

protocol WalletImplementation {
    var balance: Int { get }
    var userHasWallet: Bool? { get }
    var maxBalance: Int { get }
    
    var balancePublisher: AnyPublisher<Int, Never> { get }
    var userHasWalletPublisher: AnyPublisher<Bool?, Never> { get }
    var isLoadingWalletPublisher: AnyPublisher<Bool, Never> { get }
    
    func sendLNInvoice(_ lninvoice: String, satsOverride: Int?, messageOverride: String?) async throws
    func sendLNURL(lnurl: String, pubkey: String?, sats: Int, note: String, zap: NostrObject?) async throws
    func sendLud16(_ lud: String, sats: Int, note: String, pubkey: String?, zap: NostrObject?) async throws
    func send(user: PrimalUser, sats: Int, note: String, zap: NostrObject?) async throws
    func sendOnchain(_ btcAddress: String, tier: String, sats: Int, note: String) async throws
    
    func loadMoreTransactions()
    func refreshBalance()
}

extension PrimalWalletManager: WalletImplementation {
    var isLoadingWalletPublisher: AnyPublisher<Bool, Never> { $isLoadingWallet.eraseToAnyPublisher() }
    var balancePublisher: AnyPublisher<Int, Never> { $balance.eraseToAnyPublisher() }
    var userHasWalletPublisher: AnyPublisher<Bool?, Never> { $userHasWallet.eraseToAnyPublisher() }
    var transactionsPublisher: AnyPublisher<[WalletTransaction], Never> { $transactions.eraseToAnyPublisher() }
}

final class WalletManager {
    static let instance = WalletManager()
    
    private(set) var impl: WalletImplementation
    
    var primal: PrimalWalletManager? { impl as? PrimalWalletManager }
    var nwc: NWCWalletManager? { impl as? NWCWalletManager }
    
    var cancellables = Set<AnyCancellable>()
    var updateCancellables = Set<AnyCancellable>()
    
    @Published var premiumState: PremiumState?
    @Published var didJustCreateWallet = false
    @Published var btcToUsd: Double = 44022
    @Published var isBitcoinPrimary = !UserDefaults.standard.useUSD {
        didSet {
            if oldValue != isBitcoinPrimary {
                UserDefaults.standard.useUSD = !isBitcoinPrimary
            }
        }
    }
    
    @Published var userHasWallet: Bool?
    @Published var isLoadingWallet = true
    @Published var balance: Int = 0
    
    var maxBalance: Int { impl.maxBalance }
    
    var hasPremium: Bool { premiumState?.isExpired == false }
    var hasLegend: Bool { premiumState?.isLegend == true }
    var hasPremiumPublisher: AnyPublisher<Bool, Never> {
        $premiumState.map { $0?.isExpired == false }.eraseToAnyPublisher()
    }
    
    let zapEvent = PassthroughSubject<ParsedZap, Never>()
    let animatingZap = CurrentValueSubject<ParsedZap?, Never>(nil)
    
    var userData: [String: ParsedUser] = [:]
    
    @Published var parsedTransactions: [ParsedTransaction] = []
    @Published private var userZapped: [String: Int] = [:]
    
    private init() {
        impl = DummyWalletImplementation()
        
        setupPublishers()
        
        DispatchQueue.main.async {
            self.loadNewExchangeRate()
        }
    }
    
    func reset(_ pubkey: String) {
        if UserDefaults.standard.useNwcWallet[pubkey] == true {
            if let nwcString = UserDefaults.standard.nwcSettings[pubkey] {
                impl = NWCWalletManager(url: nwcString) ?? DummyWalletImplementation()
            } else {
                impl = DummyWalletImplementation()
            }
            parsedTransactions = []
        } else {
            impl = PrimalWalletManager()
            let oldTransactions = (UserDefaults.standard.oldTransactions[pubkey] ?? []).map { $0.toTuple() }
            parsedTransactions = oldTransactions
        }

        updateCancellables = [
            impl.balancePublisher.assign(to: \.balance, onWeak: self),
            impl.userHasWalletPublisher.assign(to: \.userHasWallet, onWeak: self),
            impl.isLoadingWalletPublisher.assign(to: \.isLoadingWallet, onWeak: self)
        ]
        
        userZapped = [:]
        premiumState = nil
                
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.refreshPremiumState()
        }
    }
    
    func setUsePrimalWallet(_ usePrimal: Bool = true) {
        let pubkey = IdentityManager.instance.userHexPubkey
        UserDefaults.standard.useNwcWallet[pubkey] = !usePrimal
        reset(pubkey)
    }
    
    func setNWCWallet(nwcString: String) {
        let pubkey = IdentityManager.instance.userHexPubkey
        UserDefaults.standard.useNwcWallet[pubkey] = true
        UserDefaults.standard.nwcSettings[pubkey] = nwcString
        reset(pubkey)
    }
    
    func disconnectNWCWallet() {
        let pubkey = IdentityManager.instance.userHexPubkey
        UserDefaults.standard.nwcSettings[pubkey] = nil
        reset(pubkey)
    }
    
    func refresh() {
        // TODO: resolve refresh
        impl.refreshBalance()
        primal?.refreshTransactions()
    }
    
    func recheck() {
        // TODO: resolve recheck
        primal?.refreshBalance()
        primal?.recheckTransactions()
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
    
    func refreshPremiumState() {
        guard let event = NostrObject.create(content: "", kind: 30078) else { return }
        
        SocketRequest(name: "membership_status", payload: ["event_from_user": event.toJSON()], connection: .wallet)
            .publisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] res in
                guard
                    let state: PremiumState = res.events.first(where: { Int($0["kind"]?.doubleValue ?? 0) == NostrKind.premiumState.rawValue })?["content"]?.stringValue?.decode()
                else {
                    print("FAILED")
                    return
                }
                
                self?.premiumState = state
            }
            .store(in: &cancellables)
    }
    
    func loadNewExchangeRate() {
        PrimalWalletRequest(type: .exchangeRate).publisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] res in
                guard let price = res.bitcoinPrice else { return }
                self?.btcToUsd = price
            }
            .store(in: &cancellables)
    }
    
    func sendLNInvoice(_ lninvoice: String, satsOverride: Int?, messageOverride: String?) async throws {
        try await impl.sendLNInvoice(lninvoice, satsOverride: satsOverride, messageOverride: messageOverride)
    }
    
    func sendLNURL(lnurl: String, pubkey: String?, sats: Int, note: String, zap: NostrObject? = nil) async throws {
        try await impl.sendLNURL(lnurl: lnurl, pubkey: pubkey, sats: sats, note: note, zap: zap)
    }
    
    func sendLud16(_ lud: String, sats: Int, note: String, pubkey: String? = nil, zap: NostrObject? = nil) async throws {
        try await impl.sendLud16(lud, sats: sats, note: note, pubkey: pubkey, zap: zap)
    }
    
    func send(user: PrimalUser, sats: Int, note: String, zap: NostrObject? = nil) async throws {
        try await impl.send(user: user, sats: sats, note: note, zap: zap)
    }
    
    func sendOnchain(_ btcAddress: String, tier: String, sats: Int, note: String) async throws {
        try await impl.sendOnchain(btcAddress, tier: tier, sats: sats, note: note)
    }
    
    func zap(post: ParsedContent, sats: Int, note: String) async throws {
        do {
            zapEvent.send(.init(receiptId: UUID().uuidString, postId: post.post.id, amountSats: sats, message: note, createdAt: Date().timeIntervalSince1970, user: IdentityManager.instance.parsedUserSafe))
            addZap(post.post.id, amount: sats)
            try await send(user: post.user.data, sats: sats, note: note, zap: NostrObject.zapWallet(note, sats: sats, reference: post))
        } catch {
            removeZap(post.post.id, amount: sats)
            throw error
        }
    }
    
    func zap(object: ZappableReferenceObject, sats: Int, note: String) async throws {
        do {
            if let universalID = object.reference?.universalID {
                zapEvent.send(.init(receiptId: UUID().uuidString, postId: universalID, amountSats: sats, message: note, createdAt: Date().timeIntervalSince1970, user: IdentityManager.instance.parsedUserSafe))
                addZap(universalID, amount: sats)
            }
            try await send(user: object.userToZap.data, sats: sats, note: note, zap: NostrObject.zapWallet(note, sats: sats, reference: object))
        }
    }
}

private extension WalletManager {
    func setupPublishers() {
        // Necessary to getLoginInfo so that userPubkey is properly set
        _ = ICloudKeychainManager.instance.getLoginInfo()
        let pubkeyPublisher = ICloudKeychainManager.instance.$userPubkey.removeDuplicates()
        let onlyPubkey = pubkeyPublisher.filter({ !$0.isEmpty })
        
        let complexPublisher = Publishers.Merge(pubkeyPublisher.first(), onlyPubkey.debounce(for: 1, scheduler: RunLoop.main)).removeDuplicates()
        
        complexPublisher
            .sink(receiveValue: { [weak self] pubkey in
                self?.reset(pubkey)
            })
            .store(in: &cancellables)
        
        // Whatever is in zapEvent is also the animatingZap
        zapEvent.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] zap in self?.animatingZap.send(zap) })
            .store(in: &cancellables)
        
        // Clear animating zap
        animatingZap.debounce(for: 1, scheduler: RunLoop.main).sink { [weak self] zap in
            if zap == nil { return }
            self?.animatingZap.send(nil)
        }
        .store(in: &cancellables)
    }
}

class DummyWalletImplementation: WalletImplementation {
    
    var balance: Int = 0
    
    var userHasWallet: Bool? = false
    
    var maxBalance: Int = 0
    
    var transactions: [WalletTransaction] = []
    
    var balancePublisher: AnyPublisher<Int, Never> { Just(0).eraseToAnyPublisher() }
    
    var userHasWalletPublisher: AnyPublisher<Bool?, Never> { Just(false).eraseToAnyPublisher() }
    
    var isLoadingWalletPublisher: AnyPublisher<Bool, Never> { Just(false).eraseToAnyPublisher() }
    
    var transactionsPublisher: AnyPublisher<[WalletTransaction], Never> { Just([]).eraseToAnyPublisher() }
    
    func sendLNInvoice(_ lninvoice: String, satsOverride: Int?, messageOverride: String?) async throws {
        throw WalletError.noWallet
    }
    
    func sendLNURL(lnurl: String, pubkey: String?, sats: Int, note: String, zap: NostrObject?) async throws {
        throw WalletError.noWallet
    }
    
    func sendLud16(_ lud: String, sats: Int, note: String, pubkey: String?, zap: NostrObject?) async throws {
        throw WalletError.noWallet
    }
    
    func send(user: PrimalUser, sats: Int, note: String, zap: NostrObject?) async throws {
        throw WalletError.noWallet
    }
    
    func sendOnchain(_ btcAddress: String, tier: String, sats: Int, note: String) async throws {
        throw WalletError.noWallet
    }
    
    func loadMoreTransactions() {
        
    }
    
    func refreshBalance() {
        
    }
}
