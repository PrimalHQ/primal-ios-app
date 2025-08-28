//
//  LiveVideoChatController.swift
//  Primal
//
//  Created by Pavle Stevanović on 22. 7. 2025..
//

import Combine
import UIKit
import GenericJSON
import Nantes
import SafariServices
import NostrSDK

class LiveZapsInfoVC: EmbeddedPostController<LiveVideoZapsPostCell> {
    
    let onZapDetails: () -> Void
    init(onZapDetails: @escaping () -> Void) {
        self.onZapDetails = onZapDetails
        super.init()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func reloadZaps() {
        table.reloadData()
        self.heightConstraint?.constant = 64
    }
    
    override func performEvent(_ event: PostCellEvent, withPost post: ParsedContent, inCell cell: UITableViewCell?) {
        guard case .zapDetails = event else {
            super.performEvent(event, withPost: post, inCell: cell)
            return
        }
        onZapDetails()
    }
}

class LiveVideoChatController: UIViewController, Themeable {
    
    let infoParent = UIView()
    let header = LiveCommentsHeaderView()
    let commentsTable = SafeTableView()
    let usersTable = UsersTableView()
    let input = LiveVideoChatInputView()
    let spacer = KeyboardSizingView()
    
    var cancellables: Set<AnyCancellable> = []
    
    lazy var zapsInfoVC = LiveZapsInfoVC { [weak self] in
        self?.videoController?.presentLivePopup(LiveVideoZapsController(zaps: self?.comments.filter({ $0.zapAmount > 0 }) ?? []))
    }
    
    let live: ParsedLiveEvent
    
    var continousConnection: ContinousConnection?
    
    var comments: [ParsedLiveComment] = []
    let post: ParsedContent
    
    static var userCache: [String: ParsedUser] = [:]
    
    var videoController: LiveVideoPlayerController? { parent as? LiveVideoPlayerController }
    
    lazy var inputManager = LiveChatTextViewManager(textView: input.textView, usersTable: usersTable, sendButton: input.sendButton, live: live)
    
    let zapsLoadingView = ZapGalleryLoadingView()
    let chatLoadingView = LiveChatLoadingView()
    
    var isFilteringOn = true {
        didSet {
            requestChat()
        }
    }
    
    init(live: ParsedLiveEvent) {
        self.live = live
        let nostrContent = NostrContent(json: .object(live.event.event))
        self.post = ParsedContent(post: .init(nostrPost: nostrContent, nostrPostStats: .empty(nostrContent.id)), user: live.user)
        
        super.init(nibName: nil, bundle: nil)
        
        commentsTable.transform = .init(rotationAngle: .pi)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        zapsLoadingView.isUserInteractionEnabled = false
        chatLoadingView.isUserInteractionEnabled = false
        
        infoParent.addSubview(zapsInfoVC.view)
        zapsInfoVC.view.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .top).pinToSuperview(edges: .bottom, padding: 12)
        
        zapsInfoVC.willMove(toParent: self)
        
