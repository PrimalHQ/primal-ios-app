//
//  LiveChatTextViewManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 15. 8. 2025..
//

import Combine
import NostrSDK
import UIKit

final class LiveChatTextViewManager: TextViewManager, MetadataCoding {
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
    
    let usersTableView: UsersTableView
    let sendButton: UIButton
    let live: ParsedLiveEvent
    
    private var tagRegex: NSRegularExpression! { try! NSRegularExpression(pattern: "@([^\\s\\K]+)") }
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(textView: UITextView, usersTable: UsersTableView, sendButton: UIButton, live: ParsedLiveEvent) {
        usersTableView = usersTable
        self.sendButton = sendButton
        self.live = live
        
        super.init(textView: textView)
        connectPublishers()
        setup()
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
    
    func reset() {
        textView.text = ""
        media = []
    }
    
    func post() {
        let postingText = postingText
        guard
            !postingText.isEmpty,
            let ev = NostrObject.liveComment(live: live.event, comment: postingText)
        else { return }
        
        textView.text = ""
        
        PostingManager.instance.sendEvent(ev, { _ in })
    }
}

private extension LiveChatTextViewManager {
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
    
    func connectPublishers() {
        didChangeEvent.sink { [weak self] _ in
            self?.processFocusedWordForMention()
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest($isEditing, $currentlyEditingToken)
            .map { isEditing, token in
                guard isEditing, let token else { return nil }
                
                return token.text.hasPrefix("@") ? (token.text as NSString).substring(from: 1) : nil
            }
            .assign(to: \.userSearchText, onWeak: usersTableView)
            .store(in: &cancellables)
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
    
    func setup() {
        textView.font = .appFont(withSize: 16, weight: .regular)
        textView.textColor = .foreground
        textView.backgroundColor = .clear
        textView.delegate = self
        textView.bounces = false
        
        usersTableView.delegate = self
        
        $isEmpty.removeDuplicates().assign(to: \.isHidden, onWeak: sendButton).store(in: &cancellables)
        
        sendButton.addAction(.init(handler: { [weak self] _ in
            self?.post()
        }), for: .touchUpInside)
    }
}

extension LiveChatTextViewManager: UsersTableViewDelegate {
    func usersTableDidSelectUser(_ table: UsersTableView, user: ParsedUser) {
        replaceEditingTokenWithUser(user)
    }
}
