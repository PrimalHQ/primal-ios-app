//
//  WalletManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.10.23..
//

import Combine

enum WalletError: Error {
    case serverError(String)
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
            .waitForConnection()
            .flatMap { _ in PrimalWalletRequest(type: .isUser).publisher() }
            .sink(receiveValue: { [weak self] val in
                self?.userHasWallet = val.kycLevel == .email || val.kycLevel == .idDocument
            })
            .store(in: &cancellables)
        
        
        $userHasWallet
            .filter { $0 }
            .waitForConnection()
            .flatMap { _ in PrimalWalletRequest(type: .balance).publisher() }
            .sink(receiveValue: { [weak self] val in
                let string = val.balance?.amount ?? "0"
                let double = (Double(string) ?? 0) * .BTC_TO_SAT
                
                self?.balance = Int(double)
            })
            .store(in: &cancellables)
        
        $balance
            .removeDuplicates()
            .waitForConnection()
            .flatMap { _ in PrimalWalletRequest(type: .transactions()).publisher() }
            .sink(receiveValue: { [weak self] val in
                self?.transactions = val.transactions
            })
            .store(in: &cancellables)
        
        $transactions
            .flatMap { [weak self] transactions in
                let flatPubkeys: [String] = transactions.flatMap { [$0.pubkey_1] + ($0.pubkey_2 == nil ? [] : [$0.pubkey_2!]) }
                
                var set = Set<String>()
                
                for pubkey in flatPubkeys {
                    if self?.userData[pubkey] == nil {
                        set.insert(pubkey)
                    }
                }
                
                return SocketRequest(name: "user_infos", payload: .object([
                    "pubkeys": .array(set.map { .string($0) })
                ])).publisher()
            }
            .sink { [weak self] result in
                guard let self else { return }
                for (key, value) in result.users {
                    self.userData[key] = result.createParsedUser(value)
                }
                self.parsedTransactions = self.transactions.map { (
                    $0,
                    self.userData[$0.pubkey_2 ?? $0.pubkey_1] ?? result.createParsedUser(.init(pubkey: $0.pubkey_2 ?? $0.pubkey_1))
                ) }
            }
            .store(in: &cancellables)
    }
    
    func loadMore() {
        guard !isLoading else { return }
        
        isLoading = true
     
        PrimalWalletRequest(type: .transactions(since: transactions.last?.created_at)).publisher()
            .sink { [weak self] res in
                self?.transactions += res.transactions
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }
    
    func send(user: PrimalUser, amount: String, note: String) async throws {
        return try await withCheckedThrowingContinuation({ continuation in
            let lud = user.lud16
            guard !lud.isEmpty else { return }
            PrimalWalletRequest(type: .send(target: lud, amount: amount, note: note)).publisher()
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
}

private extension WalletManager {
}
