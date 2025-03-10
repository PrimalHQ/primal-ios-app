//
//  PostingTextViewManager.swift
//  Primal
//
//  Created by Pavle D Stevanović on 24.5.23..
//

import Combine
import UIKit
import GenericJSON
import NostrSDK

struct EditingToken {
    var range: NSRange
    var text: String
}

struct UserToken {
    var range: NSRange
    var text: String
    var user: PrimalUser
}

extension NoteDraft {
    var isPosting: Bool { preparedEvent != nil }
}

final class PostingTextViewManager: TextViewManager, MetadataCoding {
    @Published var userSearchText: String?
    @Published var users: [ParsedUser] = []
    @Published var isPosting: Bool = false
    
    @Published var postButtonEnabledState = true
    @Published var postButtonTitle: String
    
    @Published var oldDraft: NoteDraft?
    
    let defaultPostButtonTitle: String
    
    var tokens: [UserToken] {
        get {
            guard let string = textView.attributedText else { return [] }
            
            let entireRange = NSRange(location: 0, length: string.length)
            
            var tokens: [UserToken] = []
            string.enumerateAttribute(.link, in: entireRange) { (value, linkRange, stop) in
                guard let user = value as? PrimalUser else { return }
                
                tokens.append(.init(range: linkRange, text: string.attributedSubstring(from: linkRange).string, user: user))
            }
            return tokens
        }
        set {
            let mutable = NSMutableAttributedString(string: textView.text ?? "", attributes: [
                .font: UIFont.appFont(withSize: 18, weight: .regular),
                .foregroundColor: UIColor.foreground
            ])
            
            for token in newValue {
                mutable.addAttributes([
                    .foregroundColor: UIColor.accent,
                    .link: token.user
                ], range: token.range)
            }
            textView.attributedText = mutable
        }
    }
    
    @Published private var currentlyEditingToken: EditingToken?
    
    let returnPressed = PassthroughSubject<Void, Never>()
    
    let usersTableView: UITableView
    var usersHeightConstraint: NSLayoutConstraint!
    let replyId: String?
    var replyingTo: PrimalFeedPost? {
        didSet {
            findDraft()
        }
    }
    
    private var tagRegex: NSRegularExpression! { try! NSRegularExpression(pattern: "@([^\\s\\K]+)") }
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(textView: UITextView, usersTable: UITableView, replyId: String?, replyingTo: PrimalFeedPost?, defaultPostTitle: String = "Post") {
        usersTableView = usersTable
        self.replyingTo = replyingTo
        self.replyId = replyId
        defaultPostButtonTitle = defaultPostTitle
        postButtonTitle = defaultPostTitle
        super.init(textView: textView)
        connectPublishers()
        setup()
        
        if replyId == nil {
            findDraft()
        }
    }
    
    func replaceEditingTokenWithUser(_ user: ParsedUser) {
        SmartContactsManager.instance.addContact(user)
        
        guard let currentlyEditingToken else { return }
        
        let user = user.data
        let replacementText = user.atIdentifier
        
        var mutable = NSMutableAttributedString(attributedString: textView.attributedText ?? .init())
        mutable.replaceCharacters(in: currentlyEditingToken.range, with: "")
        mutable.insert(NSAttributedString(string: replacementText, attributes: [
            .font: UIFont.appFont(withSize: 18, weight: .regular),
            .foregroundColor: UIColor.accent,
            .link: user
        ]), at: currentlyEditingToken.range.location)
        
        addUnattributedText(" ", to: &mutable, inRange: .init(location: currentlyEditingToken.range.location + replacementText.utf16.count, length: 0))
        
        updateText(mutable, cursorPosition: currentlyEditingToken.range.location + replacementText.utf16.count + 1)
        self.currentlyEditingToken = nil
    }
    
