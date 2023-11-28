//
//  NewPostsButton.swift
//  Primal
//
//  Created by Pavle D Stevanović on 14.7.23..
//

import FLAnimatedImage
import UIKit

final class NewPostsButton: MyButton, Themeable {
    private let avatars: [FLAnimatedImageView] = (0..<3).map { _ in FLAnimatedImageView(image: UIImage(named: "Profile")) }
    private let label = UILabel()
    
    lazy var avatarStack = UIStackView(avatars)
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
        
        avatars.forEach {
            $0.constrainToSize(32)
            $0.layer.cornerRadius = 16
            $0.layer.masksToBounds = true
            $0.layer.borderWidth = 2
            $0.layer.borderColor = UIColor.white.cgColor
            $0.backgroundColor = .init(rgb: 0xAAAAAA)
            $0.contentMode = .scaleAspectFill
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
            avatar.isHidden = true
        }
        
        guard count > 0 else { return }
        
        let uniqueUsers = users.uniqueByFilter { $0.data.id }
        
        zip((1...count), zip(uniqueUsers, avatars)).forEach { (_, arg1) in
            let (user, avatar) = arg1
            avatar.isHidden = false
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
