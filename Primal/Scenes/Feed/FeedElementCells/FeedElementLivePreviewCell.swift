//
//  FeedElementLivePreviewCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 19. 8. 2025..
//

import UIKit

class FeedElementLivePreviewCell: FeedElementBaseCell, RegularFeedElementCell {
    static var cellID: String { "FeedElementLivePreviewCell" }
    
    let preview = LivePreviewView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(preview)
        preview
            .pinToSuperview(edges: .top, padding: 8)
            .pinToSuperview(edges: .bottom, padding: 0)
            .pinToSuperview(edges: .horizontal, padding: 16)
        
        preview.addGestureRecognizer(BindableTapGestureRecognizer(action: { [unowned self] in
            delegate?.postCellDidTap(self, .live)
        }))
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func update(_ parsedContent: ParsedContent) {
        super.update(parsedContent)
        
        guard let live = parsedContent.embeddedLive else { return }
        
        preview.setLive(live: live)
    }
}


class LivePreviewView: UIView, Themeable {
    let userImage = UserImageView(height: 40)
    
    let nameLabel = UILabel("", color: .foreground, font: .appFont(withSize: 14, weight: .bold))
    let nipLabel = UILabel("", color: .foreground4, font: .appFont(withSize: 14, weight: .regular))
    let titleLabel = UILabel("", color: .foreground, font: .appFont(withSize: 14, weight: .bold))
    
    let checkView = VerifiedView().constrainToSize(13)
    
    let liveDot = SpacerView(width: 6, height: 6, color: .live, priority: .required)
    let liveLabel = UILabel("Live", color: .foreground, font: .appFont(withSize: 12, weight: .regular))
    let startedLabel = UILabel("Started", color: .foreground4, font: .appFont(withSize: 12, weight: .regular))
    let countIcon = UIImageView(image: .liveViewersCount).constrainToSize(10)
    let countLabel = UILabel("--", color: .foreground4, font: .appFont(withSize: 12, weight: .regular))
    
    init() {
        super.init(frame: .zero)
        
        layer.cornerRadius = 8
        
        let nameStack = UIStackView([nameLabel, checkView, nipLabel])
        nameStack.spacing = 4
        nameStack.alignment = .center
        
        nameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        liveDot.layer.cornerRadius = 3
        let liveStack = UIStackView([liveDot, liveLabel, startedLabel, countIcon, countLabel])
        liveStack.spacing = 8
        liveStack.alignment = .center
        liveStack.setCustomSpacing(6, after: liveDot)
        liveStack.setCustomSpacing(4, after: countIcon)
        
        let vStack = UIStackView(axis: .vertical, [nameStack, titleLabel, liveStack])
        vStack.spacing = 6
        vStack.alignment = .leading
        titleLabel.numberOfLines = 2
        
        let mainStack = UIStackView([userImage, vStack])
        mainStack.spacing = 12
        mainStack.alignment = .top
        
        addSubview(mainStack)
        mainStack.pinToSuperview(padding: 12)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    func updateTheme() {
        backgroundColor = .background5
        
        [nameLabel, titleLabel, liveLabel].forEach { $0.textColor = .foreground }
        [nipLabel, startedLabel, countLabel].forEach { $0.textColor = .foreground4 }
        
        countIcon.tintColor = .foreground4
    }
    
    func setLive(live: ParsedLiveEvent) {
        updateTheme()
        
        userImage.setUserImage(live.user)
        
        nameLabel.text = live.user.data.firstIdentifier
        nipLabel.text = live.user.data.parsedNip
        checkView.user = live.user.data
        nipLabel.isHidden = checkView.isHidden
        
        titleLabel.text = live.title
        countLabel.text = live.event.participants.localized()
        startedLabel.text = live.startedText
        
        liveDot.backgroundColor = live.isLive ? .live : .foreground4
        liveLabel.isHidden = !live.isLive
    }
}
