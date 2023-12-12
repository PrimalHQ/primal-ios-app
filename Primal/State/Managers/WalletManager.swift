//
//  WalletManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.10.23..
//

import Combine
import Foundation

extension UserDefaults {
    var howManyZaps: Int {
        get { integer(forKey: "howManyZapsKey") }
        set { setValue(newValue, forKey: "howManyZapsKey") }
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

final class WalletManager {
    static let instance = WalletManager()
    
    var cancellables = Set<AnyCancellable>()
    @Published var userHasWallet: Bool?
    @Published var balance: Int = 0
    @Published var transactions: [WalletTransaction] = []
    @Published var isLoadingWallet = true
    @Published var didJustCreateWallet = false
    @Published private var userZapped: [String: Int] = [:]
    
    var userData: [String: ParsedUser] = [:]
    
    @Published var parsedTransactions: [(WalletTransaction, ParsedUser)] = []
    
    private var isLoadingTransactions = false
    
    private init() {
        setupPublishers()
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
        
        PrimalWalletRequest(type: .transactions()).publisher().waitForConnection(Connection.wallet)
            .sink(receiveValue: { [weak self] val in
                self?.transactions = val.transactions
                self?.isLoadingTransactions = false
            })
            .store(in: &cancellables)
    }
    
    func refreshBalance() {
        PrimalWalletRequest(type: .balance).publisher().waitForConnection(Connection.wallet)
            .sink(receiveValue: { [weak self] val in
                guard  let string = val.balance?.amount else { return }
                
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
    
    func sendLNInvoice(_ lninvoice: String, satsOverride: Int?, messageOverride: String?) async throws {
        return try await withCheckedThrowingContinuation({ continuation in
            PrimalWalletRequest(type: .sendLNInvoice(lnInvoice: lninvoice, amountOverride: satsOverride?.satsToBitcoinString(), noteOverride: messageOverride)).publisher()
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
    
    func sendLNURL(lnurl: String, pubkey: String?, sats: Int, note: String) async throws {
        return try await withCheckedThrowingContinuation({ continuation in
            PrimalWalletRequest(type: .sendLNURL(lnurl: lnurl, pubkey: pubkey, amount: sats.satsToBitcoinString(), note: note)).publisher()
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
    
    func send(user: PrimalUser, sats: Int, note: String, zap: NostrObject? = nil) async throws {
        let lud06 = user.lud06
        if lud06.isEmpty {
            let lud = user.lud16
            if lud.isEmpty { throw WalletError.noLud }
            
            return try await withCheckedThrowingContinuation({ continuation in
                PrimalWalletRequest(type: .sendLud16(target: lud, pubkey: user.pubkey, amount: sats.satsToBitcoinString(), note: note, zap: zap)).publisher()
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
        
        return try await withCheckedThrowingContinuation({ continuation in
            PrimalWalletRequest(type: .sendLud06(target: lud06, pubkey: user.pubkey, amount: sats.satsToBitcoinString(), note: note, zap: zap)).publisher()
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
        IdentityManager.instance.$user
            .compactMap { $0?.npub }
            .removeDuplicates()
            .map { [weak self] in
                self?.userHasWallet = nil
                self?.balance = 0
                self?.transactions = []
                self?.userZapped = [:]
                self?.isLoadingWallet = true
                return $0
            }
            .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
            .flatMap { npub -> AnyPublisher<WalletRequestResult, Never> in
                return PrimalWalletRequest(type: .isUser).publisher().waitForConnection(Connection.wallet)
            }
            .sink(receiveValue: { [weak self] val in
                self?.isLoadingWallet = false
                self?.userHasWallet = val.kycLevel == .email || val.kycLevel == .idDocument
            })
            .store(in: &cancellables)
        
        $userHasWallet
            .filter { $0 == true }
            .flatMap { [weak self] _ in
                self?.isLoadingWallet = true
                return Publishers.Zip(
                    PrimalWalletRequest(type: .balance).publisher().waitForConnection(Connection.wallet),
                    PrimalWalletRequest(type: .transactions()).publisher().waitForConnection(Connection.wallet)
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
        
        $balance
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .flatMap { [weak self] _ in
                return PrimalWalletRequest(type: .transactions(since: self?.transactions.first?.created_at)).publisher().waitForConnection(Connection.wallet)
            }
            .sink(receiveValue: { [weak self] val in
                guard let self else { return }
                
                let newTransactions = val.transactions.filter { new in !self.transactions.contains(where: { $0.id == new.id }) }
                
                if !newTransactions.isEmpty {
                    self.transactions = newTransactions + self.transactions
                }
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
                    self.parsedTransactions = self.transactions.map { (
                        $0,
                        self.userData[$0.pubkey_2 ?? $0.pubkey_1] ?? result.createParsedUser(.init(pubkey: $0.pubkey_2 ?? $0.pubkey_1))
                    ) }
                }
            }
            .store(in: &cancellables)
    }
}
