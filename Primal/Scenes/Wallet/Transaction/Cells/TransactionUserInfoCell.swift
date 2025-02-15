//
//  TransactionUserInfoCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 20.12.23..
//

import UIKit
import FLAnimatedImage

class TransactionUserInfoCell: UITableViewCell {
    let background = UIView()
    let border = UIView().constrainToSize(height: 1)
    
    let avatar = UserImageView(height: 42)
    let mainLabel = UILabel()
    let checkbox = VerifiedView()
    let subtitleLabel = UILabel()
    let messageLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}


extension TransactionUserInfoCell: TransactionPartialCell {
    func setupWithCellInfo(_ info: TransactionCellType) {
        let user: ParsedUser?
        let message: String?
        let onchain: Bool
        switch info {
        case .user(let parsedUser, let message1):
            user = parsedUser
            message = message1
            onchain = false
        case .onchain(let message1):
            user = nil
            message = message1
            onchain = true
        default:
            return
        }
        
        if onchain {
            avatar.image = UIImage(named: "onchainPayment")
            mainLabel.text = "Bitcoin payment"
            subtitleLabel.isHidden = true
            checkbox.isHidden = true
        } else if let user {
            avatar.setUserImage(user)
            mainLabel.text = user.data.firstIdentifier
            subtitleLabel.text = user.data.address
            subtitleLabel.isHidden = subtitleLabel.text?.isEmpty != false
            checkbox.user = user.data
        } else {
            avatar.image = UIImage(named: "nonZapPayment")
            mainLabel.text = "Lightning payment"
            subtitleLabel.isHidden = true
            checkbox.isHidden = true
        }
        
        messageLabel.text = message
        messageLabel.isHidden = messageLabel.text?.isEmpty != false
        
        mainLabel.textColor = .foreground
        messageLabel.textColor = .foreground
        subtitleLabel.textColor = .foreground4
        backgroundColor = .background2
        background.backgroundColor = .background4
        border.backgroundColor = .background3
    }
}

private extension TransactionUserInfoCell {
    func setup() {
        selectionStyle = .none
        
        let firstLine = UIStackView([mainLabel, SpacerView(width: 6, priority: .required), checkbox, UIView()])
        firstLine.alignment = .center
        
        let nameStack = UIStackView(axis: .vertical, [firstLine, subtitleLabel])
        nameStack.spacing = 3
        
        let infoStack = UIStackView([avatar, nameStack])
        infoStack.alignment = .center
        infoStack.spacing = 10
        
        let contentStack = UIStackView(axis: .vertical, [infoStack, messageLabel, border])
        contentStack.spacing = 10
        
        contentView.addSubview(background)
        background.pinToSuperview()
        background.addSubview(contentStack)
        contentStack.pinToSuperview(edges: .horizontal, padding: 12).pinToSuperview(edges: .bottom).pinToSuperview(edges: .top, padding: 12)
        
        background.layer.cornerRadius = 8
        background.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        mainLabel.font = .appFont(withSize: 18, weight: .bold)
        subtitleLabel.font = .appFont(withSize: 16, weight: .regular)
        messageLabel.font = .appFont(withSize: 16, weight: .regular)
        messageLabel.numberOfLines = 0
    }
}