    override var postingText: String {
        var currentText = (textView.text ?? "") as NSString
        
        var tokens = self.tokens
        
        for i in tokens.indices {
            let token = tokens[i]
        
            let replacement = "nostr:\(RelayHintManager.instance.encodeUserWithRelays(token.user))"
            
            if currentText.length < token.range.endLocation {
                print("TEXT LENGTH: \(currentText.length)")
                break
            }
            
            currentText = currentText.replacingCharacters(in: token.range, with: replacement) as NSString
            tokens = updateTokensForReplacingRange(tokens: tokens, range: token.range, replacementText: replacement)
        }
        
        for image in media {
            guard case .uploaded(let url) = image.state else { continue }
            currentText = currentText.appending("\n" + url) as NSString
        }
        
        return currentText as String
    }
    
    var mentionedUsersPubkeys: [String] {
        tokens.map { $0.user.pubkey }
    }
    
    @objc func atButtonPressed() {
        let range = textView.selectedRange
        if textView(textView, shouldChangeTextIn: range, replacementText: "@") {
            var mutable = NSMutableAttributedString(attributedString: textView.attributedText ?? .init())
            addUnattributedText("@", to: &mutable, inRange: range)
            
            updateText(mutable, cursorPosition: range.location + 1)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let attributedString = textView.attributedText else {
            return true     // If we cannot get an attributed string, just fail gracefully and allow changes
        }
        var mutable = NSMutableAttributedString(attributedString: attributedString)
        
        let entireRange = NSRange(location: 0, length: attributedString.length)
        var shouldAllowChange = true
        var performEditActionManually = false

        attributedString.enumerateAttribute(.link, in: entireRange, options: []) { (value, linkRange, stop) in
            guard value != nil else {
                return  // This range is not a link. Skip checking.
            }
            
            if range.contains(linkRange.upperBound) && range.contains(linkRange.lowerBound) {
                // Edit range engulfs all of this link's range.
                // This link will naturally disappear, so no work needs to be done in this range.
                return
            }
            else if linkRange.intersection(range) != nil {
                // If user tries to change an existing link directly, remove the link attribute
                mutable.removeAttribute(.link, range: linkRange)
                mutable.addAttribute(.foregroundColor, value: UIColor.foreground, range: linkRange)
                // Perform action manually to flush above changes to the view, and to prevent the character being added from having an attributed link property
                performEditActionManually = true
                return
            }
            else if range.location == linkRange.location + linkRange.length && range.length == 0 {
                // If we are inserting a character at the right edge of a link, UITextInput tends to include the new character inside the link.
                // Therefore, we need to manually append that character outside of the link
                performEditActionManually = true
                return
            }
        }
        
        if performEditActionManually {
            shouldAllowChange = false
            addUnattributedText(text, to: &mutable, inRange: range)
            
            updateText(mutable, cursorPosition: range.location + text.count)
        }

        return shouldAllowChange
    }
    
    func addUnattributedText(_ text: String, to attributedString: inout NSMutableAttributedString, inRange range: NSRange) {
        if range.length > 0 {
            attributedString.replaceCharacters(in: range, with: "")
        }
        
        attributedString.insert(NSAttributedString(string: text, attributes: [
            .font: UIFont.appFont(withSize: 18, weight: .regular),
            .foregroundColor: UIColor.foreground
        ]), at: range.location)
    }
    
    var currentDraft: NoteDraft {
        NoteDraft(
            replyingTo: replyingTo?.universalID ?? "",
            userPubkey: IdentityManager.instance.userHexPubkey,
            text: textView.text ?? "",
            uploadedAssets: media.compactMap { $0.state.url },
            taggedUsers: tokens.map({ token in
                    .init(
                        range: .init(location: token.range.location, length: token.range.length),
                        text: token.text,
                        userPubkey: token.user.pubkey
                    )
            })
        )
    }
    
    func askToSave(_ vc: UIViewController, callback: @escaping (Bool) -> Void = { _ in }) {        
        let draft = currentDraft
        
        if let oldDraft {
            if oldDraft.text == draft.text && oldDraft.uploadedAssets == draft.uploadedAssets {
                callback(false)
                return
            }
        } else if textView.text.isEmpty == true {
            callback(false)
            return
        }
        
        textView.resignFirstResponder()
        
        let alert = UIAlertController(title: "Save note draft?", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: { [weak self] _ in
            self?.oldDraft = nil
            self?.textView.text = ""
            callback(false)
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
            DatabaseManager.instance.saveDraft(draft)
            self?.oldDraft = draft
            callback(true)
        }))
        
        vc.present(alert, animated: true, completion: nil)
    }
    
