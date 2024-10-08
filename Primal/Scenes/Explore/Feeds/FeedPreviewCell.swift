//
//  FeedPreviewCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 26.9.24..
//

import UIKit
import Kingfisher

class FeedPreviewCell: UITableViewCell, Themeable {
    let feedImageView = UIImageView().constrainToSize(44)
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    
    let freePaidView = FreePaidInfoView().constrainToSize(width: 44)
    
    let likeButton = FeedLikeButton()
    let zapButton = FeedZapButton()
    
    let createdByPrimalView = CreatedByPrimalView()
    
    let extraSpacerView = SpacerView(height: 12)
    
    let avatarView = AvatarView(size: 20, spacing: -6)
    
    weak var delegate: FeedMarketplaceCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        feedImageView.layer.cornerRadius = 22
        feedImageView.clipsToBounds = true
        
        let leftStack = UIStackView(axis: .vertical, [feedImageView, freePaidView])
        leftStack.spacing = 8
        
        let botStackStandin = SpacerView(height: 22)
        let rightStack = UIStackView(axis: .vertical, [titleLabel, subtitleLabel, createdByPrimalView, botStackStandin])
        rightStack.spacing = 12
        
        let mainStack = UIStackView(axis: .horizontal, [leftStack, rightStack])
        mainStack.spacing = 16
        mainStack.alignment = .top
        contentView.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .vertical, padding: 12)
        
        let botStack = UIStackView([likeButton, zapButton, UIView(), avatarView])
        botStack.spacing = 12
        botStack.alignment  = .center
        contentView.addSubview(botStack)
        botStack.pin(to: botStackStandin, edges: .trailing).centerToView(botStackStandin, axis: .vertical).pin(to: botStackStandin, edges: .leading, padding: -8)
        
        titleLabel.font = .appFont(withSize: 16, weight: .bold)
        subtitleLabel.font = .appFont(withSize: 14, weight: .regular)
        subtitleLabel.numberOfLines = 0
        titleLabel.numberOfLines = 0
        
        likeButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            delegate?.likeButtonPressedInFeedCell(self)
        }), for: .touchUpInside)
        
        zapButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            delegate?.zapButtonPressedInFeedCell(self)
        }), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setup(_ parsed: ParsedFeedFromMarket, delegate: FeedMarketplaceCellDelegate) {
        self.delegate = delegate
        
        let feed = parsed.data
        
        titleLabel.text = feed.name
        subtitleLabel.text = feed.about
        
        let defaultImage = UIImage(named: "dvmDefault")?.withTintColor(.foreground6).withRenderingMode(.alwaysOriginal)
        
        feedImageView.kf.setImage(with: URL(string: feed.picture ?? feed.image ?? ""), placeholder: defaultImage, options: [
            .scaleFactor(UIScreen.main.scale),
            .cacheOriginalImage,
            .processor(ResizingImageProcessor(referenceSize: .init(width: 40, height: 40)))
        ])
        
        freePaidView.state = feed.subscription == true ? .paid : .free
        
        likeButton.set(parsed.stats?.likes ?? 0, filled: PostingManager.instance.hasLiked(parsed.stats?.event_id ?? ""))
        zapButton.set(parsed.stats?.satszapped ?? 0, filled: WalletManager.instance.hasZapped(parsed.stats?.event_id ?? ""))
        
        let images = parsed.users.compactMap { $0.profileImage.url(for: .small) }
        if images.isEmpty {
            avatarView.isHidden = true
        } else {
            avatarView.isHidden = false
            avatarView.setImages(images, userCount: 0)
        }
        
        createdByPrimalView.isHidden = parsed.metadata?.is_primal != true
        extraSpacerView.isHidden = parsed.metadata?.is_primal != true
        
        updateTheme()
    }
    
    func updateTheme() {
        avatarView.setBorderColor(.background3)
        contentView.backgroundColor = .background3
        
        subtitleLabel.textColor = .foreground2
        titleLabel.textColor = .foreground
        
        createdByPrimalView.updateTheme()
    }
}

class CreatedByPrimalView: UIView, Themeable {
    let icon = UIImageView(image: UIImage(named: "sunsetWaveIcon16"))
    let label = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        let stack = UIStackView([icon, label])
        stack.alignment = .center
        stack.spacing = 6
        addSubview(stack)
        stack.pinToSuperview()
        
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        icon.setContentHuggingPriority(.required, for: .horizontal)
        
        updateTheme()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        let text = NSMutableAttributedString(string: "Created by ", attributes: [
            .font: UIFont.appFont(withSize: 15, weight: .regular),
            .foregroundColor: UIColor.foreground3
        ])
        text.append(.init(string: "Primal", attributes: [
            .font: UIFont.appFont(withSize: 15, weight: .bold),
            .foregroundColor: UIColor.foreground
        ]))
        label.attributedText = text
    }
}

extension FeedPreviewCell: AnimatingLikingView, AnimatingZappingView {
    var zapIconToPin: UIView? { zapButton.iconView }
    
    var animatingZappingButton: FeedZapButton? { zapButton }
}