        let stack = UIStackView(axis: .vertical, [
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
        
        addChild(zapsInfoVC)
        zapsInfoVC.didMove(toParent: self)
        zapsInfoVC.posts = [post]
        zapsInfoVC.heightOverride = 64
        
        view.addSubview(zapsLoadingView)
        zapsLoadingView.pin(to: zapsInfoVC.view, edges: [.horizontal, .top])
        
        view.addSubview(chatLoadingView)
        chatLoadingView.pin(to: commentsTable)
        
        view.addSubview(usersTable)
        usersTable.pin(to: commentsTable, edges: [.horizontal, .bottom])

        NSLayoutConstraint.activate([
            usersTable.topAnchor.constraint(greaterThanOrEqualTo: commentsTable.topAnchor),
            input.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 12),
            commentsTable.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
        
        commentsTable.backgroundColor = .background
        commentsTable.delegate = self
        commentsTable.dataSource = self
        commentsTable.register(LiveVideoChatMessageCell.self, forCellReuseIdentifier: "cell")
        commentsTable.register(LiveVideoChatZapCell.self, forCellReuseIdentifier: "zapCell")
        commentsTable.showsVerticalScrollIndicator = false
        commentsTable.separatorStyle = .none
        commentsTable.keyboardDismissMode = .onDrag
        commentsTable.contentInsetAdjustmentBehavior = .never
        commentsTable.contentInset = .init(top: 10, left: 0, bottom: 10, right: 0)
        
        spacer.updateHeightCancellable().store(in: &cancellables)
        
        KeyboardManager.instance.isShowingKeyboard.sink { [weak self] isShowing in
            self?.header.small = isShowing
            self?.zapsInfoVC.view.superview?.isHidden = isShowing
            
            if isShowing {
                self?.videoController?.chatControllerRequestsMoreSpace()
            } else {
                self?.videoController?.chatControllerRequestsNormalSize()
            }
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest(inputManager.$isEmpty, inputManager.$isEditing).map({ !$0 || $1 }).assign(to: \.isHidden, on: input.placeholderLabel).store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .userMuted)
            .compactMap { $0.object as? String }
            .receive(on: DispatchQueue.main) // Emit on main
            .sink { [weak self] pubkey in
                guard let self else { return }
                let filtered = comments.filter { $0.user.data.pubkey != pubkey }
                
                if filtered.count == comments.count { return }
                
                comments = filtered
                commentsTable.reloadData()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.requestChat()
            }
            .store(in: &cancellables)
        
        header.infoButton.addAction(.init(handler: { [weak self] _ in
            guard let videoVC = self?.parent as? LiveVideoPlayerController else { return }
            
            videoVC.presentLivePopup(LiveVideoDetailsController(live: videoVC.live))
        }), for: .touchUpInside)
        
        header.closeButton.addAction(.init(handler: { [weak self] _ in
            self?.input.textView.resignFirstResponder()
        }), for: .touchUpInside)
        
        header.configButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            videoController?.presentLivePopup(LiveVideoConfigController(live: live, chatVC: self))
        }), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateTheme()
        
        header.titleLabel.text = live.title
        header.countLabel.text = live.event.participants.localized()
        header.timeLabel.text = live.startedText
        if live.isLive {
            header.liveIcon.backgroundColor = .live
        } else {
            header.liveIcon.backgroundColor = .foreground4
        }
        
        zapsLoadingView.play()
        chatLoadingView.play()
        
        requestChat()
    }
    
    func updateTheme() {
        view.backgroundColor = .background4
        spacer.backgroundColor = .background
    }
}

extension LiveVideoChatController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let videoVC = parent as? LiveVideoPlayerController, let message = comments[safe: indexPath.row] else { return }
        
        videoVC.presentLivePopup(LiveVideoMessageDetailsController(live: live, message: message))
    }
}

extension LiveVideoChatController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { comments.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = comments[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: comment.zapAmount > 0 ? "zapCell" : "cell", for: indexPath)
        cell.transform = tableView.transform
        if comment.zapAmount > 0 {
            (cell as? LiveVideoChatZapCell)?.updateForComment(comment, delegate: self)
        } else {
            (cell as? LiveVideoChatMessageCell)?.updateForComment(comment, delegate: self)
        }
        return cell
    }
}

extension LiveVideoChatController: NantesLabelDelegate {
    func attributedLabel(_ label: NantesLabel, didSelectLink link: URL) {
        let handler = PrimalWebsiteScheme.shared
        if handler.canOpenURL(link) {
            dismiss(animated: true) {
                handler.openURL(link)
            }
        } else {
            present(SFSafariViewController(url: link), animated: true)
        }
    }
}

private extension LiveVideoChatController {
    func setZaps(_ zaps: [ParsedZap]) {
        post.zaps = zaps.sorted(by: {
            guard $0.amountSats == $1.amountSats else { return $0.amountSats > $1.amountSats }
            
            return $0.createdAt < $1.createdAt
        })
        self.zapsInfoVC.reloadZaps()
    }
    
    func addZap(_ zap: ParsedZap) {
        post.zaps.append(zap)
        post.zaps.sort(by: {
            guard $0.amountSats == $1.amountSats else { return $0.amountSats > $1.amountSats }
            
            return $0.createdAt < $1.createdAt
        })
        WalletManager.instance.zapEvent.send(zap)
        DispatchQueue.main.async {
            self.zapsInfoVC.reloadZaps()
        }
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
        
        let user = Self.userCache[pubkey] ?? ParsedUser(data: .init(pubkey: pubkey))
        let message: String = event["content"]?.stringValue ?? ""
        
        return ParsedLiveComment(user: user, comment: parsedComment(message, isZap: true), event: event, zapAmount: amount)
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
        
        let user = Self.userCache[pubkey] ?? ParsedUser(data: .init(pubkey: pubkey))
        let message: String = event["content"]?.stringValue ?? ""
        let receiptId = event["id"]?.stringValue ?? ""
        let createdAt = event["created_at"]?.doubleValue ?? 0
        
        return ParsedZap(receiptId: receiptId, postId: post.post.id, amountSats: amount, message: message, createdAt: createdAt, user: user)
    }
    
