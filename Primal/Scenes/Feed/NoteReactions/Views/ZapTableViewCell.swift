//
//  ZapTableViewCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 19.4.24..
//

import UIKit
import FLAnimatedImage

protocol ZapTableViewCellDelegate: AnyObject {
    func contextMenuForZapCell(_ cell: ZapTableViewCell) -> UIMenu?
    func messageTappedInZapCell(_ cell: ZapTableViewCell)
}

final class ZapTableViewCell: UITableViewCell, Themeable, UIContextMenuInteractionDelegate {
    
    private let icon = UIImageView(image: UIImage(named: "feedZapBig"))
    private let countLabel = UILabel()
    private let avatarView = UserImageView(height: 42)
    private let nameLabel = UILabel()
    private let messageLabel = UILabel()
    
    var delegate: ZapTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        let iconStack = UIStackView(axis: .vertical, [icon, countLabel]).constrainToSize(width: 40)
        iconStack.alignment = .center
        iconStack.spacing = 5
        
        let infoStack = UIStackView(axis: .vertical, [nameLabel, messageLabel])
        infoStack.spacing = 8
        
        let mainStack = UIStackView([iconStack, avatarView, infoStack])
        contentView.addSubview(mainStack)
        mainStack.pinToSuperview(padding: 12)
        mainStack.alignment = .center
        mainStack.spacing = 12
        
        nameLabel.font = .appFont(withSize: 16, weight: .bold)
        
        messageLabel.font = .appFont(withSize: 15, weight: .regular)
        
        countLabel.font = .appFont(withSize: 14, weight: .semibold)
        
        let interaction = UIContextMenuInteraction(delegate: self)
        contentView.addInteraction(interaction)
        
        messageLabel.isUserInteractionEnabled = true
        messageLabel.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            guard let self else { return }
            delegate?.messageTappedInZapCell(self)
        }))
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateForZap(_ zap: ParsedZap, delegate: ZapTableViewCellDelegate?) {
        countLabel.text = zap.amountSats.shortenedLocalized()
        
        avatarView.setUserImage(zap.user)
        
        nameLabel.text = zap.user.data.firstIdentifier
        
        messageLabel.text = zap.message
        messageLabel.isHidden = zap.message.isEmpty
        messageLabel.textColor = zap.message.isValidURL ? .accent : .foreground3
        
        updateTheme()
        
        self.delegate = delegate
    }
    
    func updateTheme() {
        contentView.backgroundColor = .background2
        
        icon.tintColor = .foreground3
        nameLabel.textColor = .foreground
        
        countLabel.textColor = .foreground
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        .init(identifier: nil, previewProvider: nil) { [weak self] suggestedActions in
            guard let self else { return nil }
            return delegate?.contextMenuForZapCell(self)
        }
    }
}
