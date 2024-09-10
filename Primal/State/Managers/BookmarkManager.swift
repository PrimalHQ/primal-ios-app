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
    
    @Published var tagsToBookmark: [Tag] = []
    @Published var tagsToUnbookmark: Set<Tag> = []
    @Published var cachedBookmarks = DatedTagArray(created_at: -10, array: [])
    @Published var isReadyForFirstBookmark = false
    
    var cancellables: Set<AnyCancellable> = []
    
    private init() {
        IdentityManager.instance.$user.map { $0?.pubkey }.removeDuplicates().receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                tagsToBookmark = []
                tagsToUnbookmark = []
                cachedBookmarks = DatedTagArray(created_at: -10, array: [])
                isReadyForFirstBookmark = false
                fetchBookmarks()
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest4($tagsToBookmark, $tagsToUnbookmark, $isReadyForFirstBookmark, Connection.regular.isConnectedPublisher)
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
                
                if self.tagsToBookmark != hexesB || self.tagsToUnbookmark != hexesU { return } // Don't update yet, another update is coming
                
                var bookmarks = datedBookmarks.array
                bookmarks.append(contentsOf: hexesB)
                bookmarks = bookmarks.filter { !hexesU.contains($0) }
                
                self.tagsToBookmark = []
                self.tagsToUnbookmark = []
                
                if datedBookmarks.array == bookmarks { return } // Don't update if same
                
                self.sendBatchEvent(bookmarks, errorHandler:  {
                    self.tagsToBookmark.insert(contentsOf: hexesB, at: 0)
                    self.tagsToUnbookmark = self.tagsToUnbookmark.union(hexesU)
                })
            })
            .store(in: &cancellables)
    }
    
    func tag(_ content: ParsedContent) -> Tag { .init(type: content.post.referenceTagLetter, text: content.post.universalID) }
    
    func isBookmarkedPublisher(_ content: ParsedContent) -> AnyPublisher<Bool, Never> {
        let tag = tag(content)
        
        return Publishers.CombineLatest3($tagsToBookmark, $tagsToUnbookmark, $cachedBookmarks)
            .map { toB, toUB, cached in
                !toUB.contains(tag) && (toB.contains(tag) || cached.array.contains(tag))
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    func isBookmarked(_ content: ParsedContent) -> Bool {
        let tag = tag(content)
        
        return !tagsToUnbookmark.contains(tag) && (tagsToBookmark.contains(tag) || cachedBookmarks.array.contains(tag))
    }
    
    func bookmark(_ content: ParsedContent) {
        if LoginManager.instance.method() != .nsec { return }

        tagsToUnbookmark.remove(tag(content))
        tagsToBookmark.append(tag(content))
    }
    
    func unbookmark(_ content: ParsedContent) {
        if LoginManager.instance.method() != .nsec { return }
        
        tagsToBookmark.remove(object: tag(content))
        tagsToUnbookmark.insert(tag(content))
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
