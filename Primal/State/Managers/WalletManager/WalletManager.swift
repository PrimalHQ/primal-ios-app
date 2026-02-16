//
//  WalletManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.10.23..
//

import Combine
import GenericJSON
import Foundation
import PrimalShared

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
    
    var nwcSettings: [String: String] {
        get { string(forKey: .nwcSettingsKey)?.decode() ?? [:] }
        set { setValue(newValue.encodeToString(), forKey: .nwcSettingsKey) }
    }
    
    var useNwcWallet: [String: Bool] {
        get { string(forKey: .useNWCKey)?.decode() ?? [:] }
        set { setValue(newValue.encodeToString(), forKey: .useNWCKey) }
    }
    
    var btcToUsd: Double {
        get {
            let double = double(forKey: .btcExchangeRateKey)
            
            if double < 1 {
                return 90000
            }
            
            return double
        }
        set { set(newValue, forKey: .btcExchangeRateKey) }
    }
}

extension String {
    static let howManyZapsKey = "howManyZapsKey"
    static let oldWalletAmountKey = "oldWalletAmountKey"
    static let oldTransactionsKey = "oldTransactionsKey"
    static let minimumZapValueKey = "minimumZapValueKey"
    static let useUSDKey = "walletUseUSDKey"
    static let nwcSettingsKey = "nwcSettingsKey"
    static let useNWCKey = "useNWCKey"
    static let btcExchangeRateKey = "btcExchangeRateKey"
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
            return message.count < 100 ? message : "There has been an error."
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
    func sendLNURL(lnurl: String, pubkey: String?, sats: Int, note: String) async throws
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
    
//    private(set) var impl: WalletImplementation
    
//    var primal: PrimalWalletManager? { impl as? PrimalWalletManager }
//    var nwc: NWCWalletManager? { impl as? NWCWalletManager }
    
    var cancellables = Set<AnyCancellable>()
    var updateCancellables = Set<AnyCancellable>()
    
    var isNWCWalletActive: Bool { activeWallet is Wallet.NWC }
    
    @Published var premiumState: PremiumState?
    @Published var didJustCreateWallet = false
    @Published var btcToUsd: Double = UserDefaults.standard.btcToUsd
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
    
    var maxBalance: Int { Int((activeWallet?.maxBalanceInBtc?.doubleValue ?? 0.00001) * .BTC_TO_SAT) }
    
    var hasPremium: Bool { premiumState?.isExpired == false }
    var hasLegend: Bool { premiumState?.isLegend == true }
    var hasPremiumPublisher: AnyPublisher<Bool, Never> {
        $premiumState.map { $0?.isExpired == false }.eraseToAnyPublisher()
    }
    
    let zapEvent = PassthroughSubject<ParsedZap, Never>()
    let animatingZap = CurrentValueSubject<ParsedZap?, Never>(nil)
    
    var userData: [String: ParsedUser] = [:]
    
    @Published var parsedTransactions: [PrimalShared.Transaction] = []
    @Published private var userZapped: [String: Int] = [:]
    
    let zapFactory: any NostrZapperFactory
    let walletRepo: any WalletRepository
    
    let regConnection = PrimalApiClientFactory.shared.create(serverType: .caching)
    let walletConnection = PrimalApiClientFactory.shared.create(serverType: .wallet)
    let walletAccountRepo = WalletRepositoryFactory.shared.createWalletAccountRepository()
    
    let profileRepo: ProfileRepository
    lazy var primalWalletRepo = WalletRepositoryFactory.shared.createPrimalWalletAccountRepository(primalWalletApiClient: walletConnection, nostrEventSignatureHandler: SigningManager.instance)
    lazy var sparkWalletManager = WalletRepositoryFactory.shared.createSparkWalletManager()
    lazy var sparkWalletAccountRepository = WalletRepositoryFactory.shared.createSparkWalletAccountRepository(primalWalletApiClient: walletConnection, nostrEventSignatureHandler: SigningManager.instance)
    
    lazy var nwcRepo = WalletRepositoryFactory.shared.createNwcRepository(nip47EventsHandler: self)
    
    var walletID: String? { activeWallet?.walletId }
    @Published var activeWallet: Wallet?
    
    private init() {
        let eventRepo = PrimalRepositoryFactory.shared.createEventRepository(cachingPrimalApiClient: regConnection, mediaCacher: MediaCacher.instance)
        
        profileRepo = PrimalRepositoryFactory.shared.createProfileRepository(cachingPrimalApiClient: regConnection, primalPublisher: SigningManager.instance, mediaCacher: MediaCacher.instance)
        
        // WalletRepo wallet info by id (balance, transactions, etc.)
        walletRepo = WalletRepositoryFactory.shared.createWalletRepository(
            primalWalletApiClient: walletConnection,
            nostrEventSignatureHandler: SigningManager.instance,
            profileRepository: profileRepo,
            eventRepository: eventRepo
        )
        
        zapFactory = NostrZapperFactoryProvider.shared.createNostrZapperFactory(walletRepository: walletRepo, nostrEventSignatureHandler: SigningManager.instance, primalWalletApiClient: walletConnection)
        
        setupPublishers()
        
        DispatchQueue.main.async {
            self.loadNewExchangeRate()
        }
    }
    
