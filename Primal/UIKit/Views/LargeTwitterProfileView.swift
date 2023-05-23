//
//  LargeTwitterProfileView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 25.4.23..
//

import UIKit

final class LargeTwitterProfileView: UIView {
    let coverImageView = UIImageView()
    let profileImageView = UIImageView()
    let nameLabel = UILabel()
    let usernameLabel = UILabel()
    let descriptionLabel = LinkableLabel()
    
    var profile: TwitterUserRequest.Response? {
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

private extension LargeTwitterProfileView {
    func updateView() {
        guard let profile else { return }
        profileImageView.kf.setImage(with: URL(string: profile.avatar))
        coverImageView.kf.setImage(with: URL(string: profile.banner))
        usernameLabel.text = "@" + profile.username
        descriptionLabel.text = profile.bio
        nameLabel.text = profile.displayname
    }
    
    func setup() {
        backgroundColor = .black
        layer.cornerRadius = 12
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
        layer.masksToBounds = true
        
        let profileImageViewParent = UIView()
        profileImageViewParent.backgroundColor = .black
        profileImageViewParent.layer.cornerRadius = (72 + 6) / 2
        profileImageViewParent.addSubview(profileImageView)
        profileImageView.pinToSuperview(padding: 3)
        
        addSubview(coverImageView)
        coverImageView.pinToSuperview(edges: [.horizontal, .top]).constrainToSize(height: 102)
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.layer.masksToBounds = true
        coverImageView.backgroundColor = .darkGray
        
        let nameStack = UIStackView(arrangedSubviews: [nameLabel, usernameLabel])
        let mainStack = UIStackView(arrangedSubviews: [profileImageViewParent, nameStack, descriptionLabel])
        
        addSubview(mainStack)
        mainStack.pinToSuperview(edges: [.horizontal, .bottom], padding: 16)
        profileImageView
            .constrainToSize(72)
            .centerYAnchor.constraint(equalTo: coverImageView.bottomAnchor).isActive = true
        
        profileImageView.layer.cornerRadius = 72 / 2
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.masksToBounds = true
        profileImageView.backgroundColor = .darkGray
        
        nameLabel.font = .appFont(withSize: 20, weight: .bold)
        nameLabel.textColor = .white
        nameLabel.adjustsFontSizeToFitWidth = true
        
        usernameLabel.font = .appFont(withSize: 14, weight: .regular)
        usernameLabel.textColor = .init(rgb: 0x666666)
        
        descriptionLabel.font = .appFont(withSize: 14, weight: .regular)
        descriptionLabel.numberOfLines = 4
        descriptionLabel.adjustsFontSizeToFitWidth = true
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.textColor = .white
        
        nameStack.spacing = 6
        nameStack.alignment = .center
        
        mainStack.axis = .vertical
        mainStack.alignment = .leading
        mainStack.spacing = 10
    }
}
