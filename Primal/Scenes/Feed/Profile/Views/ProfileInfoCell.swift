//
//  ProfileInfoCell.swift
//  Primal
//
//  Created by Pavle D Stevanović on 8.6.23..
//

import Combine
import Nantes
import UIKit
import GenericJSON
import Lottie

protocol ProfileInfoCellDelegate: AnyObject {
    func followPressed(in cell: ProfileInfoCell)
    func qrPressed()
    func zapPressed()
    func editProfilePressed()
    func messagePressed()
    func linkPressed(_ url: URL?)
    func followersPressed()
    func followingPressed()
    
    func didSelectTab(_ tab: Int)
}

class ProfileCellNantesDelegate {
    weak var cell: ProfileInfoCell?
    init(cell: ProfileInfoCell) {
        self.cell = cell
    }
}

class ProfileInfoCell: UITableViewCell {
    let qrButton = CircleIconButton(icon: UIImage(named: "profileQR"))
    let zapButton = CircleIconButton(icon: UIImage(named: "profileZap"))
    let messageButton = CircleIconButton(icon: UIImage(named: "profileMessage"))
    let followButton = BrightSmallButton(title: "follow").constrainToSize(width: 100)
    let unfollowButton = RoundedSmallButton(text: "unfollow").constrainToSize(width: 100)
    let editProfile = RoundedSmallButton(text: "edit profile")
    
    let followingLabel = UILabel()
    let followersLabel = UILabel()
    let followingLoadingView = LottieAnimationView(animation: Theme.current.isDarkTheme ? AnimationType.smallPillLoader.animation : AnimationType.smallPillLoaderLight.animation).constrainToSize(width: 190 / 6, height: 80 / 6)
    let followersLoadingView = LottieAnimationView(animation: Theme.current.isDarkTheme ? AnimationType.smallPillLoader.animation : AnimationType.smallPillLoaderLight.animation).constrainToSize(width: 190 / 6, height: 80 / 6)
    
    let primaryLabel = UILabel()
    let checkboxIcon = UIImageView(image: UIImage(named: "purpleVerified")).constrainToSize(20)
    let followsYou = FollowsYouView()
    
    let secondaryLabel = UILabel()
    let descLabel = NantesLabel()
    let linkView = UILabel()
    let followedByView = FollowedByView()
    
    let infoStack = ProfileTabSelectionView(tabs: ["notes", "replies", "reads", "media"])
    
    weak var delegate: ProfileInfoCellDelegate?
    
    lazy var nantesDelegate = ProfileCellNantesDelegate(cell: self)
    
    var cancellables: Set<AnyCancellable> = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    func update(user: PrimalUser, parsedDescription: NSAttributedString, stats: NostrUserProfileInfo?, followedBy: [ParsedUser]?, followsUser: Bool, selectedTab: Int, delegate: ProfileInfoCellDelegate?) {
        self.delegate = delegate
        
        primaryLabel.text = user.firstIdentifier
        primaryLabel.isHidden = primaryLabel.text == user.npub
        
        followsYou.isHidden = !followsUser
        
        if CheckNip05Manager.instance.isVerified(user) {
            checkboxIcon.isHidden = false
            checkboxIcon.tintColor = .accent
            
            secondaryLabel.isHidden = false
            secondaryLabel.text = user.parsedNip
        } else {
            checkboxIcon.isHidden = true
            secondaryLabel.isHidden = true
        }
        
        descLabel.attributedText = parsedDescription
        linkView.text = user.website.trimmingCharacters(in: .whitespaces)
        
        if let stats {
            infoStack.isLoading = false
            followersLoadingView.isHidden = true
            followingLoadingView.isHidden = true
            
            followingLabel.attributedText = infoString(count: stats.follows, text: "following")
            followersLabel.attributedText = infoString(count: stats.followers, text: "followers")
            
            zip(infoStack.buttons, [stats.notes, stats.replies, stats.articles, stats.media]).forEach { button, count in
                button.text = count.shortenedLocalized()
                button.isEnabled = count > 0
            }
        } else {
            followingLabel.attributedText = infoString(text: "following")
            followersLabel.attributedText = infoString(text: "followers")
            
            infoStack.isLoading = true
            followersLoadingView.isHidden = false
            followingLoadingView.isHidden = false
            
            followersLoadingView.play()
            followingLoadingView.play()
        }
        
        followedByView.setUsers(followedBy)
        followedByView.isHidden = followedBy?.isEmpty == true
        
        infoStack.set(selectedTab)
        
        editProfile.isHidden = !user.isCurrentUser
        zapButton.isHidden = user.isCurrentUser

        if user.isCurrentUser {
            followButton.isHidden = true
            unfollowButton.isHidden = true
        } else {
            updateFollowButton(FollowManager.instance.isFollowing(user.pubkey))
        }
    }
    