    func reset(_ pubkey: String) {
        // TODO: sparkWalletManager.disconnectWallet(walletId: ) stari wallet
        
        userZapped = [:]
        premiumState = nil
        activeWallet = nil
        updateCancellables = []
        isLoadingWallet = false
        userHasWallet = true
        
        walletAccountRepo.observeActiveWallet(userId: pubkey)
            .toPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] wallet in
                guard let self, let wallet else { return }
                activeWallet = wallet
                balance = Int((wallet.balanceInBtc?.doubleValue ?? 0) * Double(SAT_PER_BTC))
                isLoadingWallet = false
                userHasWallet = (wallet as? Wallet.Primal)?.kycLevel ?? .email == .email
            }
            .store(in: &updateCancellables)
        
        let nwcService = WalletRepositoryFactory.shared.createNwcService(walletRepository: walletRepo, nostrEncryptionService: EncryptionServiceHandler.instance, nwcRepository: nwcRepo)
        
        
        Task {
            let wallet = try await walletAccountRepo.getActiveWallet(userId: pubkey)
            guard wallet == nil else {
                if wallet is Wallet.Spark {
                    let newResult = try await EnsureSparkWalletExistsUseCase(sparkWalletManager: sparkWalletManager, sparkWalletAccountRepository: sparkWalletAccountRepository, walletAccountRepository: walletAccountRepo, seedPhraseGenerator: RecoveryPhraseGenerator())
                        .invoke(userId: pubkey, register: false)
                }
                return
            }
            
            
            let result = try await EnsurePrimalWalletExistsUseCase(primalWalletAccountRepository: primalWalletRepo, walletAccountRepository: walletAccountRepo)
                .invoke(userId: pubkey, setAsActive: true).getOrNull()
            
            let newWallet = try await walletAccountRepo.getActiveWallet(userId: pubkey)
            
            guard newWallet == nil else { return }
            
            let newResult = try await EnsureSparkWalletExistsUseCase(sparkWalletManager: sparkWalletManager, sparkWalletAccountRepository: sparkWalletAccountRepository, walletAccountRepository: walletAccountRepo, seedPhraseGenerator: RecoveryPhraseGenerator())
                .invoke(userId: pubkey, register: true)
            
//            guard let sparkWallet = try await walletAccountRepo.findLastUsedWallet(userId: pubkey, type: .spark) else { return }
//            try await walletAccountRepo.setActiveWallet(userId: pubkey, walletId: sparkWallet.walletId)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.refreshPremiumState()
            self.refresh()
        }
    }
    
    func newWalletSpark(_ pubkey: String) {
        let ensureSpark = EnsureSparkWalletExistsUseCase(sparkWalletManager: sparkWalletManager, sparkWalletAccountRepository: sparkWalletAccountRepository, walletAccountRepository: walletAccountRepo, seedPhraseGenerator: RecoveryPhraseGenerator())
        
        Task {
            let invokeSpark = try await ensureSpark.invoke(userId: pubkey, register: true)
        }
    }
    
    func seedPhrase() async throws -> [String] {
        guard let walletID else { return [] }

        let seed = try await sparkWalletAccountRepository.getPersistedSeedWords(walletId: walletID).getOrNull()
        
        return seed?.compactMap { $0 as? String } ?? []
    }
    
    func markWalletAsBackedUp() {
        guard let walletID else { return }

        Task {
            try await sparkWalletAccountRepository.markWalletAsBackedUp(walletId: walletID)
        }
    }
    
    func setUsePrimalWallet(_ usePrimal: Bool = true) async throws {
        let userPubkey = IdentityManager.instance.userHexPubkey
        if usePrimal {
            let primal = try await walletAccountRepo.findLastUsedWallet(userId: userPubkey, type: [WalletType.primal, WalletType.spark])
            if let primal {
                try await walletAccountRepo.setActiveWallet(userId: userPubkey, walletId: primal.walletId)
            }
        } else if let nwc = try await walletAccountRepo.findLastUsedWallet(userId: userPubkey, type: .nwc) {
            try await walletAccountRepo.setActiveWallet(userId: userPubkey, walletId: nwc.walletId)
        }
    }
    
    func setNWCWallet(nwcString: String) async throws {
        let pubkey = IdentityManager.instance.userHexPubkey
        
        let res = try await ConnectNwcUseCase(walletRepository: walletRepo, walletAccountRepository: walletAccountRepo).invoke(userId: pubkey, nwcUrl: nwcString, autoSetAsDefaultWallet: true)
    }
    
    func disconnectNWCWallet() async throws {
        let pubkey = IdentityManager.instance.userHexPubkey
        
        guard let nwc = try await walletAccountRepo.findLastUsedWallet(userId: pubkey, type: .nwc) else { return }
        
        try await walletRepo.deleteWalletById(walletId: nwc.walletId)
        
        try await setUsePrimalWallet()
    }
    
    func createLightningInvoice(amountInBtc: String?, comment: String?) async throws -> String? {
        guard let walletID else { return activeWallet?.lightningAddress }
        
        let invoiceResult = try await WalletManager.instance.walletRepo.createLightningInvoice(walletId: walletID, amountInBtc: amountInBtc, comment: comment, expiry: nil)
        
        return invoiceResult.getOrNull()?.invoice ?? activeWallet?.lightningAddress
    }
    
    func createOnchainInvoice() async throws -> String? {
        guard let walletID else { return nil }
        
        return try await WalletManager.instance.walletRepo.createOnChainAddress(walletId: walletID).getOrNull()?.address
    }
    
    func refresh() {
        guard let walletID else { return }
        
        let flow = walletRepo.latestTransactions(walletId: walletID)
        let snapshot = IosWalletPagingFactory.shared.createTransactionSnapshot(pagingFlow: flow)
        
        Task { @MainActor in
            _ = try await self.walletRepo.fetchWalletBalance(walletId: walletID)
            
            for await items in snapshot.items where !items.isEmpty{
                print("Got \(items.count) transactions")
                
                self.parsedTransactions = items
                
                snapshot.dispose()
                // Dismiss this snapshot so that it is not constantly updating forever
                break
            }
        }
    }
    
    func recheck() {
        // TODO: resolve recheck
//        primal?.refreshBalance()
//        primal?.recheckTransactions()
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
                UserDefaults.standard.btcToUsd = price
            }
            .store(in: &cancellables)
    }
    
    
    // COPIED FROM NWC
    func sendInvoice(_ address: String, satsOverride: Int?, messageOverride: String?) async throws {
        throw WalletError.notSupported
    }
    
    func zapUser(_ user: PrimalUser, sats: Int, note: String, zap: NostrObject) async throws {
        guard let address = user.decodedLNURL else { throw WalletError.noLud }
        guard let walletID else { throw WalletError.noWallet }
        
        let data = ZapRequestData(
            zapperUserId: IdentityManager.instance.userHexPubkey,
            recipientUserId: user.pubkey,
            recipientLnUrlDecoded: address,
            zapAmountInSats: UInt64(sats),
            zapComment: note,
            userZapRequestEvent: .init(id: zap.id, pubKey: zap.pubkey, createdAt: zap.created_at, kind: Int32(zap.kind), tags: NostrExtensions.shared.mapAsListOfJsonArray(tags: zap.tags), content: zap.content, sig: zap.sig)
        )

        let zapper = try await zapFactory.createOrNull(walletId: walletID)
        let res = try await zapper?.zap(walletId: walletID, data: data)
        
        if let error = res as? ZapResult.Failure {
            print(error.description())
        }
    }
    
    func sendLNInvoice(_ lninvoice: String, satsOverride: Int?, messageOverride: String?) async throws {
        guard let walletID else { throw WalletError.noWallet }
        let res = try await walletRepo.pay(walletId: walletID, request: .LightningLnInvoice(amountSats: String(satsOverride ?? 0), noteRecipient: messageOverride, noteSelf: messageOverride, idempotencyKey: UUID().uuidString, lnInvoice: lninvoice))
        print(res)
    }
    
    func sendLNURL(lnurl: String, pubkey: String?, sats: Int, note: String) async throws {
        guard let walletID else { throw WalletError.noWallet }
        let res = try await walletRepo.pay(walletId: walletID, request: .LightningLnUrl(amountSats: String(sats), noteRecipient: note, noteSelf: note, idempotencyKey: UUID().uuidString, lnUrl: lnurl, lud16: nil))
        print(res)
    }
    
    func sendLud16(_ lud: String, sats: Int, note: String, pubkey: String? = nil, zap: NostrObject? = nil) async throws {
        guard let walletID else { throw WalletError.noWallet }
        guard let decoded = lud.lud16ToDecodedLNURL else { throw WalletError.noLud }
        
        let res = try await walletRepo.pay(walletId: walletID, request: .LightningLnUrl(amountSats: String(sats), noteRecipient: note, noteSelf: note, idempotencyKey: UUID().uuidString, lnUrl: decoded, lud16: lud))
        print(res)
    }
    
    func send(user: PrimalUser, sats: Int, note: String, zap: NostrObject? = nil) async throws {
        if let zap {
            return try await zapUser(user, sats: sats, note: note, zap: zap)
        }
        
        var relays = Array((IdentityManager.instance.userRelays ?? [:]).keys)
        if relays.isEmpty {
            relays = bootstrap_relays
        }
        
        guard let zap = NostrObject.zap(target: .profile(user.pubkey), relays: relays) else { throw WalletError.signingError }
        
        try await zapUser(user, sats: sats, note: note, zap: zap)
    }
    
    func sendOnchain(_ btcAddress: String, tier: String, sats: Int, note: String) async throws {
        guard let walletID else { throw WalletError.noWallet }

        let res = try await walletRepo.pay(walletId: walletID, request: .BitcoinOnChain(amountSats: String(sats), noteRecipient: note, noteSelf: note, idempotencyKey: UUID().uuidString, onChainAddress: btcAddress, onChainTierId: tier))
        print(res)
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

extension WalletManager {
    
    
    func restoreWalletFromSeed(_ phrase: String) {
        Task {
            try await RestoreSparkWalletUseCase(
                sparkWalletManager: sparkWalletManager,
                walletAccountRepository: walletAccountRepo,
                sparkWalletAccountRepository: sparkWalletAccountRepository
            )
            .invoke(seedWords: phrase, userId: IdentityManager.instance.userHexPubkey)
        }
    }
    
    func migrateToSpark(_ callback: @escaping (WalletMigrationStep) -> Void) {
        let pubkey = IdentityManager.instance.userHexPubkey
        let migrationHandler = WalletRepositoryFactory.shared.createMigratePrimalToSparkWalletHandler(
            primalWalletApiClient: walletConnection,
            nostrEventSignatureHandler: SigningManager.instance,
            ensureSparkWalletExistsUseCase: EnsureSparkWalletExistsUseCase(
                sparkWalletManager: sparkWalletManager,
                sparkWalletAccountRepository: sparkWalletAccountRepository,
                walletAccountRepository: walletAccountRepo,
                seedPhraseGenerator: RecoveryPhraseGenerator()
            ),
            walletRepository: walletRepo,
            profileRepository: profileRepo
        )
        
        Task {
            try await migrationHandler.invoke(userId: IdentityManager.instance.userHexPubkey, onProgress: { prog in
                let step: WalletMigrationStep = {
                    if let inProgress = prog as? MigrationProgress.InProgress {
                        return .inProgress(MigrationStepName(rawValue: inProgress.step.name)?.userFriendlyDescription ?? inProgress.step.name)
                    }
                    if let failed = prog as? MigrationProgress.Failed {
                        return .failed(failed.logs.joined(separator: "\n"))
                    }
                    if let completed = prog as? MigrationProgress.Completed {
                        return .completed
                    }
                    return .inProgress("Starting migration...")
                }()
                
                DispatchQueue.main.async {
                    callback(step)
                }
            })
        }
    }
}

enum MigrationStepName: String {
      case creatingWallet = "CREATING_WALLET"
      case registeringWallet = "REGISTERING_WALLET"
      case checkingBalance = "CHECKING_BALANCE"
      case creatingInvoice = "CREATING_INVOICE"
      case transferringFunds = "TRANSFERRING_FUNDS"
      case awaitingConfirmation = "AWAITING_CONFIRMATION"
      case configuringWallet = "CONFIGURING_WALLET"
      case importingHistory = "IMPORTING_HISTORY"
      case activatingWallet = "ACTIVATING_WALLET"

      var userFriendlyDescription: String {
          switch self {
          case .creatingWallet:       return "Creating your new wallet…"
          case .registeringWallet:    return "Registering wallet…"
          case .checkingBalance:      return "Checking your balance…"
          case .creatingInvoice:      return "Preparing transfer…"
          case .transferringFunds:    return "Transferring your funds…"
          case .awaitingConfirmation: return "Awaiting confirmation…"
          case .configuringWallet:    return "Configuring wallet…"
          case .importingHistory:     return "Importing transaction history…"
          case .activatingWallet:     return "Activating wallet…"
          }
      }
  }


enum WalletMigrationStep {
    case inProgress(String)
    case failed(String)
    case completed
}

private extension WalletManager {
    func setupPublishers() {
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
    
    func sendLNURL(lnurl: String, pubkey: String?, sats: Int, note: String) async throws {
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

extension WalletManager: Nip47EventsHandler {
    func __fetchNip47Events(eventIds: [String], completionHandler: @escaping @Sendable (UtilsResult<NSArray>?, (any Error)?) -> Void) {
        // TODO: fetch
        completionHandler(nil, nil)
    }
}
