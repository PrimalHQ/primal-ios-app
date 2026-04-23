//
//  NewPostsButton.swift
//  Primal
//
//  Created by Pavle D Stevanović on 14.7.23..
//

import FLAnimatedImage
import UIKit

final class NewPostsButton: MyButton, Themeable {
    private let noteAvatars: [UserImageView] = (0..<3).map { _ in UserImageView(height: 28, showLegendGlow: false) }
    private let noteLabel = UILabel()

    private let liveAvatars: [UserImageView] = (0..<3).map { _ in UserImageView(height: 28, showLegendGlow: false) }
    private let liveLabel = UILabel()

    lazy var noteAvatarStack = UIStackView()
    lazy var noteStack = UIStackView([noteAvatarStack, noteLabel])

    lazy var liveAvatarStack = UIStackView()
    lazy var liveStack = UIStackView([liveAvatarStack, liveLabel])

    let separator = SpacerView(width: 1, height: 24, color: .white.withAlphaComponent(0.5))

    private var isExcited = false

    override var isPressed: Bool {
        didSet {
            noteStack.alpha = isPressed ? 0.5 : 1
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .accent
        layer.cornerRadius = 20
        
        [(noteAvatars, noteAvatarStack, noteLabel, noteStack), (liveAvatars, liveAvatarStack, liveLabel, liveStack)].forEach { avatars, avatarStack, label, stack in
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
            
            label.font = .appFont(withSize: 14, weight: .regular)
            label.textColor = .white
        }
        
        let mainStack = UIStackView([noteStack, separator, liveStack])
        mainStack.spacing = 8
        
        addSubview(mainStack)
        mainStack.pinToSuperview(edges: .leading, padding: 5).pinToSuperview(edges: .trailing, padding: 17).centerToSuperview(axis: .vertical)
        
        constrainToSize(height: 40)
    }
    
    func setCounts(noteCount: Int, noteUsers: [ParsedUser], liveCount: Int, liveUsers: [ParsedUser]) {
        if noteCount == 1 {
            noteLabel.attributedText = labelText(1, "note")
        } else {
            noteLabel.attributedText = labelText(noteCount, "notes")
        }
        
        liveLabel.attributedText = labelText(liveCount, "live")
        
        for avatar in noteAvatars + liveAvatars {
            avatar.superview?.isHidden = true
        }
        
        liveStack.isHidden = liveCount < 1
        noteStack.isHidden = noteCount < 1
        separator.isHidden = noteCount < 1 || liveCount < 1
        
        if noteCount > 0 {
            let uniqueUsers = noteUsers.uniqueByFilter { $0.data.id }
            
            zip((1...noteCount), zip(uniqueUsers, noteAvatars)).forEach { (_, arg1) in
                let (user, avatar) = arg1
                avatar.superview?.isHidden = false
                avatar.setUserImage(user)
            }
        }
        if liveCount > 0 {
            let uniqueUsers = liveUsers.uniqueByFilter { $0.data.id }
            
            zip((1...liveCount), zip(uniqueUsers, liveAvatars)).forEach { (_, arg1) in
                let (user, avatar) = arg1
                avatar.superview?.isHidden = false
                avatar.setUserImage(user)
            }
        }
    }
    
    func labelText(_ number: Int, _ text: String) -> NSAttributedString {
        let str = NSMutableAttributedString(string: number.localized(), attributes: [
            .font: UIFont.appFont(withSize: 14, weight: .bold),
            .foregroundColor: UIColor.white
        ])
        str.append(.init(string: " \(text)", attributes: [
            .foregroundColor: UIColor.white,
            .font: UIFont.appFont(withSize: 14, weight: .regular)
        ]))
        return str
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setHidden(_ hidden: Bool, animated: Bool) {
        isExcited = false
        guard isHidden != hidden else { return }

        guard animated else {
            isHidden = hidden
            alpha = hidden ? 0 : 1
            transform = .identity
            return
        }

        if hidden {
            UIView.animate(withDuration: 0.25) {
                self.transform = .init(scaleX: 0.2, y: 0.2)
                self.alpha = 0
            } completion: { _ in
                self.isHidden = true
            }
        } else {
            alpha = 0
            transform = .init(translationX: 0, y: -30)
            isHidden = false
            UIView.animate(withDuration: 12 / 30, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0) {
                self.alpha = 1
                self.transform = .identity
            }
        }
    }

    func setIsExcited(_ excited: Bool) {
        guard isExcited != excited, !isHidden else { return }
        isExcited = excited
        UIView.animate(withDuration: 0.1) {
            self.transform = excited ? .init(scaleX: 0.9, y: 0.9) : .identity
        }
    }

    func updateTheme() {
        backgroundColor = .accent
    }
}
