//
//  LongFormNavExtensionView.swift
//  Primal
//
//  Created by Pavle Stevanović on 29.5.24..
//

import UIKit
import FLAnimatedImage

extension UIButton.Configuration {
    static func accent14(_ text: String) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .accent2
        config.attributedTitle = .init(text, attributes: .init([
            .font: UIFont.appFont(withSize: 14, weight: .semibold),
            .foregroundColor: UIColor.white
        ]))
        config.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 14, bottom: 7, trailing: 14)
        return config
    }
}

class LongFormNavExtensionView: UIView, Themeable {
    let nameLabel = UILabel()
    let secondaryLabel = UILabel()
    let profileIcon = FLAnimatedImageView(image: UIImage(named: "profile"))
    let border = SpacerView(height: 1)
    let subscribeButton = UIButton(configuration: .accent14("Subscribe")).constrainToSize(height: 38)
    
    init(_ user: ParsedUser) {
        super.init(frame: .zero)
        setup()
        update(user: user)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func update(user: ParsedUser) {
        updateTheme()
        
        nameLabel.text = user.data.firstIdentifier
        
        if CheckNip05Manager.instance.isVerified(user.data) {
            secondaryLabel.text = user.data.parsedNip
            secondaryLabel.isHidden = false
        } else {
            secondaryLabel.isHidden = true
        }
        
        profileIcon.setUserImage(user)
    }
    
    func updateTheme() {
        backgroundColor = .background
        nameLabel.textColor = .foreground
        secondaryLabel.textColor = .foreground5
        
        border.backgroundColor = .background3
        subscribeButton.configuration = .accent14("Subscribe")
    }
}

private extension LongFormNavExtensionView {
    func setup() {
        profileIcon.constrainToSize(40)
        profileIcon.contentMode = .scaleAspectFill
        profileIcon.layer.cornerRadius = 20
        profileIcon.layer.masksToBounds = true
        
        let nameStack = UIStackView(arrangedSubviews: [nameLabel, secondaryLabel])
        nameStack.alignment = .leading
        nameStack.axis = .vertical
        nameStack.spacing = 4
        
        let mainStack = UIStackView(arrangedSubviews: [profileIcon, nameStack, subscribeButton])
        mainStack.alignment = .center
        mainStack.spacing = 8
        
        addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .vertical, padding: 12)
        
        nameLabel.font = .appFont(withSize: 16, weight: .bold)
        secondaryLabel.font = .appFont(withSize: 14, weight: .regular)
        
        addSubview(border)
        border.pinToSuperview(edges: [.horizontal, .bottom])
    }
}