    func askToSaveThenDismiss(_ vc: UIViewController) {
        askToSave(vc) { [weak vc] _ in
            vc?.backButtonPressed()
        }
    }
    
    func askToDeleteDraft(_ vc: UIViewController, callback: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "Do you want to start a new draft?", message: "Old draft will probably be posted.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: { _ in callback(false) }))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
            guard let self else { return }
            deleteDraft()
            reset()
            // TODO: Cancel posting
            callback(true)
        }))
        
        vc.present(alert, animated: true, completion: nil)
    }
    
    func deleteDraft() {
        DatabaseManager.instance.deleteDraft(replyingTo: replyingTo?.universalID)
    }
    
    func reset() {
        oldDraft = nil
        isPosting = false
        postButtonTitle = defaultPostButtonTitle
        postButtonEnabledState = true
        
        textView.text = ""
        media = []
    }
    
    func post(callback: @escaping (Bool, NostrObject?) -> Void) {
        var draft = currentDraft
        
        guard let ev = NostrObject.post(draft, postingText: postingText, replyingToObject: replyingTo) else {
            callback(false, nil)
            return
        }
        
        isPosting = true
        draft.preparedEvent = ev
        oldDraft = draft
        DatabaseManager.instance.saveDraft(draft)
        
        PostingManager.instance.sendEvent(ev) { success in
            callback(success, ev)
            if success {
                DatabaseManager.instance.deleteDraft(draft)
            }
        }
    }
    
    var currentSearchPublisher: AnyCancellable?
}

private extension PostingTextViewManager {
    func updateTokensForReplacingRange(tokens: [UserToken], range: NSRange, replacementText: String) -> [UserToken] {
        var tokens = tokens
        for i in tokens.indices where tokens[i].range.location >= range.location {
            tokens[i].range.location += replacementText.utf16.count - range.length
        }
        return tokens
    }
    
    func updateText(_ text: NSAttributedString? = nil, cursorPosition: Int? = nil) {
        let selection = textView.selectedRange
        
        if let text {
            textView.attributedText = text
        }
        
        if let cursorPosition {
            textView.selectedRange = .init(location: cursorPosition, length: 0)
        } else {
            textView.selectedRange = selection
        }
        
        didChangeEvent.send(textView)
    }
    
    func processFocusedWordForMention() {
        guard
            let selectedRange = textView.selectedTextRange,
            let wordRange = rangeOfMention(in: textView, from: selectedRange.start),
            let startPosition = textView.position(from: wordRange.start, offset: -1),
            let newRange = textView.textRange(from: startPosition, to: selectedRange.start),
            let word = textView.text(in: newRange),
            let nsRange = textView.convertToNSRange(startPosition, selectedRange.start)
        else {
            currentlyEditingToken = nil
            return
        }
        
        if startPosition != textView.beginningOfDocument, 
           let charBeforePosition = textView.position(from: startPosition, offset: -1),
           let charBeforeRange = textView.textRange(from: charBeforePosition, to: startPosition),
           let charBefore = textView.text(in: charBeforeRange),
           charBefore.first?.isWhitespace == false
        {
            currentlyEditingToken = nil
            return
        }
        
        currentlyEditingToken = .init(range: nsRange, text: word)
    }
    
    func rangeOfMention(in textView: UITextView, from position: UITextPosition) -> UITextRange? {
        var startPosition = position
        
        while startPosition != textView.beginningOfDocument {
            guard let previousPosition = textView.position(from: startPosition, offset: -1),
                  let range = textView.textRange(from: previousPosition, to: startPosition),
                  let text = textView.text(in: range), !text.isEmpty,
                  let lastChar = text.last else {
                break
            }

            if [" ", "\n", "@"].contains(lastChar) {
                return textView.textRange(from: startPosition, to: position)
            }

            startPosition = previousPosition
        }

        return nil
    }
    
