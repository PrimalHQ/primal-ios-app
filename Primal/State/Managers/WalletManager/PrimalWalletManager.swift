//
//  PrimalWalletManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 27.5.25..
//

import Combine
import Foundation
import GenericJSON
import PrimalShared

class PrimalWalletManager {
    @Published var userHasWallet: Bool?
    @Published var updatedAt: Double?
    @Published var balance: Int = 0
    @Published var maxBalance: Int = 0
    @Published var transactions: [WalletTransaction] = []
    @Published var isLoadingWallet = true
    
    private var isLoadingTransactions = false
    private var update: ContinuousConnection?
    private var cancellables: Set<AnyCancellable> = []
    
    let zapFactory: any NostrZapperFactory
    let walletRepo: any WalletRepository
    
    var walletID: String?
    
    init() {
        
        let pubkey = IdentityManager.instance.userHexPubkey
        
        let oldBalance = UserDefaults.standard.oldWalletAmount[pubkey] ?? 0
        balance = oldBalance
        if oldBalance > 0 {
            userHasWallet = true
        }

        
        let regConnection = PrimalApiClientFactory.shared.create(serverType: .caching)
        let walletConnection = PrimalApiClientFactory.shared.create(serverType: .wallet)
        
        let repo = PrimalRepositoryFactory.shared.createProfileRepository(cachingPrimalApiClient: regConnection, primalPublisher: SigningManager.instance, mediaCacher: MediaCacher.instance)
        let eventRepo = PrimalRepositoryFactory.shared.createEventRepository(cachingPrimalApiClient: regConnection, mediaCacher: MediaCacher.instance)
        
        // WalletRepo wallet info by id (balance, transactions, etc.)
        walletRepo = WalletRepositoryFactory.shared.createWalletRepository(
            primalWalletApiClient: walletConnection,
            nostrEventSignatureHandler: SigningManager.instance,
            profileRepository: repo,
            eventRepository: eventRepo
        )
        
        zapFactory = NostrZapperFactoryProvider.shared.createNostrZapperFactory(walletRepository: walletRepo, nostrEventSignatureHandler: SigningManager.instance, primalWalletApiClient: walletConnection)
        
        
        // WalletAccountRepo
        let walletAccountRepo = WalletRepositoryFactory.shared.createWalletAccountRepository()
        
        let primalWallet = WalletRepositoryFactory.shared.createPrimalWalletAccountRepository(primalWalletApiClient: walletConnection, nostrEventSignatureHandler: SigningManager.instance)
        
        Task {
            guard let info = try await primalWallet.fetchWalletAccountInfo(userId: pubkey).getOrNull() else {
                return
            }
            
            self.walletID = info as String
            
            try await walletAccountRepo.setActiveWallet(userId: pubkey, walletId: info as String)
            
            guard let wallet = try await walletAccountRepo.getActiveWallet(userId: pubkey) else { return }
            
//            print(wallet.isActivePrimalWallet())
            print(wallet.balanceInBtc)
            
            print((wallet as? Wallet.Primal)?.kycLevel)
            
        }
        
        
        setupPublishers()
        refreshHasWallet()
    }
    
    func refreshTransactions() {
//        isLoadingTransactions = true
//        
//        PrimalWalletRequest(type: .transactions()).publisher()
//            .receive(on: DispatchQueue.main)
//            .sink(receiveValue: { [weak self] val in
//                guard let self else { return }
//                self.transactions = val.transactions
//                self.isLoadingTransactions = false
//            })
//            .store(in: &cancellables)
    }
    
    func recheckTransactions() {
//        isLoadingTransactions = true
//        
//        PrimalWalletRequest(type: .transactions()).publisher()
//            .receive(on: DispatchQueue.main)
//            .sink(receiveValue: { [weak self] val in
//                guard let self else { return }
//                var transactions = self.transactions
//                
//                let old = val.transactions.filter { new in transactions.contains(where: { $0.id == new.id }) }
//                let new = val.transactions.filter { new in
//                    !transactions.contains(where: { $0.id == new.id }) && new.created_at > transactions.first?.created_at ?? 0
//                }
//                
//                for transaction in old {
//                    guard let index = transactions.firstIndex(where: { $0.id == transaction.id }) else { continue }
//                    transactions[index] = transaction
//                }
//                
//                transactions.insert(contentsOf: new, at: 0)
//                
//                self.transactions = transactions
//                self.isLoadingTransactions = false
//            })
//            .store(in: &cancellables)
    }
    
