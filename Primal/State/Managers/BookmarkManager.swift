//
//  BookmarkManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 8.4.24..
//

import Combine
import Foundation
import UIKit

final class BookmarkManager {
    static let instance: BookmarkManager = BookmarkManager()
    
    @Published var hexesToBookmark: [String] = []
    @Published var hexesToUnbookmark: Set<String> = []
    @Published var cachedBookmarks = DatedTagArray(created_at: -10, array: [])
    @Published var isReadyForFirstBookmark = false
    
    var cancellables: Set<AnyCancellable> = []
    
    private init() {
        IdentityManager.instance.$user.map { $0?.pubkey }.removeDuplicates().receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                hexesToBookmark = []
                hexesToUnbookmark = []
                cachedBookmarks = DatedTagArray(created_at: -10, array: [])
                isReadyForFirstBookmark = false
                fetchBookmarks()
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest4($hexesToBookmark, $hexesToUnbookmark, $isReadyForFirstBookmark, Connection.regular.$isConnected)
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .filter { hexesB, hexesU, _, isConnected in
                isConnected && !(hexesB.isEmpty && hexesU.isEmpty)
            }
            .flatMap({ hexesB, hexesU, isReady, _ in
                Publishers.Zip(
                    Just((hexesB, hexesU, isReady)),
                    SocketRequest(name: "get_bookmarks", payload: .object([
                        "pubkey": .string(IdentityManager.instance.userHexPubkey)
                    ]))
                    .publisher()
                )
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (merged, result) in
                guard let self else { return }
                
                let (hexesB, hexesU, isReady) = merged
                
                guard let datedBookmarks = result.bookmarks ?? (isReady ? DatedTagArray(created_at: -10, array: []) : nil) else {
                    let alert = UIAlertController(title: "Saving first bookmark", message: "You are about to save your first public bookmark. These bookmarks can be seen by other nostr users.\nDo you wish to continue?", preferredStyle: .alert)
                    alert.addAction(.init(title: "Save bookmark", style: .default) { [weak self] _ in
                        self?.isReadyForFirstBookmark = true
                    })
                    alert.addAction(.init(title: "Cancel", style: .cancel))
                    RootViewController.instance.present(alert, animated: true)
                    return
                }
                self.cachedBookmarks = datedBookmarks
                
                if self.hexesToBookmark != hexesB || self.hexesToUnbookmark != hexesU { return } // Don't update yet, another update is coming
                
                var bookmarks = datedBookmarks.array
                bookmarks.append(contentsOf: hexesB.map { self.tag($0) })
                bookmarks = bookmarks.filter { !hexesU.contains($0.text) }
                
                self.hexesToBookmark = []
                self.hexesToUnbookmark = []
                
                if datedBookmarks.array == bookmarks { return } // Don't update if same
                
                self.sendBatchEvent(bookmarks, errorHandler:  {
                    self.hexesToBookmark.insert(contentsOf: hexesB, at: 0)
                    self.hexesToUnbookmark = self.hexesToUnbookmark.union(hexesU)
                })
            })
            .store(in: &cancellables)
    }
    
    func tag(_ hex: String) -> Tag { .init(type: "e", text: hex) }
    
    func isBookmarked(_ hex: String) -> Bool {
        !hexesToUnbookmark.contains(hex) && (hexesToBookmark.contains(hex) || cachedBookmarks.array.contains(tag(hex)))
    }
    
    func bookmark(_ hex: String) {
        if LoginManager.instance.method() != .nsec { return }

        hexesToUnbookmark.remove(hex)
        hexesToBookmark.append(hex)
    }
    
    func unbookmark(_ hex: String) {
        if LoginManager.instance.method() != .nsec { return }
        
        hexesToBookmark.remove(object: hex)
        hexesToUnbookmark.insert(hex)
    }
    
    func fetchBookmarks() {
        SocketRequest(name: "get_bookmarks", payload: .object([
            "pubkey": .string(IdentityManager.instance.userHexPubkey)
        ]))
        .publisher()
        .sink { [weak self] result in
            guard let self, let bookmarks = result.bookmarks, cachedBookmarks.created_at < bookmarks.created_at else { return }
            cachedBookmarks = bookmarks
        }
        .store(in: &cancellables)
    }
    
    private func sendBatchEvent(_ tags: [Tag], successHandler: (() -> Void)? = nil, errorHandler: (() -> Void)? = nil) {
        cachedBookmarks.array = tags
        
        guard let ev = NostrObject.bookmarks(tags) else {
            errorHandler?()
            return
        }
        
        RelaysPostbox.instance.request(ev, successHandler: { _ in successHandler?() }, errorHandler: errorHandler)
    }
}
