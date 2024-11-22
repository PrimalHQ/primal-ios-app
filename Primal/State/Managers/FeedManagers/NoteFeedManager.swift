//
//  NoteFeedManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 8.10.24..
//

import Foundation
import Combine
import GenericJSON

class ExploreMediaFeedManager: NoteFeedManager {
    init() {
        super.init(request: FeedManagerRequest(name: "explore_media", body: ["user_pubkey": .string(IdentityManager.instance.userHexPubkey)]), contentStyle: .regular)
    }
}

class NoteFeedManager: BaseFeedManager {
    // Accessed from the main thread
    @Published var notes: [ParsedContent] = []
    
    @Published private var oldNotes: [ParsedContent] = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(request: FeedManagerRequestProtocol, contentStyle: ParsedContentTextStyle) {
        super.init(request: request)
        baseDelegate = self
        
        requestResultEmitter
            .map { $0.process(contentStyle: contentStyle) }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notes in
                guard let self else { return }
                self.notes = oldNotes + notes
                self.oldNotes = self.notes
            }
            .store(in: &cancellables)
    }
    
    override func refresh() {
        oldNotes = []
        
        super.refresh()
    }
}

extension NoteFeedManager: BaseFeedManagerDelegate {
    func userMuted(pubkey: String) {
        notes = notes.filter { $0.user.data.pubkey != pubkey }
        oldNotes = oldNotes.filter { $0.user.data.pubkey != pubkey }
    }
    
    func requestOffset(until: Double) -> Int {
        1
    }
}
