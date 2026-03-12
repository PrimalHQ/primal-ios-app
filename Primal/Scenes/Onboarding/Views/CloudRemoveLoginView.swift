//
//  CloudRemoveLoginView.swift
//  Primal
//
//  Created by Pavle Stevanović on 10. 11. 2025..
//

import UIKit

class CloudRemoveLoginView: UIView {
    let removeButton = UIButton().constrainToSize(height: 25)
    
    init(user: ParsedUser) {
        super.init(frame: .zero)
    
        let avatar = UserImageView(height: 36)
        avatar.setUserImage(user)
        let nameLabel = UILabel(user.data.firstIdentifier, color: IceWave.instance.foreground, font: .appFont(withSize: 16, weight: .bold))
        let subName = UILabel(user.data.secondIdentifier ?? "", color: IceWave.instance.foreground4, font: .appFont(withSize: 14, weight: .regular))
        subName.isHidden = user.data.secondIdentifier == nil

        let titleStack = UIStackView(axis: .vertical, [nameLabel, subName])
        let mainStack = UIStackView([avatar, titleStack, removeButton])
        mainStack.alignment = .center
        mainStack.spacing = 10

        addSubview(mainStack)
        mainStack.pinToSuperview(edges: .leading, padding: 14).pinToSuperview(edges: .trailing, padding: 16).centerToSuperview(axis: .vertical)

        constrainToSize(height: 56)
        layer.cornerRadius = 12
        backgroundColor = .white

        removeButton.configuration = .pill(text: "Remove", foregroundColor: IceWave.instance.foreground, backgroundColor: IceWave.instance.background3, font: .appFont(withSize: 12, weight: .regular))
        removeButton.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}
