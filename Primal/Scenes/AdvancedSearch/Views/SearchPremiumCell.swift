//
//  SearchPremiumCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 19.11.24..
//

import UIKit

protocol SearchPremiumCellDelegate: AnyObject {
    func getPremiumPressed()
}

class SearchPremiumCell: UITableViewCell, Themeable {
    let titleLabel = UILabel("This is a Primal Premium feed.", color: .foreground, font: .appFont(withSize: 20, weight: .semibold))
    let subtitleLabel = UILabel()
    
    let actionButton = UIButton()
    
    let backgroundPill = UIView()
    
    weak var delegate: SearchPremiumCellDelegate? { didSet { updateTheme() } }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let stack = UIStackView(axis: .vertical, [
            titleLabel, SpacerView(height: 8),
            subtitleLabel, SpacerView(height: 16),
            actionButton
        ])
        stack.alignment = .center
        
        subtitleLabel.numberOfLines = 0
        
        contentView.addSubview(backgroundPill)
        backgroundPill.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .vertical, padding: 12)
        backgroundPill.layer.cornerRadius = 12
        
        backgroundPill.addSubview(stack)
        stack.pinToSuperview(padding: 16)
        
        actionButton.isUserInteractionEnabled = false
        contentView.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.delegate?.getPremiumPressed()
        }))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        paragraphStyle.alignment = .center
        subtitleLabel.attributedText = .init(string: "Buy a Subscription to become a Nostr power user and support our work:", attributes: [
            .foregroundColor: UIColor.foreground3,
            .font: UIFont.appFont(withSize: 15, weight: .regular),
            .paragraphStyle: paragraphStyle
        ])

        titleLabel.textColor = .foreground
        actionButton.configuration = .accent("Get Primal Premium", font: .appFont(withSize: 14, weight: .regular))
        backgroundPill.backgroundColor = .background5
    }
}
