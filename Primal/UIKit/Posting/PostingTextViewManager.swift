//
//  PostingTextViewManager.swift
//  Primal
//
//  Created by Pavle D Stevanović on 24.5.23..
//

import Combine
import UIKit

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
        var currentText = textView.text as NSString
        
        for token in tokens {
            currentText = currentText.replacingCharacters(in: token.range, with: "nostr:\(token.user.npub)") as NSString
        }
        
        return currentText as String
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
                    return SocketRequest(name: "user_search", payload: .object([
                        "query": .string(""),
                        "limit": .number(15),
                        "pubkey": .string(IdentityManager.instance.userHex)
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
                self?.users = Array(result.users.values).sorted(by: { $0.firstIdentifier.lowercased() < $1.firstIdentifier.lowercased() })
            })
            .store(in: &cancellables)
    }
    
    func setup() {
        textView.font = .appFont(withSize: 18, weight: .regular)
        textView.textColor = .foreground
        textView.backgroundColor = .background2
        textView.delegate = self
        textView.keyboardType = .emailAddress
        textView.bounces = false
        
        usersTableView.register(UserInfoTableCell.self, forCellReuseIdentifier: "cell")
        usersTableView.delegate = self
        usersTableView.dataSource = self
        usersTableView.separatorStyle = .none
        
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
