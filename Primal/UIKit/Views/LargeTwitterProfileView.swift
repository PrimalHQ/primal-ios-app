//
//  LargeTwitterProfileView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 25.4.23..
//

import UIKit

class LargeTwitterProfileView: UIView {
    let coverImageView = UIImageView()
    let profileImageView = UIImageView()
    let nameLabel = UILabel()
    let usernameLabel = UILabel()
    let descriptionLabel = UILabel()
    let linkLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension LargeTwitterProfileView {
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
        let mainStack = UIStackView(arrangedSubviews: [profileImageViewParent, nameStack, descriptionLabel, linkLabel])
        
        addSubview(mainStack)
        mainStack.pinToSuperview(edges: [.horizontal, .bottom], padding: 16)
        profileImageView
            .constrainToSize(72)
            .centerYAnchor.constraint(equalTo: coverImageView.bottomAnchor).isActive = true
        
        profileImageView.layer.cornerRadius = 72 / 2
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.masksToBounds = true
        profileImageView.backgroundColor = .darkGray
        
        nameLabel.text = "Preston Pysh"
        nameLabel.font = .appFont(withSize: 20, weight: .bold)
        nameLabel.textColor = .white
        nameLabel.adjustsFontSizeToFitWidth = true
        
        usernameLabel.text = "@PrestonPysh"
        usernameLabel.font = .appFont(withSize: 14, weight: .regular)
        usernameLabel.textColor = .init(rgb: 0x666666)
        
        descriptionLabel.text = "Bitcoin & books. My bitcoin can remain in cold storage far longer than the market can remain irrational."
        descriptionLabel.font = .appFont(withSize: 14, weight: .regular)
        descriptionLabel.numberOfLines = 3
        descriptionLabel.adjustsFontSizeToFitWidth = true
        descriptionLabel.textColor = .white
        
        linkLabel.text = "https://theinvestorspodcast.com/"
        linkLabel.font = .appFont(withSize: 14, weight: .regular)
        linkLabel.textColor = .init(rgb: 0xCA079F)
        linkLabel.adjustsFontSizeToFitWidth = true
        
        nameStack.spacing = 6
        nameStack.alignment = .center
        
        mainStack.axis = .vertical
        mainStack.alignment = .leading
        mainStack.spacing = 10
    }
}
