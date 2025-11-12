//
//  CloudLoginButton.swift
//  Primal
//
//  Created by Pavle Stevanović on 10. 11. 2025..
//

import UIKit

class CloudLoginButton: MyButton {
    init(user: ParsedUser, type: String) {
        super.init(frame: .zero)
    
        let avatar = UserImageView(height: 36)
        avatar.setUserImage(user)
        let nameLabel = UILabel(user.data.firstIdentifier, color: .white, font: .appFont(withSize: 16, weight: .bold))
        let subName = UILabel(user.data.secondIdentifier ?? "", color: .white.withAlphaComponent(0.6), font: .appFont(withSize: 14, weight: .regular))
        subName.isHidden = user.data.secondIdentifier == nil

        let typeLabel = UILabel(type, color: .white.withAlphaComponent(0.5), font: .appFont(withSize: 14, weight: .semibold))
        let typeParent = UIView().constrainToSize(width: 50, height: 22)
        typeParent.layer.cornerRadius = 11
        typeParent.layer.borderWidth = 1
        typeParent.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        typeParent.addSubview(typeLabel)
        typeLabel.centerToSuperview()
        
        let titleStack = UIStackView(axis: .vertical, [nameLabel, subName])
        let mainStack = UIStackView([avatar, titleStack, typeParent])
        mainStack.alignment = .center
        mainStack.spacing = 10
        
        addSubview(mainStack)
        mainStack.pinToSuperview(edges: .leading, padding: 14).pinToSuperview(edges: .trailing, padding: 16).centerToSuperview(axis: .vertical)
        
        constrainToSize(height: 56)
        layer.cornerRadius = 12
        backgroundColor = .black.withAlphaComponent(0.4)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}
