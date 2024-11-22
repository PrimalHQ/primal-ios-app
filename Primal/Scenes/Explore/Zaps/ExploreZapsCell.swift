//
//  ExploreZapsCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 8.10.24..
//

import UIKit
import FLAnimatedImage

final class ExploreZapsCell: UITableViewCell, Themeable {
    let avatar = UserImageView(height: 36)
    let name = UILabel()
    let dotLabel = UILabel()
    let timeLabel = UILabel()
    let desc = UILabel()
    
    let secondRow = UIStackView()
        
    let background = UIView()
    let firstRowBackground = UIView()
    let firstRowImage = UserImageView(height: 36)
    let zapIcon = UIImageView(image: UIImage(named: "topZapGalleryIcon"))
    let zapAmount = UILabel()
    let zapText = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateForZap(_ parsedZap: ParsedFeedZap) {
        let zap = parsedZap.zap
        firstRowImage.setUserImage(zap.user)
        zapAmount.text = zap.amountSats.localized()
        zapText.text = zap.message
        
        let zappedUser = parsedZap.zappedObject.userToZap
        
        if let time = parsedZap.zappedObject.referenceTime {
            timeLabel.text = Date(timeIntervalSince1970: TimeInterval(time)).timeAgoDisplay()
            timeLabel.isHidden = false
            dotLabel.isHidden = false
        } else {
            timeLabel.isHidden = true
            dotLabel.isHidden = true
        }
        avatar.setUserImage(zappedUser, feed: true)
        name.text = zappedUser.data.firstIdentifier
        desc.text = parsedZap.zappedObject.description.trimmingCharacters(in: .whitespacesAndNewlines)
        desc.isHidden = desc.text?.isEmpty != false
        
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
        
        zapAmount.font = .appFont(withSize: 16, weight: .heavy)
        
        zapText.font = .appFont(withSize: 16, weight: .regular)
        zapText.lineBreakMode = .byTruncatingTail
        
        firstRowBackground.addSubview(firstRow)
        firstRow.pinToSuperview(edges: [.leading, .vertical], padding: 1).pinToSuperview(edges: .trailing, padding: 20)
        firstRowBackground.layer.cornerRadius = 19
        
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
        background.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .bottom, padding: 16).pinToSuperview(edges: .top)
        
        background.addSubview(mainStack)
        mainStack.pinToSuperview(edges: [.horizontal, .top], padding: 8).pinToSuperview(edges: .bottom, padding: 12)
        
        background.layer.cornerRadius = 8
        
        name.font = .appFont(withSize: 16, weight: .bold)
        timeLabel.font = .appFont(withSize: 16, weight: .regular)
        dotLabel.font = .appFont(withSize: 16, weight: .regular)
        desc.font = .appFont(withSize: 15, weight: .regular)
        desc.numberOfLines = 2
        desc.lineBreakMode = .byTruncatingTail
        desc.setContentHuggingPriority(.required, for: .vertical)
        
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
