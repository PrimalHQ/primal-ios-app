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

final class PostingTextViewManager: NSObject {
    @Published var isEditing = false
    @Published var userSearchText: String?
    
    var userScore: [String: Int] = [:]
    @Published var users: [PrimalUser] = []
    
    var tokens: [UserToken] = []
    
    var didChangeEvent = PassthroughSubject<UITextView, Never>()
    
    @Published var currentlyEditingToken: EditingToken?
    
    private var cancellables: Set<AnyCancellable> = []
    private var nextEditShouldBeManual = false
    
    let textView: UITextView
    let usersTableView: UITableView
    var usersHeightConstraint: NSLayoutConstraint!
    init(textView: UITextView, usersTable: UITableView) {
        self.textView = textView
        usersTableView = usersTable
        super.init()
        connectPublishers()
        setup()
    }
    
    func replaceEditingTokenWithUser(_ user: PrimalUser) {
        guard let currentlyEditingToken else { return }
        let replacementText = user.atIdentifier
        let newText = (textView.text as NSString).replacingCharacters(in: currentlyEditingToken.range, with: replacementText + " ")
        
        updateTokensForReplacingRange(currentlyEditingToken.range, replacementText: replacementText + " ")
        tokens.append(UserToken(
            range: .init(location: currentlyEditingToken.range.location, length: (replacementText as NSString).length),
            text: replacementText,
            user: user
        ))
        self.currentlyEditingToken = nil
        updateText(newText, cursorPosition: currentlyEditingToken.range.location + (replacementText as NSString).length + 1)
        nextEditShouldBeManual = true
    }
    
    var postingText: String {
        var tokens = self.tokens
        var currentText = textView.text as NSString
        
        for i in tokens.indices {
            let token = tokens[i]
            let replacement = "nostr:\(token.user.npub)"
            currentText = currentText.replacingCharacters(in: token.range, with: replacement) as NSString
            tokens = updateTokensForReplacingRange(tokens: tokens, range: token.range, replacementText: replacement)
        }
        
        return currentText as String
    }
    
    var mentionedUsersPubkeys: [String] {
        tokens.map { $0.user.pubkey }
    }
}

extension PostingTextViewManager: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        isEditing = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        isEditing = false
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textView.invalidateIntrinsicContentSize() // Necessary for self sizing text field
        didChangeEvent.send(textView)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let oldText = textView.text as NSString
        let newText = oldText.replacingCharacters(in: range, with: text) as NSString
        let replacementText = text as NSString
        
        let cursorPosition = range.location + replacementText.length
        
        if var currentlyEditingToken {
            let doesOverlap = range.overlaps(currentlyEditingToken.range) && range.location > currentlyEditingToken.range.location
            let isContinuing = range.location == currentlyEditingToken.range.endLocation
            
            if doesOverlap || isContinuing {
                currentlyEditingToken.range.length += replacementText.length - range.length
                
                if currentlyEditingToken.range.length > 0 {
                    currentlyEditingToken.text = newText.substring(with: currentlyEditingToken.range)
                    self.currentlyEditingToken = currentlyEditingToken
                    nextEditShouldBeManual = true
                } else {
                    self.currentlyEditingToken = nil
                    nextEditShouldBeManual = true
                }
            } else {
                self.currentlyEditingToken = nil
                nextEditShouldBeManual = true
            }
        }
        
        for (index, token) in tokens.enumerated() {
            if range.overlaps(token.range) {
                guard range != token.range else {
                    tokens.remove(at: index)
                    updateTokensForReplacingRange(range, replacementText: text)
                    updateText(newText as String, cursorPosition: cursorPosition)
                    return false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                    textView.selectedRange = token.range
                }
                return false
            }
            
            if token.range.endLocation == range.location || range.endLocation == token.range.location {
                nextEditShouldBeManual = true
            }
        }
        
        if text == " ", currentlyEditingToken != nil { // End searching if we were searching
            currentlyEditingToken = nil
            updateTokensForReplacingRange(range, replacementText: text)
            updateText(newText as String, cursorPosition: cursorPosition)
            return false
        }
        
        if text == "@" { // Start new user search
            currentlyEditingToken = .init(range: NSRange(location: range.location, length: 1), text: text)
            updateTokensForReplacingRange(range, replacementText: text)
            updateText(newText as String, cursorPosition: cursorPosition)
            return false
        }
        
        if text == "" {
            nextEditShouldBeManual = true
        }
        
        if nextEditShouldBeManual {
            nextEditShouldBeManual = text == ""
            updateTokensForReplacingRange(range, replacementText: text)
            updateText(newText as String, cursorPosition: cursorPosition)
            return false
        }
        
        updateTokensForReplacingRange(range, replacementText: text)
        return true
    }
}

