//
//  PostingTextViewManager.swift
//  Primal
//
//  Created by Pavle D Stevanović on 24.5.23..
//

import Combine
import UIKit
import GenericJSON

struct EditingToken {
    var range: NSRange
    var text: String
}

struct UserToken {
    var range: NSRange
    var text: String
    var user: PrimalUser
}

final class PostingTextViewManager: TextViewManager {
    @Published var userSearchText: String?
    
    @Published var users: [ParsedUser] = []
    
    var tokens: [UserToken] {
        guard let string = textView.attributedText else { return [] }
        
        let entireRange = NSRange(location: 0, length: string.length)
        
        var tokens: [UserToken] = []
        string.enumerateAttribute(.link, in: entireRange) { (value, linkRange, stop) in
            guard let user = value as? PrimalUser else { return }
            
            tokens.append(.init(range: linkRange, text: string.attributedSubstring(from: linkRange).string, user: user))
        }
        return tokens
    }
    
    @Published var currentlyEditingToken: EditingToken?
    let returnPressed = PassthroughSubject<Void, Never>()
    
    private var tagRegex: NSRegularExpression! { try! NSRegularExpression(pattern: "@([^\\s\\K]+)") }
    
    private var cancellables: Set<AnyCancellable> = []
    
    let usersTableView: UITableView
    var usersHeightConstraint: NSLayoutConstraint!
    init(textView: UITextView, usersTable: UITableView) {
        usersTableView = usersTable
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
            let replacement = "nostr:\(token.user.npub)"
            
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
            let cursorPosition = textView.position(from: selectedRange.start, offset: 0),
            let newRange = textView.textRange(from: startPosition, to: cursorPosition),
            let word = textView.text(in: newRange),
            let nsRange = textView.convertToNSRange(startPosition, cursorPosition)
        else {
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
            .flatMap {
                if let text = $0 {
                    return SmartContactsManager.instance.userSearchPublisher(text)
                }
                return Just([]).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] users in
                self?.users = users
                self?.usersTableView.reloadData()
            })
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
