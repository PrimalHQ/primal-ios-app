//
//  RecentSearchManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 29.4.26..
//

import Combine
import Foundation

private extension UserDefaults {
    var recentSearchesByPubkey: [String: [String]] {
        get { string(forKey: "recentSearchesByPubkeyKey")?.decode() ?? [:] }
        set { setValue(newValue.encodeToString(), forKey: "recentSearchesByPubkeyKey") }
    }
}

final class RecentSearchManager {
    static let instance = RecentSearchManager()

    private static let maxCount = 10

    @Published private(set) var recentSearches: [String] = []

    private var cancellables: Set<AnyCancellable> = []

    private init() {
        IdentityManager.instance.$user.map { $0?.pubkey }.removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reload()
            }
            .store(in: &cancellables)
    }

    func addSearch(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let pubkey = IdentityManager.instance.userHexPubkey
        guard !pubkey.isEmpty else { return }

        var list = UserDefaults.standard.recentSearchesByPubkey[pubkey] ?? []
        list.removeAll { $0.caseInsensitiveCompare(trimmed) == .orderedSame }
        list.insert(trimmed, at: 0)
        if list.count > Self.maxCount { list = Array(list.prefix(Self.maxCount)) }
        write(list, for: pubkey)
    }

    func removeSearch(_ text: String) {
        let pubkey = IdentityManager.instance.userHexPubkey
        guard !pubkey.isEmpty else { return }
        var list = UserDefaults.standard.recentSearchesByPubkey[pubkey] ?? []
        list.removeAll { $0 == text }
        write(list, for: pubkey)
    }

    func clearAll() {
        let pubkey = IdentityManager.instance.userHexPubkey
        guard !pubkey.isEmpty else { return }
        write([], for: pubkey)
    }

    private func write(_ list: [String], for pubkey: String) {
        var all = UserDefaults.standard.recentSearchesByPubkey
        all[pubkey] = list
        UserDefaults.standard.recentSearchesByPubkey = all
        recentSearches = list
    }

    private func reload() {
        let pubkey = IdentityManager.instance.userHexPubkey
        recentSearches = UserDefaults.standard.recentSearchesByPubkey[pubkey] ?? []
    }
}
