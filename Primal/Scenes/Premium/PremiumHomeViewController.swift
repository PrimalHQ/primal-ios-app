//
//  PremiumHomeViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 8.11.24..
//

import Combine
import UIKit
import FLAnimatedImage
import StoreKit

class PremiumHomeViewController: UIViewController {
    
    var cancellables: Set<AnyCancellable> = []

    let state: PremiumState
    
    init(state: PremiumState) {
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
}

private extension PremiumHomeViewController {
    func setup() {
        view.backgroundColor = .background
        
        let table = PremiumHomeTableView(state: state)
        
        let renewLabel = UILabel()
        renewLabel.numberOfLines = 0
        renewLabel.attributedText = renewString()
        renewLabel.isUserInteractionEnabled = true
        renewLabel.addGestureRecognizer(BindableTapGestureRecognizer(action: {
            
//            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
//                UIApplication.shared.open(url, options: [:], completionHandler: nil)
//            }

            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }))
        
        let mainStack = UIStackView(axis: .vertical, [
            UIView(),
            table, SpacerView(height: 20),
            renewLabel
        ])
        
        if let userStack = userStackView() {
            mainStack.insertArrangedSubview(userStack, at: 1)
            mainStack.setCustomSpacing(22, after: userStack)
        }
        
        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .horizontal, padding: 24)
            .centerToSuperview(axis: .vertical)
        
        
    }
    
    func userStackView() -> UIView? {
        guard let user = IdentityManager.instance.parsedUser else { return nil }
        let image = FLAnimatedImageView().constrainToSize(80)
        image.layer.cornerRadius = 40
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.setUserImage(user, size: .init(width: 80, height: 80))
        
        let checkbox = VerifiedView().constrainToSize(24)
        checkbox.isExtraVerified = true
        
        let nameLabel = UILabel(user.data.firstIdentifier, color: .foreground, font: .appFont(withSize: 22, weight: .bold))
        let nameStack = UIStackView([nameLabel, checkbox])
        nameStack.alignment = .center
        nameStack.spacing = 6
        
        let userStack = UIStackView(axis: .vertical, [
            image, SpacerView(height: 16),
            nameStack, SpacerView(height: 20),
            PremiumUserTitleView()
        ])
        userStack.alignment = .center
        
        return userStack
    }
    
    func renewString() -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 6
        paragraph.alignment = .center
        
        let mutable = NSMutableAttributedString(string: "Your subscription will renew automatically.\nIf you wish to stop it, you can ", attributes: [
            .font: UIFont.appFont(withSize: 14, weight: .regular),
            .foregroundColor: UIColor.foreground3,
            .paragraphStyle: paragraph
        ])
        mutable.append(.init(string: "cancel now.", attributes: [
            .font: UIFont.appFont(withSize: 14, weight: .regular),
            .foregroundColor: UIColor.accent,
            .paragraphStyle: paragraph
        ]))
        return mutable
    }
}

class PremiumUserTitleView: UIView, Themeable {
    let titleLabel = UILabel("Primal OG", color: .white, font: .appFont(withSize: 14, weight: .bold))
    let subtitleLabel = UILabel("Class of 2024", color: .white, font: .appFont(withSize: 14, weight: .regular))
    
    init(title: String = "Primal OG", subtitle: String = "Class of 2024") {
        super.init(frame: .zero)
        
        titleLabel.text = title
        subtitleLabel.text = subtitle
        
        let subtitleParent = UIView().constrainToSize(height: 24)
        subtitleParent.layer.cornerRadius = 12
        subtitleParent.backgroundColor = .black.withAlphaComponent(0.4)
        subtitleParent.addSubview(subtitleLabel)
        subtitleLabel.centerToSuperview(axis: .vertical).pinToSuperview(edges: .horizontal, padding: 10)
        
        let stack = UIStackView([titleLabel, subtitleParent])
        stack.alignment = .center
        stack.spacing = 6
        
        addSubview(stack)
        stack.pinToSuperview(edges: [.vertical, .trailing], padding: 2).pinToSuperview(edges: .leading, padding: 10)
        
        layer.cornerRadius = 14
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        backgroundColor = .accent
    }
}

class PremiumHomeTableView: UIView {
    let addressRow = PremiumSearchTableRowView(title: "Nostr Address")
    let lightningRow = PremiumSearchTableRowView(title: "Lightning Address")
    let profileRow = PremiumSearchTableRowView(title: "VIP profile")
    let endRow: PremiumSearchTableRowView
    
    init(state: PremiumState) {
        let tableStack = UIStackView(axis: .vertical, [
            addressRow, SpacerView(height: 1, color: .foreground6),
            lightningRow, SpacerView(height: 1, color: .foreground6),
            profileRow, SpacerView(height: 1, color: .foreground6)
        ])
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .long
        let expireDate = Date(timeIntervalSince1970: state.expires_on)
        
        if state.recurring, let renews_on = state.renews_on {
            let renewDate = Date(timeIntervalSince1970: renews_on)
            if renewDate.timeIntervalSinceNow < 30 * 24 * 3600 {
                endRow = .init(title: "Renews on")
                endRow.infoLabel.text = dateFormatter.string(from: renewDate)
            } else {
                endRow = .init(title: "Expires on")
                endRow.infoLabel.text = dateFormatter.string(from: expireDate)
            }
        } else {
            endRow = .init(title: expireDate.timeIntervalSinceNow > 0 ? "Expires on" : "Expired on")
            endRow.infoLabel.text = dateFormatter.string(from: expireDate)
        }
        tableStack.addArrangedSubview(endRow)
        
        super.init(frame: .zero)
        
        addSubview(tableStack)
        tableStack.pinToSuperview()
        backgroundColor = .background5
        layer.cornerRadius = 16
        
        addressRow.infoLabel.text = state.nostr_address
        lightningRow.infoLabel.text = state.lightning_address
        profileRow.infoLabel.text = state.primal_vip_profile
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
