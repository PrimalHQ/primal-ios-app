//
//  ZapFeedManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 8.10.24..
//

import Foundation
import Combine
import GenericJSON

class ExploreZapsFeedManager: ZapFeedManager {
    init() {
        super.init(request: FeedManagerRequest(name: "explore_zaps", body: ["user_pubkey": .string(IdentityManager.instance.userHexPubkey)]))
    }
}

class ParsedFeedZap {
    var zap: ParsedZap
    var zappedObject: ZappableReferenceObject
    
    init(zap: ParsedZap, zappedObject: ZappableReferenceObject) {
        self.zap = zap
        self.zappedObject = zappedObject
    }
}

class ZapFeedManager: BaseFeedManager {
    // Accessed from the main thread
    @Published var zaps: [ParsedFeedZap] = []
    
    @Published private var oldZaps: [ParsedFeedZap] = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(request: FeedManagerRequestProtocol) {
        super.init(request: request)
        baseDelegate = self
        
        requestResultEmitter
            .map { result in
                let parsedUsers = result.getSortedUsers()
                let notes = NoteProcessor(result: result, contentStyle: .regular).process()
                let articles = result.getArticles()
                
                return result.postZaps.map { primalZapEvent in
                    let user = parsedUsers.first(where: { $0.data.pubkey == primalZapEvent.sender }) ?? ParsedUser(data: .init(pubkey: primalZapEvent.sender))
                    
                    let referencedNote: ZappableReferenceObject? = notes.first(where: { $0.zaps.contains(where: { zap in zap.receiptId == primalZapEvent.zap_receipt_id })})
                    let referencedArticle: ZappableReferenceObject? = articles.first(where: { $0.zaps.contains { zap in zap.receiptId == primalZapEvent.zap_receipt_id }})
                    
                    let zappedObject: ZappableReferenceObject = referencedNote ?? referencedArticle ?? user
                    
                    return ParsedFeedZap(
                        zap: ParsedZap(
                            receiptId: primalZapEvent.zap_receipt_id,
                            postId: primalZapEvent.event_id,
                            amountSats: primalZapEvent.amount_sats,
                            message: result.zapReceipts[primalZapEvent.zap_receipt_id]?["content"]?.stringValue ?? "",
                            createdAt: primalZapEvent.created_at,
                            user: user
                        ),
                        zappedObject: zappedObject
                    )
                }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (zaps: [ParsedFeedZap]) in
                guard let self else { return }
                self.zaps = oldZaps + zaps
                self.oldZaps = self.zaps
            }
            .store(in: &cancellables)
    }
    
    override func refresh() {
        oldZaps = []
        
        super.refresh()
    }
}

extension ZapFeedManager: BaseFeedManagerDelegate {
    func userMuted(pubkey: String) {
        zaps = zaps.filter { $0.zap.user.data.pubkey != pubkey }
        oldZaps = oldZaps.filter { $0.zap.user.data.pubkey != pubkey }
    }
    
    func requestOffset(until: Double) -> Int {
        1
    }
}
