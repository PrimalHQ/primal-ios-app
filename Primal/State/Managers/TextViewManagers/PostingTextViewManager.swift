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
    
    var tokens: [UserToken] = []
    
    @Published var currentlyEditingToken: EditingToken?
    let returnPressed = PassthroughSubject<Void, Never>()
    
    private var cancellables: Set<AnyCancellable> = []
    
    let usersTableView: UITableView
    var usersHeightConstraint: NSLayoutConstraint!
    init(textView: UITextView, usersTable: UITableView) {
        usersTableView = usersTable
        super.init(textView: textView)
        connectPublishers()
        setup()
    }
    
    func replaceEditingTokenWithUser(_ user: PrimalUser) {
        guard let currentlyEditingToken else { return }
        let replacementText = user.atIdentifier
        let newText = (textView.text as NSString).replacingCharacters(in: currentlyEditingToken.range, with: replacementText + " ")
        let maxLength = (newText as NSString).length
        updateTokensForReplacingRange(currentlyEditingToken.range, replacementText: replacementText + " ", maxRange: maxLength)
        tokens.append(UserToken(
            range: .init(location: currentlyEditingToken.range.location, length: (replacementText as NSString).length),
            text: replacementText,
            user: user
        ))
        self.currentlyEditingToken = nil
        updateText(newText, cursorPosition: currentlyEditingToken.range.location + (replacementText as NSString).length + 1)
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
        
        for image in images {
            guard case .uploaded(let url) = image.state else { continue }
            currentText = currentText.appending("\n" + url) as NSString
        }
        
        return currentText as String
    }
    
    var mentionedUsersPubkeys: [String] {
        tokens.map { $0.user.pubkey }
    }
    
    @objc func atButtonPressed() {
        _ = textView(textView, shouldChangeTextIn: textView.selectedRange, replacementText: "@")
    }
    
    var declineAnyChange = false
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if declineAnyChange { return false }
        
        let oldText = textView.text as NSString
        let newText = oldText.replacingCharacters(in: range, with: text) as NSString
        let replacementText = text as NSString
        
        if text.containsOnlyEmoji {
            // This is a workaround for issue 69 - https://github.com/PrimalHQ/primal-ios-app/issues/69
            DispatchQueue.main.async {
                UIView.setAnimationsEnabled(false)
                textView.resignFirstResponder()
                textView.becomeFirstResponder()
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                    UIView.setAnimationsEnabled(true)
                }
            }
        }
        
        let cursorPosition = range.location + replacementText.length
        
        if var currentlyEditingToken {
            let doesOverlap = range.overlaps(currentlyEditingToken.range) && (range.location > currentlyEditingToken.range.location || range.length > 0)
            let isContinuing = range.location == currentlyEditingToken.range.endLocation
            
            if doesOverlap || isContinuing {
                currentlyEditingToken.range.length += replacementText.length - range.length
                
                if currentlyEditingToken.range.length > 0 {
                    currentlyEditingToken.text = newText.substring(with: currentlyEditingToken.range)
                    self.currentlyEditingToken = currentlyEditingToken
                } else {
                    self.currentlyEditingToken = nil
                }
            } else {
                self.currentlyEditingToken = nil
            }
        }
        
        
        let updateManually = {
            self.declineAnyChange = true
            self.updateTokensForReplacingRange(range, replacementText: text, maxRange: newText.length)
            self.updateText(newText as String, cursorPosition: cursorPosition)
            self.declineAnyChange = false
            self.textViewDidChange(textView)
        }
        
        for (index, token) in tokens.enumerated() {
            if range.overlaps(token.range) {
                guard range != token.range else {
                    tokens.remove(at: index)
                    updateManually()
                    return false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                    textView.selectedRange = token.range
                }
                return false
            }
        }
        
        switch text {
        case "\n":
            returnPressed.send(())
            fallthrough
        case " ":
            if currentlyEditingToken != nil { // End searching if we were searching
                currentlyEditingToken = nil
            }
        case "@":  // Start new user search
            currentlyEditingToken = .init(range: NSRange(location: range.location, length: 1), text: text)
        default:
            break
        }
        
        updateManually()
        return false
    }
}

private extension PostingTextViewManager {
    func updateTokensForReplacingRange(_ range: NSRange, replacementText: String, maxRange: Int) {
        let adjustLength = (replacementText as NSString).length - range.length
        for i in tokens.indices where tokens[i].range.location >= range.location {
            tokens[i].range.location += adjustLength
        }
    }
    
    func rangeMatchesTokens(_ range: NSRange) -> Bool {
        for t in tokens {
            if t.range.location >= range.location && t.range.location <= range.endLocation {
                return true
            }
            
            if t.range.endLocation >= range.location && t.range.endLocation <= range.endLocation {
                return true
            }
        }
        
        return false
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
                guard self?.userSearchText != nil else {
                    self?.users = []
                    self?.usersTableView.reloadData()
                    return
                }
                
                self?.users = result.users.values.map { result.createParsedUser($0) } .sorted(by: {
                    $0.likes ?? 0 > $1.likes ?? 0
                })
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
        textView.autocapitalizationType = .none
        
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
        guard let data = users[safe: indexPath.row]?.data else { return }
        replaceEditingTokenWithUser(data)
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
