//
//  TransactionUserInfoCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 20.12.23..
//

import UIKit
import FLAnimatedImage
import Nantes
import SafariServices

class TransactionUserInfoCell: UITableViewCell {
    let background = UIView()
    let border = UIView().constrainToSize(height: 1)
    
    let avatar = UserImageView(height: 42)
    let mainLabel = UILabel()
    let checkbox = VerifiedView()
    let subtitleLabel = UILabel()
    let messageLabel = NantesLabel()
    
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
            avatar.image = .nonZapPaymentOld
            mainLabel.text = "Lightning payment"
            subtitleLabel.isHidden = true
            checkbox.isHidden = true
        }
        
        messageLabel.text = message
        messageLabel.isHidden = message?.isEmpty != false
        
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
        messageLabel.numberOfLines = 0
        messageLabel.delegate = self
        messageLabel.isUserInteractionEnabled = true
        messageLabel.linkAttributes = [.foregroundColor: UIColor.accent2]
        messageLabel.tintColor = .accent2
    }
    
//    func createAttributedTextWithLinks(from text: String) -> NSAttributedString {
//        let attributedString = NSMutableAttributedString(string: text, attributes: [
//            .font: UIFont.appFont(withSize: 16, weight: .regular),
//            .foregroundColor: UIColor.foreground
//        ])
//
//        do {
//            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
//
//            let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
//
//            for match in matches {
//                let range = match.range(at: 0)
//                
//                if let url = match.url {
//                    attributedString.addAttributes([
//                        .link: url
//                    ], range: range)
//                }
//            }
//        } catch {
//            print("Error creating data detector: \(error)")
//        }
//
//        return attributedString
//    }
}

extension TransactionUserInfoCell: NantesLabelDelegate {
    func attributedLabel(_ label: NantesLabel, didSelectLink link: URL) {
        RootViewController.instance.present(SFSafariViewController(url: link), animated: true)
    }
}
