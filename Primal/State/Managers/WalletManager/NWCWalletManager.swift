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

extension PrimalUser {
    var decodedLNURL: String? {
        if lud16.isEmpty {
            if lud06.isEmpty { return nil }
            
            return decode_lnurl(lud06)?.absoluteString
        }
        
        let parts = lud16.components(separatedBy: "@")
        
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

class NWCWalletManager {
    
    @Published var balance: Int = 0
    
    @Published var userHasWallet: Bool? = true
    
    let relay: String
    let serverPubkey: String
    let secret: String
    let address: String?
    
    var maxBalance: Int = 10000
    
    private let urlSession: URLSession = .shared
    
    var cancellables: Set<AnyCancellable> = []
    
    let client: any NwcApi
    let zapper: any NostrZapper
    
    init?(url: String) {
        guard
            let u = URL(string: url),
            let items = URLComponents(url: u, resolvingAgainstBaseURL: false)?.queryItems,
            let relay = items.first(where: { $0.name == "relay" })?.value,
            //            let relayURL = URL(string: relay),
            let secret = items.first(where: { $0.name == "secret" })?.value,
            let secretPubkey = HexKeypair.privkeyToPubkey(secret),
            let serverPubkey = u.host
        else { return nil }
        
        self.serverPubkey = serverPubkey
        self.relay = relay
        self.secret = secret
        address = items.first(where: { $0.name == "lud16" })?.value
        
        let data = NostrWalletConnect(lightningAddress: nil, relays: [relay], pubkey: serverPubkey, keypair: .init(privateKey: secret, pubkey: secretPubkey))
        
        client = NwcClientFactory.shared.createNwcApiClient(nwcData: data)
        zapper = NwcClientFactory.shared.createNwcNostrZapper(nwcData: data)
        print("NWC: \(url)")
        
        refreshBalance()
        
        let regConnection = PrimalApiClientFactory.shared.create(serverType: .caching)
        let walletConnection = PrimalApiClientFactory.shared.create(serverType: .wallet)
        
        let repo = IosRepositoryFactory.shared.createProfileRepository(cachingPrimalApiClient: regConnection, primalPublisher: self)
        let eventRepo = IosRepositoryFactory.shared.createEventRepository(cachingPrimalApiClient: regConnection)
        
        // WalletRepo wallet info by id (balance, transactions, etc.)
        let walletRepo = IosRepositoryFactory_.shared.createWalletRepository(
            primalWalletApiClient: walletConnection,
            nostrEventSignatureHandler: self,
            profileRepository: repo,
            eventRepository: eventRepo
        )
        
        let pubkey = IdentityManager.instance.userHexPubkey
        
        
        
        
        // WalletAccountRepo
        let walletAccountRepo = IosRepositoryFactory_.shared.createWalletAccountRepository(primalWalletApiClient: walletConnection, nostrEventSignatureHandler: self)
        
        // Za reaktivno apdejtovanje
        walletAccountRepo.observeActiveWalletId(userId: pubkey)
            .toPublisher()
            .sink { walletId in
                print("WALLET ID \(walletId ?? "nil")")
                
            }
            .store(in: &cancellables)
        
        Task {
            let res = try await ConnectNwcUseCase(walletRepository: walletRepo, walletAccountRepository: walletAccountRepo).invoke(userId: pubkey, nwcUrl: url).exceptionOrNull()
            
            print("WALLET SUCCES \(res)")
            
            guard let walletID = try await walletAccountRepo.getActiveWallet(userId: pubkey)?.walletId else { return }
            
            let balance = try await walletRepo.fetchWalletBalance(walletId: walletID).getOrThrow()
            
            print(balance)
            
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
        
        let data = ZapRequestData(
            zapperUserId: IdentityManager.instance.userHexPubkey,
            targetUserId: user.pubkey,
            lnUrlDecoded: address,
            zapAmountInSats: UInt64(sats),
            zapComment: note,
            userZapRequestEvent: .init(id: zap.id, pubKey: zap.pubkey, createdAt: zap.created_at, kind: Int32(zap.kind), tags: NostrExtensions.shared.mapAsListOfJsonArray(tags: zap.tags), content: zap.content, sig: zap.sig)
        )
        
        let res = try await zapper.zap(data: data)
        
        if let error = res as? ZapResult.Failure {
            print(error.description())
        }
    }
    
    func sendLNInvoice(_ lninvoice: String, satsOverride: Int?, messageOverride: String?) async throws {
//        var amount: KotlinLong? = nil
//        if let satsOverride {
//            amount = KotlinLong(value: Int64(satsOverride))
//        }
//        let res = try await client.payInvoice(params: .init(invoice: lninvoice, amount: amount))
        
//        print(res.description)
    }
    
    func sendLNURL(lnurl: String, pubkey: String?, sats: Int, note: String, zap: NostrObject?) async throws {
        // TODO: Mozda nece moci throw error
        throw WalletError.notSupported
    }
    
    func sendLud16(_ lud: String, sats: Int, note: String, pubkey: String?, zap: NostrObject?) async throws {
        throw WalletError.notSupported
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
        
    }
    
    func refreshBalance() {
//        Task { @MainActor [weak self] in
//            do {
//                guard let res = (try await self?.client.getBalance() as? NwcResultSuccess<GetBalanceResponsePayload>)?.result else { return }
//
//                self?.balance = Int(res.balance / 1_000)
//            } catch {
//                print(error)
//            }
//        }
    }
}

extension NWCWalletManager: NostrEventSignatureHandler {
    func __signNostrEvent(unsignedNostrEvent: NostrUnsignedEvent, completionHandler: @escaping @Sendable (SignResult?, (any Error)?) -> Void) {
        let tags = NostrExtensions.shared.mapAsListOfListOfStrings(tags: unsignedNostrEvent.tags)
        guard let object = NostrObject.create(content: unsignedNostrEvent.pubKey, kind: Int(unsignedNostrEvent.kind), tags: tags) else {
            completionHandler(SignResult.Rejected(error: .init(message: "Failed to sign", cause: nil)), nil)
            return
        }
        
        completionHandler(
            SignResult.Signed(event: .init(
                id: object.id, pubKey: object.pubkey, createdAt: object.created_at, kind: Int32(object.kind), tags: NostrExtensions.shared.mapAsListOfJsonArray(tags: object.tags), content: object.content, sig: object.sig
            )), nil
        )
    }
    
    
    func verifySignature(nostrEvent: PrimalShared.NostrEvent) -> Bool {
        true
    }
}

extension NWCWalletManager: PrimalPublisher {
    func __signPublishImportNostrEvent(unsignedNostrEvent: NostrUnsignedEvent, outboxRelays: [String]) async throws -> PrimalPublishResult {
        throw WalletError.noWallet
    }
}