private extension PostingTextViewManager {
    func updateTokensForReplacingRange(_ range: NSRange, replacementText: String) {
        for i in tokens.indices where tokens[i].range.location >= range.location {
            tokens[i].range.location += (replacementText as NSString).length - range.length
        }
    }
    
    func updateTokensForReplacingRange(tokens: [UserToken], range: NSRange, replacementText: String) -> [UserToken] {
        var tokens = tokens
        for i in tokens.indices where tokens[i].range.location >= range.location {
            tokens[i].range.location += (replacementText as NSString).length - range.length
        }
        return tokens
    }
    
    func updateText(_ text: String, cursorPosition: Int) {
        let mutable = NSMutableAttributedString(string: text as String, attributes: [
            .font: textView.font as Any,
            .foregroundColor: UIColor.foreground as Any
        ])
        
        for token in tokens {
            mutable.addAttributes([.foregroundColor: UIColor.accent], range: token.range)
        }
        
        if let range = currentlyEditingToken?.range {
            mutable.addAttributes([.foregroundColor: UIColor.accent], range: range)
        }
        
        textView.attributedText = mutable
        textView.selectedRange = .init(location: cursorPosition, length: 0)
    }
    
    func connectPublishers() {
        $currentlyEditingToken
            .map { token in
                guard let token else { return nil }
                
                return token.text.hasPrefix("@") ? (token.text as NSString).substring(from: 1) : nil
            }
            .assign(to: \.userSearchText, onWeak: self)
            .store(in: &cancellables)
        
        $userSearchText
            .flatMap { text -> AnyPublisher<PostRequestResult, Never> in
                switch text {
                case nil:
                    return Just(.init()).eraseToAnyPublisher()
                case "":
                    return SocketRequest(name: "user_infos", payload: .object([
                        "pubkeys": .array(Self.recommendedUsersNpubs.map { .string($0) })
                    ])).publisher()
                default:
                   return SocketRequest(name: "user_search", payload: .object([
                       "query": .string(text ?? ""),
                       "limit": .number(15),
                   ])).publisher()
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                self?.userScore = result.userScore
                self?.users = Array(result.users.values).sorted(by: {
                    result.userScore[$0.pubkey] ?? 0 > result.userScore[$1.pubkey] ?? 0
                })
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
        let user = users[indexPath.row]
        (cell as? UserInfoTableCell)?.update(user: user, count: userScore[user.pubkey])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        replaceEditingTokenWithUser(users[indexPath.row])
    }
}

extension PostingTextViewManager {
    static var recommendedUsersNpubs: [String] { [
        "82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2", // jack
        "bf2376e17ba4ec269d10fcc996a4746b451152be9031fa48e74553dde5526bce", // carla
        "c48e29f04b482cc01ca1f9ef8c86ef8318c059e0e9353235162f080f26e14c11", // walker
        "85080d3bad70ccdcd7f74c29a44f55bb85cbcd3dd0cbb957da1d215bdb931204", // preston
        "eab0e756d32b80bcd464f3d844b8040303075a13eabc3599a762c9ac7ab91f4f", // lyn
        "04c915daefee38317fa734444acee390a8269fe5810b2241e5e6dd343dfbecc9", // odell
        "472f440f29ef996e92a186b8d320ff180c855903882e59d50de1b8bd5669301e", // marty
        "e88a691e98d9987c964521dff60025f60700378a4879180dcbbb4a5027850411", // nvk
        "91c9a5e1a9744114c6fe2d61ae4de82629eaaa0fb52f48288093c7e7e036f832", // rockstar
        "fa984bd7dbb282f07e16e7ae87b26a2a7b9b90b7246a44771f0cf5ae58018f52", // pablo
    ] }
}
