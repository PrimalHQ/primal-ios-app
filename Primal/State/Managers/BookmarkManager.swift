//
//  BookmarkManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 8.4.24..
//

import Combine
import Foundation

final class BookmarkManager {
    static let instance: BookmarkManager = BookmarkManager()
    
    @Published var hexesToBookmark: Set<String> = []
    @Published var hexesToUnbookmark: Set<String> = []
    
    var cancellables: Set<AnyCancellable> = []
    
    private init() {
        Publishers.CombineLatest3($hexesToBookmark, $hexesToUnbookmark, Connection.regular.$isConnected)
            .debounce(for: .seconds(2), scheduler: RunLoop.main)
            .sink { [weak self] pubkeysF, pubkeysUF, isConnected in
                if pubkeysF.isEmpty && pubkeysUF.isEmpty { return }
                guard isConnected else { return }
                
                IdentityManager.instance.requestUserContacts {
                    guard let self else { return }
                    
                    let contacts = IdentityManager.instance.userContacts.contacts.union(pubkeysF).subtracting(pubkeysUF)
                    
                    DispatchQueue.main.async {
                        if self.hexesToBookmark != pubkeysF || self.hexesToUnbookmark != pubkeysUF { return } // Don't update yet, another update is coming
                        
                        self.hexesToBookmark = []
                        self.hexesToUnbookmark = []
                        
                        if IdentityManager.instance.userContacts.contacts == contacts { return } // Don't update if same
                        
                        self.sendBatchEvent(contacts, errorHandler:  {
                            self.hexesToBookmark = self.hexesToBookmark.union(pubkeysF)
                            self.hexesToUnbookmark = self.hexesToUnbookmark.union(pubkeysUF)
                        })
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func isBookmarked(_ hex: String) -> Bool {
        !hexesToUnbookmark.contains(hex) && (hexesToBookmark.contains(hex) || IdentityManager.instance.userContacts.contacts.contains(pubkey))
    }
    
    func bookmark(_ hex: String) {
        if LoginManager.instance.method() != .nsec { return }

        hexesToUnbookmark.remove(hex)
        hexesToBookmark.insert(hex)
    }
    
    func unbookmark(_ hex: String) {
        if LoginManager.instance.method() != .nsec { return }
        
        hexesToBookmark.remove(hex)
        hexesToUnbookmark.insert(hex)
    }
    
    func sendBatchFollowEvent(_ pubkeys: Set<String>, successHandler: (() -> Void)? = nil, errorHandler: (() -> Void)? = nil) {
        if LoginManager.instance.method() != .nsec { return }
        
        var contacts = IdentityManager.instance.userContacts.contacts
        for pubkey in pubkeys {
            contacts.insert(pubkey)
        }
        
        sendBatchEvent(pubkeys, successHandler: successHandler, errorHandler: errorHandler)
    }
    
    private func sendBatchEvent(_ pubkeys: Set<String>, successHandler: (() -> Void)? = nil, errorHandler: (() -> Void)? = nil) {
        IdentityManager.instance.userContacts.contacts = pubkeys
        
        guard let ev = NostrObject.contacts(pubkeys) else {
            errorHandler?()
            return
        }
        
        RelaysPostbox.instance.request(ev, successHandler: { _ in successHandler?() }, errorHandler: errorHandler)
    }
}
