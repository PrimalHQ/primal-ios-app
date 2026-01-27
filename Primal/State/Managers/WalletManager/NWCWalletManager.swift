//
//  NWCWalletManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 27.5.25..
//

import Combine
import Foundation
import NostrSDK
import GenericJSON
import PrimalShared

extension String {
    var lud16ToDecodedLNURL: String? {
        let parts = components(separatedBy: "@")
        
        guard parts.count == 2 else { return nil }
        
        let username = parts[0]
        let domain = parts[1]
        
        let scheme = domain.hasSuffix(".onion") ? "http" : "https"
        
        var components = URLComponents()
        components.scheme = scheme
        components.host = domain
        components.path = "/.well-known/lnurlp/\(username)"
        
        guard let url = components.url?.absoluteString else { return nil }
        
        return url
    }
}

extension PrimalUser {
    var decodedLNURL: String? {
        if lud16.isEmpty {
            if lud06.isEmpty { return nil }
            
            return decode_lnurl(lud06)?.absoluteString
        }
        
        return lud16.lud16ToDecodedLNURL
    }
}

class NWCWalletManager {
    
    @Published var balance: Int = 0
    
    @Published var userHasWallet: Bool? = true
    
    let relay: String
    let serverPubkey: String
    let secret: String
    let address: String?
    
    var maxBalance: Int = 10000
    
    private let urlSession: URLSession = .shared
    
    let zapFactory: any NostrZapperFactory
    let walletRepo: any WalletRepository
    
    var walletID: String?
    
    var cancellables: Set<AnyCancellable> = []
    
    init?(url: String) {
        guard
            let u = URL(string: url),
            let items = URLComponents(url: u, resolvingAgainstBaseURL: false)?.queryItems,
            let relay = items.first(where: { $0.name == "relay" })?.value,
            //            let relayURL = URL(string: relay),
            let secret = items.first(where: { $0.name == "secret" })?.value,
//            let secretPubkey = HexKeypair.privkeyToPubkey(secret),
            let serverPubkey = u.host
        else { return nil }
        
        self.serverPubkey = serverPubkey
        self.relay = relay
        self.secret = secret
        address = items.first(where: { $0.name == "lud16" })?.value
        
//        let data = NostrWalletConnect(lightningAddress: nil, relays: [relay], pubkey: serverPubkey, keypair: .init(privateKey: secret, pubkey: secretPubkey))
        
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
        
        let pubkey = IdentityManager.instance.userHexPubkey
        
        // WalletAccountRepo
        let walletAccountRepo = WalletRepositoryFactory.shared.createWalletAccountRepository()
        
        let primalWallet = WalletRepositoryFactory.shared.createPrimalWalletAccountRepository(primalWalletApiClient: walletConnection, nostrEventSignatureHandler: SigningManager.instance)
        
        // Za reaktivno apdejtovanje
        walletAccountRepo.observeActiveWalletId(userId: pubkey)
            .toPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] walletId in
                print("WALLET ID \(walletId ?? "nil")")
                guard
                    let id = walletId
                else { return }
                
                self?.walletID = id
            }
            .store(in: &cancellables)
        
        walletAccountRepo.observeActiveWallet(userId: pubkey)
            .toPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] wallet in
                guard let wallet else { return }
                self?.balance = Int((wallet.balanceInBtc?.doubleValue ?? 0) * Double(SAT_PER_BTC))
            }
            .store(in: &cancellables)
        
        Task {
            let res = try await ConnectNwcUseCase(walletRepository: walletRepo, walletAccountRepository: walletAccountRepo).invoke(userId: pubkey, nwcUrl: url, autoSetAsDefaultWallet: true)
            
            print("WALLET SUCCES \(res)")
            
            guard let walletID = try await walletAccountRepo.getActiveWallet(userId: pubkey)?.walletId else { return }
            
            let balance = try await walletRepo.fetchWalletBalance(walletId: walletID).getOrNull()
            
            
//            walletRepo.latestTransactions(walletId: walletID, walletType: .nwc).toPublisher()
//                .sink { transaction in
//                    print(transaction)
//                }
//                .store(in: &cancellables)
            // Za receive ekran
//            try await walletRepo.createLightningInvoice(walletId: walletID, amountInBtc: nil, comment: nil)
//            
//            
//            try await walletRepo.pay(walletId: walletID, request: .LightningLnInvoice(amountSats: "10", noteRecipient: "message override", noteSelf: "message override", lnInvoice: "INVOICE STRING"))
//            
//            try await walletRepo.pay(walletId: walletID, request: .LightningLnUrl(amountSats: "", noteRecipient: "", noteSelf: "", lnUrl: "", lud16: ""))
            
        }
    }
}

extension NWCWalletManager: WalletImplementation {
    var balancePublisher: AnyPublisher<Int, Never> { $balance.eraseToAnyPublisher() }
    var userHasWalletPublisher: AnyPublisher<Bool?, Never> { Just(true).eraseToAnyPublisher() }
    var isLoadingWalletPublisher: AnyPublisher<Bool, Never> { Just(false).eraseToAnyPublisher() }
    
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
        let res = try await walletRepo.pay(walletId: walletID, request: .LightningLnInvoice(amountSats: String(satsOverride ?? 0), noteRecipient: messageOverride, noteSelf: messageOverride, lnInvoice: lninvoice))
        print(res)
    }
    
    func sendLNURL(lnurl: String, pubkey: String?, sats: Int, note: String) async throws {
        guard let walletID else { throw WalletError.noWallet }
        let res = try await walletRepo.pay(walletId: walletID, request: .LightningLnUrl(amountSats: String(sats), noteRecipient: note, noteSelf: note, lnUrl: lnurl, lud16: nil))
        print(res)
        // TODO: Ask alex about
        // lud16: nil
    }
    
    func sendLud16(_ lud: String, sats: Int, note: String, pubkey: String?, zap: NostrObject?) async throws {
        guard let walletID else { throw WalletError.noWallet }
        guard let decoded = lud.lud16ToDecodedLNURL else { throw WalletError.noLud }
        
        let res = try await walletRepo.pay(walletId: walletID, request: .LightningLnUrl(amountSats: String(sats), noteRecipient: note, noteSelf: note, lnUrl: decoded, lud16: lud))
        print(res)
//        try await sendInvoice(lud, satsOverride: sats, messageOverride: note)
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
    
    func sendOnchain(_ btcAddress: String, tier: String, sats: Int, note: String) async throws {
        throw WalletError.notSupported
    }
    
    func loadMoreTransactions() {
        guard let walletID else { return }
        
    }
    
    func refreshBalance() {
        guard let walletID else { return }
        
        Task { @MainActor in
            do {
                _ = try await walletRepo.fetchWalletBalance(walletId: walletID).getOrNull()
            } catch {
                print(error)
            }
        }
    }
}

class MediaCacher: CachingMediaCacher {
    static let instance = MediaCacher()
    
    func preCacheFeedMedia(urls: [String]) { }
        
    func preCacheUserAvatars(urls: [String]) {
    }
}
