//
//  WalletManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.10.23..
//

import Combine
import Foundation

enum WalletError: Error {
    case serverError(String)
    case inAppPurchaseServerError
    
    var message: String {
        switch self {
        case .serverError(let message):
            return message
        case .inAppPurchaseServerError:
            return "We were not able to send sats to your wallet. Please contact us at support@primal.net and we will assist you."
        }
    }
}

final class WalletManager {
    static let instance = WalletManager()
    
    var cancellables = Set<AnyCancellable>()
    
    @Published var userHasWallet = false
    @Published var balance: Int = 0
    @Published var transactions: [WalletTransaction] = []
    
    var userData: [String: ParsedUser] = [:]
    
    @Published var parsedTransactions: [(WalletTransaction, ParsedUser)] = []
    
    var isLoading = false
    
    private init() {
        IdentityManager.instance.$user
            .compactMap { $0?.npub }
            .removeDuplicates()
            .flatMap { [weak self] _ -> AnyPublisher<WalletRequestResult, Never> in
                self?.userHasWallet = false
                self?.balance = 0
                self?.transactions = []
                return PrimalWalletRequest(type: .isUser).publisher().waitForConnection()
            }
            .sink(receiveValue: { [weak self] val in
                self?.userHasWallet = val.kycLevel == .email || val.kycLevel == .idDocument
            })
            .store(in: &cancellables)
        
        
        $userHasWallet
            .filter { $0 }
            .flatMap { _ in PrimalWalletRequest(type: .balance).publisher().waitForConnection() }
            .sink(receiveValue: { [weak self] val in
                let string = val.balance?.amount ?? "0"
                let double = (Double(string) ?? 0) * .BTC_TO_SAT
                
                self?.balance = Int(double)
            })
            .store(in: &cancellables)
        
        $balance
            .removeDuplicates()
            .delay(for: .seconds(3), scheduler: RunLoop.main)
            .flatMap { _ in PrimalWalletRequest(type: .transactions()).publisher().waitForConnection() }
            .sink(receiveValue: { [weak self] val in
                guard let self else { return }
                
                self.isLoading = false
                self.transactions = val.transactions
            })
            .store(in: &cancellables)
        
        $transactions
            .flatMap { [weak self] transactions in
                let flatPubkeys: [String] = transactions.flatMap { [$0.pubkey_1] + ($0.pubkey_2 == nil ? [] : [$0.pubkey_2!]) }
                
                print("WALLET: NEW TRANSACTIONS -> LOAD USER DATA")
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
            .sink { [weak self] result in
                DispatchQueue.main.async {
                    guard let self else { return }
                    for (key, value) in result.users {
                        self.userData[key] = result.createParsedUser(value)
                    }
                    print("WALLET: NEW PARSED \(self.transactions.first?.id ?? "")")
                    self.parsedTransactions = self.transactions.map { (
                        $0,
                        self.userData[$0.pubkey_2 ?? $0.pubkey_1] ?? result.createParsedUser(.init(pubkey: $0.pubkey_2 ?? $0.pubkey_1))
                    ) }
                }
            }
            .store(in: &cancellables)
    }
    
    func refreshTransactions() {
        isLoading = true
        
        PrimalWalletRequest(type: .transactions()).publisher().waitForConnection()
            .sink(receiveValue: { [weak self] val in
                self?.transactions = val.transactions
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }
    
    func refreshBalance() {
        PrimalWalletRequest(type: .balance).publisher().waitForConnection()
            .sink(receiveValue: { [weak self] val in
                let string = val.balance?.amount ?? "0"
                let double = (Double(string) ?? 0) * .BTC_TO_SAT
                
                self?.balance = Int(double)
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
    
    func loadMoreTransactions() {
        guard !isLoading else { return }
        
        isLoading = true
     
        PrimalWalletRequest(type: .transactions(until: transactions.last?.created_at)).publisher()
            .sink { [weak self] res in
                if !res.transactions.isEmpty {
                    self?.transactions += res.transactions
                    self?.isLoading = false
                }
            }
            .store(in: &cancellables)
    }
    
    func send(user: PrimalUser, sats: Int, note: String, zap: NostrObject? = nil) async throws {
        let lud = user.lud16
        guard !lud.isEmpty else { throw NSError(domain: "no.lud", code: 1) }
        
        return try await withCheckedThrowingContinuation({ continuation in
            PrimalWalletRequest(type: .send(target: lud, pubkey: user.pubkey, amount: sats.satsToBitcoinString(), note: note, zap: zap)).publisher()
                .sink { [weak self] res in
                    if let errorMessage = res.message {
                        continuation.resume(throwing: WalletError.serverError(errorMessage))
                    } else {
                        continuation.resume()
                    }
                }
                .store(in: &cancellables)
        })
    }
    
    func zap(post: ParsedContent, sats: Int, note: String) async throws {
        try await send(user: post.user.data, sats: sats, note: note, zap: NostrObject.zapWallet(note, sats: sats, post: post))
    }
}

private extension WalletManager {
}
