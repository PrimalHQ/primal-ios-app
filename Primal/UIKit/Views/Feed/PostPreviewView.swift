//
//  PostPreviewView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 30.5.23..
//

import UIKit
import Kingfisher

final class PostPreviewView: UIView {
    let profileImageView = UIImageView()
    let nameLabel = UILabel()
    let timeLabel = UILabel()
    let secondaryIdentifierLabel = UILabel()
    let verifiedBadge = UIImageView(image: UIImage(named: "feedVerifiedBadge"))
    let mainLabel = LinkableLabel()

    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ content: ParsedContent) {
        nameLabel.text = content.user.firstIdentifier
        secondaryIdentifierLabel.text = content.user.nip05
        verifiedBadge.isHidden = content.user.nip05.isEmpty
        
        let date = Date(timeIntervalSince1970: TimeInterval(content.post.created_at))
        timeLabel.text = date.timeAgoDisplay()
        
        profileImageView.kf.setImage(with: URL(string: content.user.picture), options: [
            .processor(DownsamplingImageProcessor(size: CGSize(width: 28, height: 28))),
            .scaleFactor(UIScreen.main.scale),
            .cacheOriginalImage
        ])
        
        mainLabel.attributedText = content.attributedText
    }
}

private extension PostPreviewView {
    func setup() {
        backgroundColor = .background4
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.background3.cgColor
        
        let separatorLabel = UILabel()
        separatorLabel.text = "|"
        [timeLabel, separatorLabel, secondaryIdentifierLabel].forEach {
            $0.font = .appFont(withSize: 16, weight: .regular)
            $0.textColor = .foreground3
            $0.adjustsFontSizeToFitWidth = true
        }
        
        profileImageView.constrainToSize(28)
        profileImageView.layer.cornerRadius = 14
        profileImageView.layer.masksToBounds = true
        
        nameLabel.textColor = .foreground
        nameLabel.font = .appFont(withSize: 16, weight: .bold)
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        mainLabel.numberOfLines = 0
        mainLabel.font = UIFont.appFont(withSize: 16, weight: .regular)
        
        let nameTimeStack = UIStackView(arrangedSubviews: [
            profileImageView, nameLabel, verifiedBadge, secondaryIdentifierLabel,
            SpacerView(width: 0), separatorLabel, SpacerView(width: 0), timeLabel, UIView()
        ])
        nameTimeStack.spacing = 4
        nameTimeStack.alignment = .center
        
        let mainStack = UIStackView(arrangedSubviews: [nameTimeStack, mainLabel])
        mainStack.axis = .vertical
        mainStack.spacing = 12
        addSubview(mainStack)
        
        mainStack
            .pinToSuperview(edges: .horizontal, padding: 20)
            .pinToSuperview(edges: .vertical, padding: 16)
        
        // USER INTERACTION DISABLED FOR SUBVIEWS
        mainStack.isUserInteractionEnabled = false
    }
}
