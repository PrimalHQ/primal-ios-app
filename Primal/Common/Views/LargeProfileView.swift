//
//  LargeProfileView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 25.4.23..
//

import UIKit
import Nantes

final class LargeProfileView: UIView {
    let coverImageView = UIImageView()
    let profileImageView = UIImageView()
    let nameLabel = UILabel()
    let usernameLabel = UILabel()
    let descriptionLabel = NantesLabel()
    let websiteLabel = NantesLabel()
    let changeBannerButton = SolidColorUIButton(title: "change banner", color: .init(rgb: 0xCA079F))
    
    var didTapUrl: (URL) -> Void = { _ in }
    
    var profile: AccountCreationData? {
        didSet {
            updateView()
        }
    }
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension LargeProfileView {
    func updateView() {
        guard let profile else { return }
        profileImageView.kf.setImage(with: URL(string: profile.avatar), placeholder: UIImage(named: "onboardingDefaultAvatar")?.withAlpha(alpha: 0.5))
        coverImageView.kf.setImage(with: URL(string: profile.banner))
        usernameLabel.text = profile.username.isEmpty ? "" : "@" + profile.username
        descriptionLabel.text = profile.bio
        nameLabel.text = profile.displayname
        websiteLabel.text = profile.website
    }
    
    func setup() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 3
        layer.masksToBounds = true
        
        let profileImageViewParent = UIView()
        profileImageViewParent.backgroundColor = .white
        profileImageViewParent.layer.cornerRadius = (72 + 6) / 2
        profileImageViewParent.addSubview(profileImageView)
        profileImageView.pinToSuperview(padding: 3)
        
        addSubview(coverImageView)
        coverImageView.pinToSuperview(edges: [.horizontal, .top]).constrainToSize(height: 102)
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.layer.masksToBounds = true
        coverImageView.backgroundColor = .darkGray
        
        let nameStack = UIStackView(arrangedSubviews: [nameLabel, usernameLabel])
        let mainStack = UIStackView(arrangedSubviews: [profileImageViewParent, nameStack, descriptionLabel, websiteLabel])
        
        addSubview(mainStack)
        mainStack.pinToSuperview(edges: [.horizontal, .bottom], padding: 16)
        profileImageView
            .constrainToSize(72)
            .centerYAnchor.constraint(equalTo: coverImageView.bottomAnchor).isActive = true
        
        addSubview(changeBannerButton)
        changeBannerButton
            .pinToSuperview(edges: .trailing, padding: 14)
            .topAnchor.constraint(equalTo: coverImageView.bottomAnchor).isActive = true
        
        profileImageView.layer.cornerRadius = 72 / 2
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.masksToBounds = true
        
        nameLabel.font = .appFont(withSize: 20, weight: .bold)
        nameLabel.textColor = .black
        nameLabel.adjustsFontSizeToFitWidth = true
        
        usernameLabel.font = .appFont(withSize: 14, weight: .regular)
        usernameLabel.textColor = .init(rgb: 0x666666)
        
        descriptionLabel.font = .appFont(withSize: 14, weight: .regular)
        descriptionLabel.numberOfLines = 4
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.textColor = .black
        descriptionLabel.linkAttributes = [.foregroundColor: UIColor(rgb: 0xCA079F)]
        descriptionLabel.delegate = self
        
        websiteLabel.font = .appFont(withSize: 14, weight: .regular)
        websiteLabel.adjustsFontSizeToFitWidth = true
        websiteLabel.textColor = UIColor(rgb: 0xCA079F)
        websiteLabel.linkAttributes = [.foregroundColor: UIColor(rgb: 0xCA079F)]
        websiteLabel.delegate = self
        
        nameStack.spacing = 6
        nameStack.alignment = .center
        
        mainStack.axis = .vertical
        mainStack.alignment = .leading
        mainStack.spacing = 10
    }
}

extension LargeProfileView: NantesLabelDelegate {
    func attributedLabel(_ label: NantesLabel, didSelectLink link: URL) {
        didTapUrl(link)
    }
}
