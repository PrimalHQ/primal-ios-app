//
//  ChatMessageCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 8.9.23..
//

import UIKit
import Nantes
import SafariServices

protocol ChatMessageCellDelegate: AnyObject {
    func contextMenuForMessageCell(_ cell: ChatMessageCell) -> UIMenu?
    func copyInvoiceForMessageCell(_ cell: ChatMessageCell)
    func payInvoiceForMessageCell(_ cell: ChatMessageCell)
}

class ChatMessageCell: UITableViewCell, Themeable {
    let label = NantesLabel()
    let labelBackground = UIView()
    let coloredBackgroundView = UIView()
    let failedImageView = UIImageView(image: UIImage(named: "messageFailed"))
    lazy var messageRow = UIStackView([failedImageView, labelBackground])
    lazy var stack = UIStackView(axis: .vertical, [messageRow, SpacerView(height: 4)])
    
    weak var delegate: ChatMessageCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        labelBackground.addSubview(coloredBackgroundView)
        coloredBackgroundView.pinToSuperview()
        
        labelBackground.addSubview(label)
        label.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .vertical, padding: 12)
        label.numberOfLines = 0
        
        messageRow.alignment = .center
        messageRow.spacing = 12
        
        contentView.addSubview(stack)
        stack.pinToSuperview(edges: .vertical).pinToSuperview(edges: .horizontal, padding: 12)
        
        labelBackground.layer.masksToBounds = true
        labelBackground.layer.cornerRadius = 12
        
        labelBackground.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.8).isActive = true
        
        label.delegate = self
        label.lineSpacing = 4
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupWith(message: ProcessedMessage, roundSide: Bool) {
        let isMine = message.user.isCurrentUser
        
        coloredBackgroundView.isHidden = !isMine
        stack.alignment = isMine ? .trailing : .leading
        
        if roundSide {
            if isMine {
                labelBackground.layer.maskedCorners = [/*.layerMaxXMaxYCorner,*/ .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
            } else {
                labelBackground.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner,/* .layerMinXMaxYCorner,*/ .layerMinXMinYCorner]
            }
        } else {
            if isMine {
                labelBackground.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
            } else {
                labelBackground.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
            }
        }
        
        switch message.status {
        case .sent:
            labelBackground.alpha = 1
            failedImageView.isHidden = true
        case .sending:
            labelBackground.alpha = 0.5
            failedImageView.isHidden = true
        case .failed:
            labelBackground.alpha = 0.5
            failedImageView.isHidden = false
        }
        
        let interaction = UIContextMenuInteraction(delegate: self)
        labelBackground.addInteraction(interaction)
        
        label.textColor = isMine ? .white : .foreground
        
        label.linkAttributes = [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        updateTheme()
        
        // Due to a bug with the Nantes library we must first set colors, and then set the text
        label.text = message.message.text
    }
    
    func updateTheme() {
        coloredBackgroundView.backgroundColor = .accent
        
        labelBackground.backgroundColor = .background3
        label.font = .appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular)
    }
}

extension ChatMessageCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        .init(identifier: nil, previewProvider: nil) { [weak self] suggestedActions in
            guard let self else { return nil }
            return delegate?.contextMenuForMessageCell(self)
        }
    }
}

extension ChatMessageCell: NantesLabelDelegate {
    func attributedLabel(_ label: NantesLabel, didSelectLink link: URL) {
        guard link.scheme == "https" || link.scheme == "http" else {
            if UIApplication.shared.canOpenURL(link) {
                UIApplication.shared.open(link)
            }
            return
        }
        RootViewController.instance.present(SFSafariViewController(url: link), animated: true)
    }
}
