//
//  FeedExploreCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 25.9.24..
//

import UIKit
import Kingfisher

class FeedExploreCell: UITableViewCell, Themeable {
    let feedImageView = UIImageView().constrainToSize(44)
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let background = UIView()
    
    let freePaidView = FreePaidInfoView().constrainToSize(width: 44)
    
    let likeButton = FeedLikeButton()
    let zapButton = FeedZapButton()
    
    let avatarView = AvatarView(size: 20, spacing: -6)
    
    weak var delegate: FeedMarketplaceCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        contentView.addSubview(background)
        background.pinToSuperview(edges: .top, padding: 6).pinToSuperview(edges: .bottom, padding: 10).pinToSuperview(edges: .horizontal, padding: 16)
        background.layer.cornerRadius = 8
        
        let titleStack = UIStackView(axis: .vertical, [titleLabel, subtitleLabel])
        titleStack.distribution = .equalSpacing
        
        let topStack = UIStackView([feedImageView, titleStack])
        topStack.spacing = 12
        
        feedImageView.layer.cornerRadius = 22
        feedImageView.clipsToBounds = true
        
        let botStack = UIStackView([freePaidView, likeButton, zapButton, UIView(), avatarView])
        botStack.spacing = 12
        botStack.alignment  = .center
        botStack.setCustomSpacing(4, after: freePaidView)
        botStack.setCustomSpacing(0, after: zapButton)
        
        let mainStack = UIStackView(axis: .vertical, [topStack, botStack])
        mainStack.spacing = 2.5
        background.addSubview(mainStack)
        mainStack.pinToSuperview(edges: [.top, .horizontal], padding: 16).pinToSuperview(edges: .bottom, padding: 4.5)
        
        titleLabel.font = .appFont(withSize: 16, weight: .bold)
        subtitleLabel.font = .appFont(withSize: 14, weight: .regular)
        subtitleLabel.numberOfLines = 1
        
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
        
        updateTheme()
    }
    
    func updateTheme() {
        avatarView.setBorderColor(.background5)
        background.backgroundColor = .background5
        
        subtitleLabel.textColor = .foreground2
        titleLabel.textColor = .foreground
    }
}

extension FeedExploreCell: AnimatingZappingView, AnimatingLikingView {
    var zapIconToPin: UIView? { zapButton.iconView }
    
    var animatingZappingButton: FeedZapButton? { zapButton }
}
