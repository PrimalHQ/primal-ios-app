//
//  NewPostsView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 14.7.23..
//

import UIKit

final class NewPostsView: MyButton {
    private let avatars: [UIImageView] = (0..<3).map { _ in UIImageView(image: UIImage(named: "Profile")) }
    private let label = UILabel()
    
    override var isPressed: Bool {
        didSet {
            alpha = isPressed ? 0.5 : 1
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .gradientColor(bounds: .init(width: 192, height: 40))
        layer.cornerRadius = 20
        
        avatars.forEach {
            $0.constrainToSize(32)
            $0.layer.cornerRadius = 16
            $0.layer.masksToBounds = true
            $0.layer.borderWidth = 2
            $0.layer.borderColor = UIColor.white.cgColor
            $0.backgroundColor = .init(rgb: 0xAAAAAA)
        }
        
        let stack = UIStackView(avatars + [label])
        stack.alignment = .center
        stack.spacing = -8
        if let last = avatars.last {
            stack.setCustomSpacing(10, after: last)
        }
        addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 5).centerToSuperview()
        
        constrainToSize(height: 40)
        
        label.font = .appFont(withSize: 14, weight: .regular)
        label.textColor = .white
    }
    
    func setCount(_ count: Int, avatarURLs: [URL]) {
        if count == 1 {
            label.text = "1 new reply"
        } else {
            label.text = "\(count) new replies"
        }
        
        zip(avatarURLs, avatars).forEach { url, avatar in
            avatar.kf.setImage(with: url, placeholder: UIImage(named: "Profile"))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
