//
//  LiveVideoChatController.swift
//  Primal
//
//  Created by Pavle Stevanović on 22. 7. 2025..
//

import Combine
import UIKit
import GenericJSON

class LiveVideoChatController: UIViewController {
    
    let header = LiveCommentsHeaderView()
    let commentsTable = SafeTableView()
    let input = LiveVideoChatInputView()
    
    var cancellables: Set<AnyCancellable> = []
    
    lazy var infoVC = LongFormEmbeddedPostController<LiveVideoZapsPostCell>()
    
    let live: ParsedLiveEvent
    let user: ParsedUser
    
    var continousConnection: ContinousConnection?
    
    var comments: [ParsedLiveComment] = []
    let post: ParsedContent
    
    var userCache: [String: ParsedUser] = [:]
    
    var videoController: LiveVideoPlayerController? { parent as? LiveVideoPlayerController }
    
    init(live: ParsedLiveEvent, user: ParsedUser) {
        self.live = live
        self.user = user
        let nostrContent = NostrContent(json: .object(live.event))
        self.post = ParsedContent(post: .init(nostrPost: nostrContent, nostrPostStats: .empty(nostrContent.id)), user: user)
        
        super.init(nibName: nil, bundle: nil)
        
        requestChat()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        
        let infoParent = UIView()
        infoParent.addSubview(infoVC.view)
        infoVC.view.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .top).pinToSuperview(edges: .bottom, padding: 12)
        
        infoVC.willMove(toParent: self)
        addChild(infoVC)
        
        infoVC.posts = [post]
        
        let spacer = KeyboardSizingView()
        
        let stack = UIStackView(axis: .vertical, [
            PullBarView(color: .foreground4.withAlphaComponent(0.8)),
            header,
            infoParent,
            SpacerView(height: 1, color: .background3),
            commentsTable,
            SpacerView(height: 1, color: .background3),
            input,
            spacer
        ])
        
        view.addSubview(stack)
        stack
            .pinToSuperview(edges: [.horizontal, .bottom])
            .pinToSuperview(edges: .top, padding: 8)
        
        input.backgroundView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        commentsTable.heightAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        
        infoVC.didMove(toParent: self)
        
        commentsTable.backgroundColor = .background
        commentsTable.dataSource = self
        commentsTable.register(LiveVideoChatMessageCell.self, forCellReuseIdentifier: "cell")
        commentsTable.register(LiveVideoChatZapCell.self, forCellReuseIdentifier: "zapCell")
        commentsTable.showsVerticalScrollIndicator = false
        commentsTable.transform = .init(rotationAngle: .pi)
        commentsTable.separatorStyle = .none
        commentsTable.keyboardDismissMode = .onDrag
        commentsTable.contentInsetAdjustmentBehavior = .never
        commentsTable.contentInset = .init(top: 10, left: 0, bottom: 10, right: 0)
        
        spacer.updateHeightCancellable().store(in: &cancellables)
        
        KeyboardManager.instance.isShowingKeyboard.sink { [weak self] isShowing in
            self?.header.small = isShowing
            self?.infoVC.view.superview?.isHidden = isShowing
            
            if isShowing {
                self?.videoController?.chatControllerRequestsMoreSpace()
            } else {
                self?.videoController?.chatControllerRequestsNormalSize()
            }
        }
        .store(in: &cancellables)
    }
    
}

extension LiveVideoChatController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { comments.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = comments[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: comment.zapAmount > 0 ? "zapCell" : "cell", for: indexPath)
        cell.transform = tableView.transform
        if comment.zapAmount > 0 {
            (cell as? LiveVideoChatZapCell)?.updateForComment(comment)
        } else {
            (cell as? LiveVideoChatMessageCell)?.updateForComment(comment)
        }
        return cell
    }
}

private extension LiveVideoChatController {
    
    func addZaps(_ zaps: [ParsedZap]) {
        post.zaps.append(contentsOf: zaps)
        post.zaps.sort(by: {
            guard $0.amountSats == $1.amountSats else { return $0.amountSats > $1.amountSats }
            
            return $0.createdAt < $1.createdAt
        })
        self.infoVC.table.reloadData()
    }
    
    func jsonToZapComment(_ json: JSON) -> ParsedLiveComment? {
        guard
            let event = json.objectValue,
            let pubkey = event["pubkey"]?.stringValue,
            let tags = event["tags"]?.arrayValue,
            let amountString = tags.tagValueForKey("amount"),
            let tagAmount = Int(amountString)
        else { return nil }
        
        let amount = tagAmount / 1000
        
        let user = userCache[pubkey] ?? ParsedUser(data: .init(pubkey: pubkey))
        let message: String = event["content"]?.stringValue ?? ""
                
        return ParsedLiveComment(user: user, comment: message, event: event, zapAmount: amount)
    }
    
