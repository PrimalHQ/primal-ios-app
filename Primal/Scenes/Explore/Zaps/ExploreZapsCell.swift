//
//  ExploreZapsCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 8.10.24..
//

import UIKit
import FLAnimatedImage

final class ExploreZapsCell: UITableViewCell, Themeable {
    let avatar = FLAnimatedImageView()
    let name = UILabel()
    let dotLabel = UILabel()
    let timeLabel = UILabel()
    let desc = UILabel()
    
    let secondRow = UIStackView()
        
    let background = UIView()
    let firstRowBackground = UIView()
    let firstRowImage = FLAnimatedImageView().constrainToSize(28)
    let zapIcon = UIImageView(image: UIImage(named: "topZapGalleryIcon"))
    let zapAmount = UILabel()
    let zapText = UILabel()
    
    weak var delegate: ProfileFollowCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateForZap(_ parsedZap: ParsedFeedZap) {
        let zap = parsedZap.zap
        let user = zap.user.data
        
        name.text = user.firstIdentifier
        
        if let time = parsedZap.zappedObject.referenceTime {
            timeLabel.text = Date(timeIntervalSince1970: TimeInterval(time)).timeAgoDisplay()
            timeLabel.isHidden = false
            dotLabel.isHidden = false
        } else {
            timeLabel.isHidden = true
            dotLabel.isHidden = true
        }
        
        firstRowImage.setUserImage(zap.user)
        
        desc.text = parsedZap.zappedObject.description
        desc.isHidden = desc.text?.isEmpty != false
        
        avatar.setUserImage(parsedZap.zappedObject.userToZap, feed: true, size: CGSize(width: 64, height: 64))
        
        zapAmount.text = zap.amountSats.localized()
        zapText.text = zap.message
        
        updateTheme()
    }
    
    func updateTheme() {
        name.textColor = .foreground2
        timeLabel.textColor = .foreground4
        desc.textColor = .foreground4
        dotLabel.textColor = .foreground4
        
        zapIcon.tintColor = .foreground
        zapAmount.textColor = .foreground
        zapText.textColor = .foreground2
        
        background.backgroundColor = .background5
        firstRowBackground.backgroundColor = .background2
    }
}

private extension ExploreZapsCell {
    func setup() {
        selectionStyle = .none
        
        let firstRow = UIStackView([firstRowImage, zapIcon, zapAmount, zapText])
        firstRow.alignment = .center
        firstRow.spacing = 8
        firstRow.setCustomSpacing(2, after: zapIcon)
        
        firstRowImage.contentMode = .scaleAspectFill
        firstRowImage.clipsToBounds = true
        firstRowImage.layer.cornerRadius = 14
        
        zapAmount.font = .appFont(withSize: 14, weight: .heavy)
        
        zapText.font = .appFont(withSize: 14, weight: .regular)
        zapText.lineBreakMode = .byTruncatingTail
        
        firstRowBackground.addSubview(firstRow)
        firstRow.pinToSuperview(edges: [.leading, .vertical], padding: 1).pinToSuperview(edges: .trailing, padding: 20)
        firstRowBackground.layer.cornerRadius = 15
        
        let nameRow = UIStackView([name, dotLabel, timeLabel])
        nameRow.alignment = .center
        nameRow.spacing = 4
        
        let contentStack = UIStackView(axis: .vertical, [nameRow, desc])
        
        [avatar, contentStack].forEach { secondRow.addArrangedSubview($0) }
        secondRow.spacing = 8
        secondRow.alignment = .top
        
        let mainStack = UIStackView(axis: .vertical, [firstRowBackground, secondRow])
        mainStack.spacing = 8
        
        contentView.addSubview(background)
        background.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .bottom, padding: 12).pinToSuperview(edges: .top)
        
        background.addSubview(mainStack)
        mainStack.pinToSuperview(edges: [.horizontal, .top], padding: 8).pinToSuperview(edges: .bottom, padding: 12)
        
        background.layer.cornerRadius = 8
        
        avatar.constrainToSize(28)
        avatar.contentMode = .scaleAspectFill
        avatar.layer.cornerRadius = 14
        avatar.layer.masksToBounds = true
        
        name.font = .appFont(withSize: 14, weight: .bold)
        timeLabel.font = .appFont(withSize: 14, weight: .regular)
        dotLabel.font = .appFont(withSize: 14, weight: .regular)
        desc.font = .appFont(withSize: 14, weight: .regular)
        desc.numberOfLines = 2
        desc.lineBreakMode = .byTruncatingTail
        
        timeLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        zapText.setContentHuggingPriority(.defaultLow, for: .horizontal)
        name.setContentHuggingPriority(.required, for: .horizontal)
        [zapIcon, zapAmount, dotLabel].forEach {
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
        
        dotLabel.text = "•"
        
        updateTheme()
    }
}