    func refreshHasWallet() {
        PrimalWalletRequest(type: .isUser).publisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] val in
                self?.isLoadingWallet = false
                self?.userHasWallet = self?.userHasWallet == true || val.kycLevel == KYCLevel.email || val.kycLevel == KYCLevel.idDocument
            }
            .store(in: &cancellables)
    }
    
    func refreshBalance() {
        PrimalWalletRequest(type: .balance).publisher()
            .receive(on: DispatchQueue.main)
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
           .receive(on: DispatchQueue.main)
           .sink { [weak self] res in
               let trans = res.transactions.filter { new in self?.transactions.contains(where: { old in old.id == new.id }) != true }
               if !trans.isEmpty {
                   self?.transactions = trans + (self?.transactions ?? [])
               }
           }
           .store(in: &cancellables)
    }
    
    func loadMoreTransactions() {
        guard !isLoadingTransactions else { return }
        
        isLoadingTransactions = true
     
        PrimalWalletRequest(type: .transactions(until: transactions.last?.created_at)).publisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] res in
                if !res.transactions.isEmpty {
                    self?.transactions += res.transactions
                    self?.isLoadingTransactions = false
                }
            }
            .store(in: &cancellables)
    }
    
    private func requestAsync(_ request: PrimalWalletRequest.RequestType) async throws {
        return try await withCheckedThrowingContinuation({ continuation in
            PrimalWalletRequest(type: request).publisher()
                .receive(on: DispatchQueue.main)
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
    
    func sendLud16(_ lud: String, sats: Int, note: String, pubkey: String?, zap: NostrObject?) async throws {
        guard let walletID else { throw WalletError.noWallet }
        guard let decoded = lud.lud16ToDecodedLNURL else { throw WalletError.noLud }
        
        let res = try await walletRepo.pay(walletId: walletID, request: .LightningLnUrl(amountSats: String(sats), noteRecipient: note, noteSelf: note, idempotencyKey: UUID().uuidString, lnUrl: decoded, lud16: lud))
        print(res)
    }
    
    func send(user: PrimalUser, sats: Int, note: String, zap: NostrObject?) async throws {
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
    // END OF COPIED
    
//    func sendLNInvoice(_ lninvoice: String, satsOverride: Int?, messageOverride: String?) async throws {
//        try await requestAsync(.payInvoice(lnInvoice: lninvoice, amountOverride: satsOverride?.satsToBitcoinString(), noteOverride: messageOverride))
//    }
//    
//    func sendLNURL(lnurl: String, pubkey: String?, sats: Int, note: String) async throws {
//        try await requestAsync(.send(.lnurl, target: lnurl, pubkey: pubkey, amount: sats.satsToBitcoinString(), note: note, zap: nil))
//    }
//    
//    func sendLud16(_ lud: String, sats: Int, note: String, pubkey: String? = nil, zap: NostrObject?) async throws {
//        try await requestAsync(.send(.lud16, target: lud, pubkey: pubkey, amount: sats.satsToBitcoinString(), note: note, zap: zap))
//    }
//    
//    func send(user: PrimalUser, sats: Int, note: String, zap: NostrObject? = nil) async throws {
//        let lud16 = user.lud16
//        if lud16.isEmpty {
//            let lud06 = user.lud06
//            
//            if lud06.isEmpty { throw WalletError.noLud }
//            
//            return try await requestAsync(.send(.lud06, target: lud06, pubkey: user.pubkey, amount: sats.satsToBitcoinString(), note: note, zap: zap))
//        }
//            
//        try await sendLud16(lud16, sats: sats, note: note, pubkey: user.pubkey, zap: zap)
//    }
    
    func sendOnchain(_ btcAddress: String, tier: String, sats: Int, note: String) async throws {
        try await requestAsync(.send(.onchain(tier: tier), target: btcAddress, pubkey: nil, amount: sats.satsToBitcoinString(), note: note, zap: nil))
    }
}

private extension PrimalWalletManager {
    func setupPublishers() {
        $userHasWallet
            .filter { $0 == true }
            .receive(on: DispatchQueue.main)
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
//        
//        $transactions
//            .receive(on: DispatchQueue.main)
//            .flatMap { transactions in
//                let flatPubkeys: [String] = transactions.flatMap { [$0.pubkey_1] + ($0.pubkey_2 == nil ? [] : [$0.pubkey_2!]) }
//                
//                var set = Set<String>()
//                
//                for pubkey in flatPubkeys {
//                    if WalletManager.instance.userData[pubkey] == nil {
//                        set.insert(pubkey)
//                    }
//                }
//                
//                if set.isEmpty {
//                    return Just(PostRequestResult()).eraseToAnyPublisher()
//                }
//                
//                return SocketRequest(name: "user_infos", payload: .object([
//                    "pubkeys": .array(set.map { .string($0) })
//                ])).publisher().eraseToAnyPublisher()
//            }
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] result in
//                guard let self else { return }
//                for (key, value) in result.users {
//                    WalletManager.instance.userData[key] = result.createParsedUser(value)
//                }
//                
//                let parsed = self.transactions.map { (
//                    $0,
//                    WalletManager.instance.userData[$0.pubkey_2 ?? $0.pubkey_1] ?? result.createParsedUser(.init(pubkey: $0.pubkey_2 ?? $0.pubkey_1))
//                ) }
//                
//                WalletManager.instance.parsedTransactions = parsed
//            }
//            .store(in: &cancellables)

        Connection.wallet.isConnectedPublisher.filter { $0 }
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
}