    func updateFollowButton(_ isFollowing: Bool) {
        followButton.isHidden = isFollowing
        unfollowButton.isHidden = !isFollowing
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func infoString(count: Int32? = nil, text: String) -> NSAttributedString {
        let countString: String
        if let count {
            countString = "\(count.localized()) "
        } else {
            countString = "           "
        }
        
        let mutable = NSMutableAttributedString(string: countString, attributes: [
            .font: UIFont.appFont(withSize: 14, weight: .bold),
            .foregroundColor: UIColor.foreground
        ])
        
        mutable.append(.init(string: text, attributes: [
            .font: UIFont.appFont(withSize: 14, weight: .regular),
            .foregroundColor: UIColor.foreground3
        ]))
        
        return mutable
    }
}

extension ProfileCellNantesDelegate: NantesLabelDelegate {
    func attributedLabel(_ label: NantesLabel, didSelectLink link: URL) {
        cell?.delegate?.linkPressed(link)
    }
}

private extension ProfileInfoCell {
    func setup() {
        let actionStack = UIStackView(arrangedSubviews: [SpacerView(width: 400, priority: .defaultLow), qrButton, zapButton, messageButton, followButton, unfollowButton, editProfile])
        actionStack.spacing = 8
        actionStack.alignment = .bottom
        
        let primaryStack = UIStackView(arrangedSubviews: [primaryLabel, checkboxIcon, followsYou, UIView()])
        primaryStack.spacing = 4
        primaryStack.alignment = .center
        
        primaryLabel.font = .appFont(withSize: 20, weight: .bold)
        primaryLabel.adjustsFontSizeToFitWidth = true
        
        let followStack = UIStackView([followingLabel, followersLabel])
        followStack.spacing = 8
        followingLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        followsYou.isHidden = true
        
        secondaryLabel.font = .appFont(withSize: 14, weight: .regular)
        
        descLabel.font = .appFont(withSize: 14, weight: .regular)
        descLabel.numberOfLines = 0
        
        let mainStack = UIStackView(arrangedSubviews: [actionStack, primaryStack, secondaryLabel, followStack, descLabel, linkView, followedByView, infoStack])
        mainStack.axis = .vertical
        mainStack.alignment = .leading
        mainStack.setCustomSpacing(14, after: actionStack)
        mainStack.setCustomSpacing(8, after: primaryStack)
        mainStack.setCustomSpacing(12, after: secondaryLabel)
        mainStack.setCustomSpacing(10, after: followStack)
        mainStack.setCustomSpacing(8, after: descLabel)
        mainStack.setCustomSpacing(10, after: linkView)
        mainStack.setCustomSpacing(10, after: followedByView)
        
        infoStack.pinToSuperview(edges: .horizontal)
        
        contentView.addSubview(mainStack)
        mainStack.pinToSuperview(edges: [.horizontal, .top], padding: 12)
        let bot = mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        bot.priority = .defaultHigh
        bot.isActive = true
        
        contentView.addSubview(followersLoadingView)
        followersLoadingView.pin(to: followersLabel, edges: .leading).centerToView(followersLabel, axis: .vertical)
        contentView.addSubview(followingLoadingView)
        followingLoadingView.pin(to: followingLabel, edges: .leading).centerToView(followingLabel, axis: .vertical)
        followersLoadingView.loopMode = .loop
        followingLoadingView.loopMode = .loop
        
        contentView.backgroundColor = .background2
        primaryLabel.textColor = .foreground
        secondaryLabel.textColor = .foreground3
        descLabel.textColor = .foreground
        
        descLabel.enabledTextCheckingTypes = .allSystemTypes
        descLabel.linkAttributes = [
            .foregroundColor: UIColor.accent
        ]
        descLabel.delegate = nantesDelegate
        
        linkView.font = .appFont(withSize: 14, weight: .regular)
        linkView.textColor = .accent
        linkView.isUserInteractionEnabled = true
        linkView.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.delegate?.linkPressed(nil)
        }))
        
        followButton.addTarget(self, action: #selector(followPressed), for: .touchUpInside)
        unfollowButton.addTarget(self, action: #selector(followPressed), for: .touchUpInside)
        
        qrButton.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.qrPressed()
        }), for: .touchUpInside)
        
        editProfile.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.editProfilePressed()
        }), for: .touchUpInside)
        zapButton.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.zapPressed()
        }), for: .touchUpInside)
        messageButton.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.messagePressed()
        }), for: .touchUpInside)
        
        infoStack.$selectedTab.removeDuplicates().dropFirst().sink { [weak self] tab in
            self?.delegate?.didSelectTab(tab)
        }
        .store(in: &cancellables)
        
        followingLabel.isUserInteractionEnabled = true
        followingLabel.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in self?.delegate?.followingPressed() }))
        followersLabel.isUserInteractionEnabled = true
        followersLabel.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in self?.delegate?.followersPressed() }))
    }
    
    @objc func followPressed() {
        delegate?.followPressed(in: self)
    }
}

final class FollowsYouView: UIView {
    let label = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        addSubview(label)
        label.pinToSuperview(edges: .horizontal, padding: 8).centerToSuperview()
        label.font = .appFont(withSize: 14, weight: .regular)
        label.text = "follows you"
        
        constrainToSize(height: 22)
        
        layer.cornerRadius = 4
        
        label.textColor = .foreground3
        backgroundColor = .background3
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