    func connectPublishers() {
        didChangeEvent.sink { [weak self] _ in
            self?.processFocusedWordForMention()
        }
        .store(in: &cancellables)
        
        $currentlyEditingToken
            .map { token in
                guard let token else { return nil }
                
                return token.text.hasPrefix("@") ? (token.text as NSString).substring(from: 1) : nil
            }
            .assign(to: \.userSearchText, onWeak: self)
            .store(in: &cancellables)
        
        $userSearchText
            .sink(receiveValue: { [weak self] text in
                guard let text else {
                    self?.currentSearchPublisher = nil
                    self?.users = []
                    self?.usersTableView.reloadData()
                    return
                }
                self?.currentSearchPublisher = SmartContactsManager.instance.userSearchPublisher(text)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: { users in
                        self?.users = users
                        self?.usersTableView.reloadData()
                    })
            })
            .store(in: &cancellables)
        
        Publishers.CombineLatest4($media, $isEmpty.removeDuplicates(), $oldDraft, $isPosting)
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .sink { [weak self] images, isEmpty, oldDraft, isPosting in
                guard let self else { return }
                
                if oldDraft?.preparedEvent != nil || isPosting {
                    postButtonEnabledState = false
                    postButtonTitle = "Posting..."
                    return
                }
                
                let isUploadingImages: Bool = {
                    for image in images {
                        if case .uploading = image.state {
                            return true
                        }
                    }
                    return false
                }()
                
                postButtonEnabledState = (!isEmpty || !images.isEmpty) && !isUploadingImages
                postButtonTitle = isUploadingImages ? "Uploading..." : defaultPostButtonTitle
            }
            .store(in: &cancellables)

        $isPosting.sink { [weak self] isPosting in
            guard let self else { return }
            textView.isEditable = !isPosting
        }
        .store(in: &cancellables)
        
        PostingManager.instance.postedEvent.sink { [weak self] obj in
            guard let self, obj.id == oldDraft?.preparedEvent?.id else { return }
            // Successfully posted from the background
            reset()
        }
        .store(in: &cancellables)
    }
    
    func setup() {
        textView.font = .appFont(withSize: 18, weight: .regular)
        textView.textColor = .foreground
        textView.backgroundColor = .background2
        textView.delegate = self
        textView.bounces = false
        
        usersTableView.register(UserInfoTableCell.self, forCellReuseIdentifier: "cell")
        usersTableView.delegate = self
        usersTableView.dataSource = self
        usersTableView.separatorStyle = .none
        usersTableView.bounces = false
        
        usersHeightConstraint = usersTableView.heightAnchor.constraint(equalToConstant: 60)
        usersHeightConstraint.priority = .defaultHigh
        usersHeightConstraint.isActive = true
    }
    
    func findDraft() {
        DatabaseManager.instance.findDraft(replyingTo: replyId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] draft in
                guard let self, let draft else { return }
                if textView.text?.isEmpty == false, let text = textView.text {
                    let vc = (RootViewController.instance.presentedViewController ?? RootViewController.instance)
                    let alert = UIAlertController(title: "Discard the draft and start a new note?", message: nil, preferredStyle: .alert)
                    alert.addAction(.init(title: "Cancel", style: .cancel))
                    alert.addAction(.init(title: "OK", style: .destructive, handler: { [weak self] _ in
                        self?.reset()
                        self?.textView.text = text
                        self?.textView.selectedRange = .init(location: 0, length: 0)
                    }))
                    vc.show(alert, sender: nil)
                }
                
                oldDraft = draft
                
                textView.text = draft.text
                isEmpty = draft.text.isEmpty
                isPosting = draft.isPosting
                
                tokens = draft.taggedUsers.map({ token in
                    .init(
                        range: .init(location: token.range.location, length: token.range.length),
                        text: token.text,
                        user: .init(pubkey: token.userPubkey)
                    )
                })
                
                media = draft.uploadedAssets.map { .init(resource: nil, state: .uploaded($0)) }
                
                didChangeEvent.send(textView)
            }
            .store(in: &cancellables)
    }
}

extension PostingTextViewManager: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let user = users[safe: indexPath.row] {
            (cell as? UserInfoTableCell)?.update(user: user)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let data = users[safe: indexPath.row] else { return }
        replaceEditingTokenWithUser(data)
    }
}