    func jsonToZap(_ json: JSON) -> ParsedZap? {
        guard
            let event = json.objectValue,
            let pubkey = event["pubkey"]?.stringValue,
            let tags = event["tags"]?.arrayValue,
            let amountString = tags.tagValueForKey("amount"),
            let tagAmount = Int(amountString)
        else { return nil }
        
        let amount = tagAmount / 1000
        
        let user = userCache[pubkey] ?? ParsedUser(data: .init(pubkey: pubkey))
        let message: String = event["content"]?.stringValue ?? ""
        let receiptId = event["id"]?.stringValue ?? ""
        let createdAt = event["created_at"]?.doubleValue ?? 0

        return ParsedZap(receiptId: receiptId, postId: post.post.id, amountSats: amount, message: message, createdAt: createdAt, user: user)
    }
    
    func requestChat() {
        SocketRequest(name: "live_feed", payload: [
            "kind": .number(30311),
            "pubkey": .string(live.creatorPubkey),
            "identifier": .string(live.dTag),
            "user_pubkey": .string(IdentityManager.instance.userHexPubkey)
        ])
        .publisher()
        .receive(on: DispatchQueue.main)
        .sink { [weak self] res in
            guard let self else { return }
            
            let zapReceipts = res.zapReceipts
            let commentEvents = res.events.filter { Int($0["kind"]?.doubleValue ?? 0) == NostrKind.liveComment.rawValue }
            
            var pubkeys: [String] = res.zapReceipts.compactMap { $0.value.objectValue?["pubkey"]?.stringValue }
            pubkeys += commentEvents.compactMap { $0["pubkey"]?.stringValue }
            
            pubkeys = pubkeys.unique().filter({ self.userCache[$0] == nil })
            
            SocketRequest(name: "user_infos", payload: ["pubkeys": .array(pubkeys.map({ .string($0) }))]).publisher()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] res in
                    for user in res.getSortedUsers() {
                        self?.userCache[user.data.pubkey] = user
                    }
                    
                    let zapComments: [ParsedLiveComment] = zapReceipts.compactMap({ self?.jsonToZapComment($0.1) })
                    
                    let comments: [ParsedLiveComment] = commentEvents
                        .compactMap({ event in
                            guard
                                let userPubkey = event["pubkey"]?.stringValue,
                                let content = event["content"]?.stringValue
                            else { return nil }
                            
                            return .init(
                                user: self?.userCache[userPubkey] ?? ParsedUser(data: .init(pubkey: userPubkey)),
                                comment: content,
                                event: event
                            )
                        })
                    
                    self?.comments += (comments + zapComments).sorted(by: { $0.createdAt > $1.createdAt })
                    self?.addZaps(zapReceipts.compactMap { self?.jsonToZap($0.1) })
                    self?.commentsTable.reloadData()
                }
                .store(in: &cancellables)
        }
        .store(in: &cancellables)
        
        continousConnection = Connection.regular.requestCacheContinous(name: "live_feed", request: .object([
            "kind": .number(30311),
            "pubkey": .string(live.creatorPubkey),
            "identifier": .string(live.dTag),
            "user_pubkey": .string(IdentityManager.instance.userHexPubkey)
        ])) { [weak self] response in
            DispatchQueue.main.async {
                guard
                    let self,
                    var event = response.arrayValue?.last?.objectValue
                else { return }
                
                let kind: Int = Int(event["kind"]?.doubleValue ?? 0)
                
                if kind == NostrKind.live.rawValue {
                    // TODO: Update the live info
                    return
                }
                
                var amount = 0
                let userPubkey: String
                let content: String
                if kind == NostrKind.zapReceipt.rawValue {
                    guard
                        let tags = event["tags"]?.arrayValue,
                        let desc = tags.tagValueForKey("description"),
                        let zapReceipt: [String: JSON] = desc.decode(),
                        let pubkey = zapReceipt["pubkey"]?.stringValue
                    else { return }
                    
                    if let amountS = tags.tagValueForKey("amount") {
                        amount = Int(amountS) ?? amount
                    }
                    
                    event = zapReceipt
                    content = zapReceipt["content"]?.stringValue?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    userPubkey = pubkey
                } else {
                    content = event["content"]?.stringValue?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    guard let pubkey = event["pubkey"]?.stringValue else { return }
                    userPubkey = pubkey
                }
                
                if let user = self.userCache[userPubkey] {
                    self.comments.insert(ParsedLiveComment(user: user, comment: content, event: event, zapAmount: amount), at: 0)
                    self.commentsTable.insertRows(at: [.init(row: 0, section: 0)], with: .automatic)
                    if let zap = self.jsonToZap(.object(event)) {
                        self.addZaps([zap])
                    }
                    return
                }
                
                SocketRequest(name: "user_infos", payload: ["pubkeys": [.string(userPubkey)]]).publisher()
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] res in
                        let user = res.getSortedUsers().first
                        if let user {
                            self?.userCache[user.data.pubkey] = user
                        }
                        self?.comments.insert(ParsedLiveComment(
                            user: user ?? .init(data: .init(pubkey: userPubkey)),
                            comment: content,
                            event: event,
                            zapAmount: amount
                        ), at: 0)
                        self?.commentsTable.insertRows(at: [.init(row: 0, section: 0)], with: .automatic)
                    }
                    .store(in: &self.cancellables)
            }
        }
    }
}