    func requestChat() {
        SocketRequest(name: "live_feed", payload: [
            "kind": .number(30311),
            "pubkey": .string(live.event.creatorPubkey),
            "identifier": .string(live.event.dTag),
            "user_pubkey": .string(IdentityManager.instance.userHexPubkey),
            "content_moderation_mode": .string(isFilteringOn ? "moderated" : "all")
        ])
        .publisher()
        .sink { [weak self] res in
            guard let self else { return }
            
            let zapReceipts = res.zapReceipts
            let commentEvents = res.events.filter { Int($0["kind"]?.doubleValue ?? 0) == NostrKind.liveComment.rawValue }
            
            var pubkeys: [String] = res.zapReceipts.compactMap { $0.value.objectValue?["pubkey"]?.stringValue }
            pubkeys += commentEvents.compactMap { $0["pubkey"]?.stringValue }
            pubkeys += res.zapReceipts.flatMap { $0.value.objectValue?["content"]?.stringValue?.extractUserMentionsAsPubkeys() ?? [] }
            pubkeys += commentEvents.flatMap { $0["content"]?.stringValue?.extractUserMentionsAsPubkeys() ?? [] }
            pubkeys = pubkeys.unique().filter({ Self.userCache[$0] == nil })
            
            let splitPubkeys = pubkeys.splitInSubArrays(into: max(1, pubkeys.count / 50))
            
            let publishers = splitPubkeys.map { SocketRequest(name: "user_infos", payload: ["pubkeys": .array($0.map({ .string($0) }))]).publisher().map({ $0.getSortedUsers() }).eraseToAnyPublisher() }
            let first = publishers.first ?? SocketRequest(name: "user_infos", payload: ["pubkeys": .array(pubkeys.map({ .string($0) }))]).publisher().map({ $0.getSortedUsers() }).eraseToAnyPublisher()
            
            let sequenced = publishers.dropFirst()
                .reduce(first) { acc, next in
                    acc.append(next).eraseToAnyPublisher()
                }
                .collect()
                .map { $0.reduce(Array<ParsedUser>(), +) }
            
            DispatchQueue.main.async {
                sequenced
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] users in
                        guard let self else { return }
                        
                        zapsLoadingView.pause()
                        zapsLoadingView.isHidden = true
                        chatLoadingView.pause()
                        chatLoadingView.isHidden = true
                        
                        for user in users {
                            Self.userCache[user.data.pubkey] = user
                        }
                        
                        let zapComments: [ParsedLiveComment] = zapReceipts.compactMap({ self.jsonToZapComment($0.1) })
                        
                        let comments: [ParsedLiveComment] = commentEvents
                            .compactMap({ event -> ParsedLiveComment? in
                                guard
                                    let userPubkey = event["pubkey"]?.stringValue,
                                    let content = event["content"]?.stringValue
                                else { return nil }
                                
                                return .init(
                                    user: Self.userCache[userPubkey] ?? ParsedUser(data: .init(pubkey: userPubkey)),
                                    comment: self.parsedComment(content, isZap: false),
                                    event: event
                                )
                            })
                        
                        self.comments += (comments + zapComments).sorted(by: { $0.createdAt > $1.createdAt })
                        setZaps(zapReceipts.compactMap { self.jsonToZap($0.1) })
                        commentsTable.reloadData()
                    }
                    .store(in: &self.cancellables)
            }
        }
        .store(in: &cancellables)
        
        requestContinous()
    }
     
    func requestContinous() {
        continousConnection = Connection.regular.requestCacheContinous(name: "live_feed", request: .object([
            "kind": .number(30311),
            "pubkey": .string(live.event.creatorPubkey),
            "identifier": .string(live.event.dTag),
            "user_pubkey": .string(IdentityManager.instance.userHexPubkey),
            "content_moderation_mode": .string(isFilteringOn ? "moderated" : "all")
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
                
                if kind == NostrKind.livePresence.rawValue {
                    // TODO: Update the watcher count
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
                    
                    if let zapTags = zapReceipt["tags"]?.arrayValue, let amountS = zapTags.tagValueForKey("amount") {
                        amount = (Int(amountS) ?? amount) / 1000
                    }
                    
                    event = zapReceipt
                    content = zapReceipt["content"]?.stringValue?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    userPubkey = pubkey
                } else {
                    content = event["content"]?.stringValue?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    guard let pubkey = event["pubkey"]?.stringValue else { return }
                    userPubkey = pubkey
                }
                
                var pubkeysToFetch: [String] = Self.userCache[userPubkey] == nil ? [userPubkey] : []
                pubkeysToFetch += content.extractUserMentionsAsPubkeys().filter { Self.userCache[$0] == nil }
                
                if let user = Self.userCache[userPubkey], pubkeysToFetch.isEmpty {
                    self.comments.insert(ParsedLiveComment(user: user, comment: self.parsedComment(content, isZap: amount > 0), event: event, zapAmount: amount), at: 0)
                    self.commentsTable.insertRows(at: [.init(row: 0, section: 0)], with: .automatic)
                    if let zap = self.jsonToZap(.object(event)), userPubkey != IdentityManager.instance.userHexPubkey {
                        self.addZap(zap)
                    }
                    return
                }
                
                SocketRequest(name: "user_infos", payload: ["pubkeys": .array(pubkeysToFetch.map({ .string($0) }))]).publisher()
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] res in
                        guard let self else { return }
                        
                        for user in res.getSortedUsers() {
                            Self.userCache[user.data.pubkey] = user
                        }
                        
                        comments.insert(ParsedLiveComment(
                            user: Self.userCache[userPubkey] ?? .init(data: .init(pubkey: userPubkey)),
                            comment: parsedComment(content, isZap: amount > 0),
                            event: event,
                            zapAmount: amount
                        ), at: 0)
                        commentsTable.insertRows(at: [.init(row: 0, section: 0)], with: .automatic)
                        if let zap = jsonToZap(.object(event)), userPubkey != IdentityManager.instance.userHexPubkey  {
                            addZap(zap)
                        }
                    }
                    .store(in: &self.cancellables)
            }
        }
    }
}

