//
//  PrimalWalletManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 27.5.25..
//

import Combine
import Foundation
import GenericJSON

class PrimalWalletManager {
    @Published var userHasWallet: Bool?
    @Published var updatedAt: Double?
    @Published var balance: Int = 0
    @Published var maxBalance: Int = 0
    @Published var transactions: [WalletTransaction] = []
    @Published var isLoadingWallet = true
    
    private var isLoadingTransactions = false
    private var update: ContinousConnection?
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        setupPublishers()
        
        let pubkey = IdentityManager.instance.userHexPubkey
        
        let oldBalance = UserDefaults.standard.oldWalletAmount[pubkey] ?? 0
        balance = oldBalance
        if oldBalance > 0 {
            userHasWallet = true
        }

        let oldTransactions = (UserDefaults.standard.oldTransactions[pubkey] ?? []).map { $0.toTuple() }
        isLoadingWallet = oldTransactions.isEmpty
        
        refreshHasWallet()
    }
    
    func refreshTransactions() {
        isLoadingTransactions = true
        
        PrimalWalletRequest(type: .transactions()).publisher()
            .receive(on: DispatchQueue.main)
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
            .receive(on: DispatchQueue.main)
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
    
    func sendLNInvoice(_ lninvoice: String, satsOverride: Int?, messageOverride: String?) async throws {
        try await requestAsync(.payInvoice(lnInvoice: lninvoice, amountOverride: satsOverride?.satsToBitcoinString(), noteOverride: messageOverride))
    }
    
    func sendLNURL(lnurl: String, pubkey: String?, sats: Int, note: String, zap: NostrObject?) async throws {
        try await requestAsync(.send(.lnurl, target: lnurl, pubkey: pubkey, amount: sats.satsToBitcoinString(), note: note, zap: zap))
    }
    
    func sendLud16(_ lud: String, sats: Int, note: String, pubkey: String? = nil, zap: NostrObject?) async throws {
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
        
        $transactions
            .receive(on: DispatchQueue.main)
            .flatMap { transactions in
                let flatPubkeys: [String] = transactions.flatMap { [$0.pubkey_1] + ($0.pubkey_2 == nil ? [] : [$0.pubkey_2!]) }
                
                var set = Set<String>()
                
                for pubkey in flatPubkeys {
                    if WalletManager.instance.userData[pubkey] == nil {
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
                    WalletManager.instance.userData[key] = result.createParsedUser(value)
                }
                
                let parsed = self.transactions.map { (
                    $0,
                    WalletManager.instance.userData[$0.pubkey_2 ?? $0.pubkey_1] ?? result.createParsedUser(.init(pubkey: $0.pubkey_2 ?? $0.pubkey_1))
                ) }
                
                WalletManager.instance.parsedTransactions = parsed
                
                if !parsed.isEmpty {
                    UserDefaults.standard.oldTransactions[IdentityManager.instance.userHexPubkey] = parsed.prefix(10).map { .init(transaction: $0.0, user: .init($0.1)) }
                }
            }
            .store(in: &cancellables)

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
