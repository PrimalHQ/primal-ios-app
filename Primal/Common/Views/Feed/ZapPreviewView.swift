//
//  ZapPreviewView.swift
//  Primal
//
//  Created by Pavle Stevanović on 4.11.24..
//

import UIKit
import FLAnimatedImage

final class ZapPreviewView: UIView, Themeable {
    let avatar = UserImageView(height: 36)
    let name = UILabel()
    let dotLabel = UILabel()
    let timeLabel = UILabel()
    let desc = UILabel()
    
    var extraSpacers: [UIView] = []
    
    let secondRow = UIStackView()
        
    let background = UIView()
    
    let firstRowBackground = UIView()
    let firstRowImage = UserImageView(height: 36)
    let backupRecipientAvatar = UserImageView(height: 31)
    let backupRecipientName = UILabel()
    let backupSpacer = SpacerView(width: 8)
    let zapIcon = UIImageView(image: UIImage(named: "topZapGalleryIcon"))
    let zapAmount = UILabel()
    let zapText = UILabel()
    
    
    init() {
        super.init(frame: .zero)
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
        
        if let post = parsedZap.zappedObject as? ParsedContent {
            backupRecipientAvatar.isHidden = true
            backupRecipientName.isHidden = true
            secondRow.isHidden = false
            
            avatar.setUserImage(zappedUser, feed: true)
            name.text = zappedUser.data.firstIdentifier
            
            desc.text = parsedZap.zappedObject.description.trimmingCharacters(in: .whitespacesAndNewlines)
            desc.isHidden = desc.text?.isEmpty != false
            
            background.layer.cornerRadius = 8
            backupSpacer.isHidden = false
            extraSpacers.forEach { $0.isHidden = true }
        } else {
            backupRecipientAvatar.isHidden = false
            backupRecipientName.isHidden = false
            secondRow.isHidden = true
            
            backupRecipientAvatar.setUserImage(zappedUser, feed: true)
            backupRecipientName.text = zappedUser.data.firstIdentifier
            
            background.layer.cornerRadius = 27
            backupSpacer.isHidden = true
            extraSpacers.forEach { $0.isHidden = false }
        }
        
        if let time = parsedZap.zappedObject.referenceTime {
            timeLabel.text = Date(timeIntervalSince1970: TimeInterval(time)).timeAgoDisplay()
            timeLabel.isHidden = false
            dotLabel.isHidden = false
        } else {
            timeLabel.isHidden = true
            dotLabel.isHidden = true
        }
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
        backupRecipientName.textColor = .foreground2
        
        background.backgroundColor = .background5
        firstRowBackground.backgroundColor = .background2
    }
}

private extension ZapPreviewView {
    func setup() {
        let small1 = SpacerView(width: 8)
        let small2 = SpacerView(width: 8)
        extraSpacers = [small1, small2]
        let firstRowBackgroundStack = UIStackView([firstRowImage, small1, zapIcon, zapAmount, zapText, small2, backupRecipientAvatar, backupSpacer])
        firstRowBackgroundStack.alignment = .center
        firstRowBackgroundStack.spacing = 8
        firstRowBackgroundStack.setCustomSpacing(2, after: zapIcon)
        
        zapAmount.font = .appFont(withSize: 16, weight: .heavy)
        
        zapText.font = .appFont(withSize: 16, weight: .regular)
        zapText.lineBreakMode = .byTruncatingTail
        
        firstRowBackground.addSubview(firstRowBackgroundStack)
        firstRowBackgroundStack.pinToSuperview(edges: [.leading, .vertical], padding: 1).pinToSuperview(edges: .trailing, padding: 4)

        firstRowBackground.layer.cornerRadius = 19
        
        let firstRow = UIStackView([firstRowBackground, backupRecipientName])
        firstRow.spacing = 8
        firstRow.alignment = .center
        
        let nameRow = UIStackView([name, dotLabel, timeLabel])
        nameRow.alignment = .center
        nameRow.spacing = 4
        
        let contentStack = UIStackView(axis: .vertical, [nameRow, desc])
        
        [avatar, contentStack].forEach { secondRow.addArrangedSubview($0) }
        secondRow.spacing = 8
        secondRow.alignment = .top
        
        let mainStack = UIStackView(axis: .vertical, [firstRow, secondRow])
        mainStack.spacing = 8
        
        addSubview(background)
        background.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .bottom, padding: 16).pinToSuperview(edges: .top)
        
        background.addSubview(mainStack)
        mainStack.pinToSuperview(edges: [.horizontal, .top], padding: 8).pinToSuperview(edges: .bottom, padding: 12)
        
        name.font = .appFont(withSize: 16, weight: .bold)
        backupRecipientName.font = .appFont(withSize: 14, weight: .regular)
        timeLabel.font = .appFont(withSize: 16, weight: .regular)
        dotLabel.font = .appFont(withSize: 16, weight: .regular)
        desc.font = .appFont(withSize: 15, weight: .regular)
        desc.numberOfLines = 2
        desc.lineBreakMode = .byTruncatingTail
        desc.setContentHuggingPriority(.required, for: .vertical)
        
        backupRecipientName.textAlignment = .center
        
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
