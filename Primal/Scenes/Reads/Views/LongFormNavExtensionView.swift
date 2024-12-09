//
//  LongFormNavExtensionView.swift
//  Primal
//
//  Created by Pavle Stevanović on 29.5.24..
//

import Combine
import UIKit
import FLAnimatedImage

extension UIButton.Configuration {
    static func accent14(_ text: String) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .accent
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
    let profileIcon = UserImageView(height: 40)
    let border = SpacerView(height: 1)
    
//    let subscribeButton = UIButton(configuration: .accent14("Subscribe")).constrainToSize(height: 38)
    let followButton = BrightSmallButton(title: "follow", font: .appFont(withSize: 16, weight: .semibold)).constrainToSize(width: 100)
    let unfollowButton = RoundedSmallButton(text: "following", font: .appFont(withSize: 16, weight: .semibold), horizontalPadding: 0).constrainToSize(width: 100)
    
    init(_ user: ParsedUser) {
        super.init(frame: .zero)
        setup()
        update(user: user)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    var followingCancellable: AnyCancellable?
    var user: ParsedUser?
    func update(user: ParsedUser) {
        self.user = user
        updateTheme()
        
        nameLabel.text = user.data.firstIdentifier
        
        if CheckNip05Manager.instance.isVerified(user.data) {
            secondaryLabel.text = user.data.parsedNip
            secondaryLabel.isHidden = false
        } else {
            secondaryLabel.isHidden = true
        }
        
        profileIcon.setUserImage(user)
        
        followingCancellable = FollowManager.instance.isFollowingPublisher(user.data.pubkey).sink(receiveValue: { [weak self] following in
            self?.followButton.isHidden = following
            self?.unfollowButton.isHidden = !following
        })
    }
    
    func updateTheme() {
        backgroundColor = .background
        nameLabel.textColor = .foreground
        secondaryLabel.textColor = .foreground5
        
        border.backgroundColor = .background3
    }
}

private extension LongFormNavExtensionView {
    func setup() {
        let nameStack = UIStackView(arrangedSubviews: [nameLabel, secondaryLabel])
        nameStack.alignment = .leading
        nameStack.axis = .vertical
        nameStack.spacing = 4
        
        let mainStack = UIStackView(arrangedSubviews: [profileIcon, nameStack, followButton, unfollowButton])
        mainStack.alignment = .center
        mainStack.spacing = 8
        
        addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .vertical, padding: 12)
        
        nameLabel.font = .appFont(withSize: 16, weight: .bold)
        secondaryLabel.font = .appFont(withSize: 14, weight: .regular)
        
        addSubview(border)
        border.pinToSuperview(edges: [.horizontal, .bottom])
        
        followButton.addAction(.init(handler: { [weak self] _ in
            guard let pubkey = self?.user?.data.pubkey else { return }
            FollowManager.instance.sendFollowEvent(pubkey)
        }), for: .touchUpInside)
        
        unfollowButton.addAction(.init(handler: { [weak self] _ in
            guard let data = self?.user?.data else { return }
            
            let alert = UIAlertController(title: "Unfollow \(data.firstIdentifier)?", message: "Are you sure?", preferredStyle: .alert)
            alert.addAction(.init(title: "Cancel", style: .cancel))
            alert.addAction(.init(title: "OK", style: .destructive) { _ in
                FollowManager.instance.sendUnfollowEvent(data.pubkey)
            })
            RootViewController.instance.present(alert, animated: true)
        }), for: .touchUpInside)
    }
}
