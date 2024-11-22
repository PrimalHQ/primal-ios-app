//
//  HighlightUsersView.swift
//  Primal
//
//  Created by Pavle Stevanović on 18.7.24..
//

import UIKit
import FLAnimatedImage

class HighlightUsersView: UIView {
    var users: [ParsedUser] {
        didSet {
            update()
        }
    }
    
    let userStack = UIStackView()
    
    let label = UILabel()
    
    init(users: [ParsedUser]) {
        self.users = users
        super.init(frame: .zero)
        setup()
    }
    
    func setup() {
        let image = UIImageView(image: UIImage(named: "highlightIcon30"))
        image.tintColor = .foreground
        
        let vStack = UIStackView(axis: .vertical, [userStack])
        vStack.spacing = 4
        vStack.alignment = .leading
        
        userStack.spacing = 4
        
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 2
        vStack.addArrangedSubview(label)
        
        addSubview(vStack)
        vStack
            .pinToSuperview(edges: .leading, padding: 58)
            .pinToSuperview(edges: .trailing, padding: 20)
            .pinToSuperview(edges: .vertical, padding: 12)
        
        addSubview(image)
        image.pinToSuperview(edges: .leading, padding: 20).pinToSuperview(edges: .top, padding: 12).constrainToSize(30)
        
        update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update() {
        userStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        var userList: [ParsedUser] = []
        
        if let current = users.first(where: { $0.isCurrentUser }) {
            userList = [current] + users.filter({ !$0.isCurrentUser }).prefix(5)
        } else {
            userList = Array(users.prefix(6))
        }
        
        userList.forEach { user in
            let view = HighlighUserAvatarView(user: user)
            userStack.addArrangedSubview(view)
        }
        
        if let first = userList.first {
            let text = NSMutableAttributedString(string: first.isCurrentUser ? "You" : first.data.atIdentifierWithoutAt, attributes: [
                .font: UIFont.appFont(withSize: 15, weight: .bold),
                .foregroundColor: UIColor.foreground
            ])
            
            if userList.count > 1 {
                text.append(.init(string: " and \(userList.count - 1) other\(userList.count == 2 ? "" : "s")", attributes: [
                    .font: UIFont.appFont(withSize: 15, weight: .regular),
                    .foregroundColor: UIColor.foreground
                ]))
            }
                        
            text.append(.init(string: " highlighted", attributes: [
                .font: UIFont.appFont(withSize: 15, weight: .regular),
                .foregroundColor: UIColor.foreground
            ]))
            label.attributedText = text
        }
    }
}

class HighlighUserAvatarView: UserImageView {
    init(user: ParsedUser) {
        super.init(height: 30)
        
        setUserImage(user)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