extension LiveVideoChatController: MetadataCoding {
    func parsedComment(_ comment: String, isZap: Bool) -> NSAttributedString {
        let mentions = comment.extractMentions()
        
        var replacements: [(String, String, String)] = []
        for mention in mentions {
            if let mentionText = mention.split(separator: "/").last?.split(separator: ":").last?.string, let pubkey = (try? decodedMetadata(from: mentionText).pubkey) ?? mentionText.npubToPubkey() {
                let user = Self.userCache[pubkey] ?? .init(data: .init(pubkey: pubkey))
                let name = "@\(user.data.firstIdentifier)"
                replacements.append((mention, name, "https://primal.net/p/\(user.data.npub)"))
            }
        }
        
        return attributedStringByReplacing(
            comment,
            replacements: replacements,
            baseAttributes: [
                .font: UIFont.appFont(withSize: 15, weight: .regular),
                .foregroundColor: isZap ? UIColor.foreground : UIColor.foreground3,
            ],
            specialAttributes:  [
                .font: UIFont.appFont(withSize: 15, weight: .regular),
                .foregroundColor: isZap ? UIColor.foreground : UIColor.foreground3,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        )
    }
    
    func attributedStringByReplacing(
        _ source: String,
        replacements: [(a: String, b: String, c: String)],
        baseAttributes: [NSAttributedString.Key: Any]? = nil,
        specialAttributes: [NSAttributedString.Key: Any]? = nil,
        options: NSString.CompareOptions = []
    ) -> NSAttributedString {
        let mutable = NSMutableAttributedString(string: source, attributes: baseAttributes)

        for (a, b, c) in replacements {
            guard !a.isEmpty else { continue } // skip empty search strings

            var searchLocation = 0
            while searchLocation < mutable.length {
                let searchRange = NSRange(location: searchLocation, length: mutable.length - searchLocation)
                let foundRange = (mutable.string as NSString).range(of: a, options: options, range: searchRange)
                if foundRange.location == NSNotFound { break }

                // Use specialAttributes if provided, otherwise fall back to baseAttributes (or empty)
                var attrs = specialAttributes ?? baseAttributes ?? [:]
                attrs[.link] = URL(string: c)
                let replacementAttr = NSAttributedString(string: b, attributes: attrs)
                mutable.replaceCharacters(in: foundRange, with: replacementAttr)

                // Move past the inserted replacement
                searchLocation = foundRange.location + replacementAttr.length
            }
        }

        return mutable
    }
}
