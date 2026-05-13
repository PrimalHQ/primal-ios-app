//
//  RecentUserView.swift
//  Primal
//
//  Created by Pavle Stevanović on 29.4.26..
//

import UIKit

final class RecentUserView: UIView, Themeable {
    let avatar = UserImageView(height: 44)
    let nameLabel = UILabel()

    var onTap: (() -> Void)?

    init() {
        super.init(frame: .zero)
        setup()
        setPlaceholder()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setUser(_ user: ParsedUser) {
        avatar.setUserImage(user)
        nameLabel.text = user.data.firstIdentifier
    }
    
    func setPlaceholder() {
        avatar.image = .profile
        nameLabel.text = " "
    }

    func updateTheme() {
        nameLabel.textColor = .foreground.withAlphaComponent(0.7)
        avatar.updateTheme()
    }
}

private extension RecentUserView {
    func setup() {
        nameLabel.font = .appFont(withSize: 13, weight: .regular)
        nameLabel.textAlignment = .center
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.numberOfLines = 1

        let stack = UIStackView(arrangedSubviews: [avatar, nameLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8

        addSubview(stack)
        stack.pinToSuperview(edges: .vertical).pinToSuperview(edges: .horizontal, padding: 4)

        updateTheme()

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }

    @objc func handleTap() { onTap?() }
}
