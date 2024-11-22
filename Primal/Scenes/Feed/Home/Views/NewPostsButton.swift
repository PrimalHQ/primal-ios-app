//
//  NewPostsButton.swift
//  Primal
//
//  Created by Pavle D Stevanović on 14.7.23..
//

import FLAnimatedImage
import UIKit

final class NewPostsButton: MyButton, Themeable {
    private let avatars: [UserImageView] = (0..<3).map { _ in UserImageView(height: 28, glowPadding: 2) }
    private let label = UILabel()
    
    lazy var avatarStack = UIStackView()
    lazy var stack = UIStackView([avatarStack, label])
    
    override var isPressed: Bool {
        didSet {
            stack.alpha = isPressed ? 0.5 : 1
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .accent
        layer.cornerRadius = 20
        
        avatars.forEach { avatar in
            let parent = UIView()
            let background = UIView()
            background.backgroundColor = .init(rgb: 0xAAAAAA)
            parent.addSubview(background)
            background.pinToSuperview(padding: 2)
            
            parent.addSubview(avatar)
            avatar.centerToSuperview()
            
            background.layer.cornerRadius = 14
            parent.layer.cornerRadius = 16
            parent.backgroundColor = .white
            
            avatarStack.addArrangedSubview(parent.constrainToSize(32))
        }
        
        avatarStack.alignment = .center
        avatarStack.spacing = -8
        
        stack.alignment = .center
        stack.spacing = 10
        
        addSubview(stack)
        stack.pinToSuperview(edges: .leading, padding: 5).pinToSuperview(edges: .trailing, padding: 17).centerToSuperview(axis: .vertical)
        
        constrainToSize(height: 40)
        
        label.font = .appFont(withSize: 14, weight: .regular)
        label.textColor = .white
    }
    
    func setCount(_ count: Int, users: [ParsedUser]) {
        if count == 1 {
            label.text = "1 new note"
        } else {
            label.text = "\(count) new notes"
        }
        
        for avatar in avatars {
            avatar.superview?.superview?.isHidden = true
        }
        
        guard count > 0 else { return }
        
        let uniqueUsers = users.uniqueByFilter { $0.data.id }
        
        zip((1...count), zip(uniqueUsers, avatars)).forEach { (_, arg1) in
            let (user, avatar) = arg1
            avatar.superview?.superview?.isHidden = false
            avatar.setUserImage(user)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        backgroundColor = .accent
    }
}
