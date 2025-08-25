//
//  LiveVideoDetailsController.swift
//  Primal
//
//  Created by Pavle Stevanović on 12. 8. 2025..
//


import UIKit
import Nantes
import SafariServices

class LiveVideoDetailsController: UIViewController, LiveVideoUserDetailsViewControllerProtocol, Themeable {
    let live: ParsedLiveEvent
    init(live: ParsedLiveEvent) {
        self.live = live
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    var userForDetails: ParsedUser { live.user }
    
    private let pullbar = PullBarView(color: .foreground5.withAlphaComponent(0.8))
    private lazy var nameLabel = UILabel(live.user.data.firstIdentifier, color: .foreground, font: .appFont(withSize: 18, weight: .bold))
    private lazy var followersLabel = UILabel("\(live.user.followersSafe.localized()) followers", color: .foreground4, font: .appFont(withSize: 16, weight: .regular))
    private let infoBackground = UIView()
    private let descBackground = UIScrollView()
    private let border = SpacerView(height: 1, color: .foreground6)
    
    private lazy var titleLabel = UILabel(live.title, color: .foreground, font: .appFont(withSize: 16, weight: .semibold))
    
    private let qrButton = CircleIconButton(icon: UIImage(named: "profileQR"))
    private let zapButton = CircleIconButton(icon: UIImage(named: "profileZap"))
    private let messageButton = CircleIconButton(icon: UIImage(named: "profileMessage"))
    internal let followButton = BrightSmallButton(title: "follow").constrainToSize(width: 100)
    internal let unfollowButton = RoundedSmallButton(text: "unfollow").constrainToSize(width: 100)
    
    private let liveLabel = UILabel("Live", color: .foreground4, font: .appFont(withSize: 14, weight: .regular))
    private let startedLabel = UILabel("Started", color: .foreground4, font: .appFont(withSize: 14, weight: .regular))
    private let countLabel = UILabel("--", color: .foreground4, font: .appFont(withSize: 14, weight: .regular))
    private let countIcon = UIImageView(image: .liveViewersCount).constrainToSize(12)
    
    private let descLabel = NantesLabel()
    
    private let backgroundExtender = SpacerView(height: 200, priority: .required)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoBackground.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        infoBackground.layer.cornerRadius = 16
        
        let imageView = UserImageView(height: 48)
        imageView.setUserImage(live.user)
        let infoStack = UIStackView([imageView, UIStackView(axis: .vertical, [nameLabel, followersLabel])])
        let actionStack = UIStackView([UIView(), qrButton, zapButton, messageButton, followButton, unfollowButton])
        
        let topStack = UIStackView(axis: .vertical, [pullbar, infoStack, actionStack])
        
        infoBackground.addSubview(topStack)
        topStack.pinToSuperview(edges: .horizontal, padding: 24).pinToSuperview(edges: .vertical, padding: 16)
        
        let isFollowing = FollowManager.instance.isFollowing(live.user.data.pubkey)
        let isCurrentUser = live.user.data.pubkey == IdentityManager.instance.userHexPubkey
        followButton.isHidden = isCurrentUser || isFollowing
        unfollowButton.isHidden = isCurrentUser || !isFollowing
        actionStack.isHidden = isCurrentUser
        
        topStack.spacing = 16
        infoStack.spacing = 12
        infoStack.alignment = .center
        actionStack.spacing = 6
        actionStack.alignment = .center
        
        let mainStack = UIStackView(axis: .vertical, [infoBackground, border, descBackground, backgroundExtender])
        view.addSubview(mainStack)
        mainStack.pinToSuperview(edges: [.top, .horizontal]).pinToSuperview(edges: .bottom, padding: -200)
        
        let liveDot = SpacerView(width: 6, height: 6, color: .live, priority: .required)
        liveDot.layer.cornerRadius = 3
        let liveStack = UIStackView([liveDot, liveLabel, SpacerView(width: 4), startedLabel, SpacerView(width: 4), countIcon, countLabel])
        liveStack.alignment = .center
        liveStack.spacing = 4
        
        let descStack = UIStackView(axis: .vertical, [titleLabel, SpacerView(height: 4), liveStack, SpacerView(height: 16), descLabel])
        descStack.alignment = .leading
        
        descBackground.addSubview(descStack)
        descStack.pinToSuperview(padding: 24).pin(to: view, edges: .horizontal, padding: 24)
        
        titleLabel.numberOfLines = 0
        
        descLabel.numberOfLines = 0
        descLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        descLabel.enabledTextCheckingTypes = .link
        descLabel.delegate = self
        
        updateTheme()
        
        view.addGestureRecognizer(LivePopupDismissGesture(vc: self))
        followButton.addAction(.init(handler: { [weak self] _ in self?.followTapped() }), for: .touchUpInside)
        unfollowButton.addAction(.init(handler: { [weak self] _ in self?.unfollowTapped() }), for: .touchUpInside)
        qrButton.addAction(.init(handler: { [weak self] _ in self?.qrTapped() }), for: .touchUpInside)
        zapButton.addAction(.init(handler: { [weak self] _ in self?.zapTapped() }), for: .touchUpInside)
        messageButton.addAction(.init(handler: { [weak self] _ in self?.messageTapped() }), for: .touchUpInside)
        imageView.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in self?.openUserProfile() }))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        countLabel.text = live.event.participants.localized()
        startedLabel.text = live.startedText
        titleLabel.text = live.title
        
        updateFollowButtons()
    }
    
    func updateTheme() {
        infoBackground.backgroundColor = .background4
        descBackground.backgroundColor = .background3
        backgroundExtender.backgroundColor = .background3
        
        pullbar.pullBar.backgroundColor = .foreground5.withAlphaComponent(0.8)
        
        descLabel.linkAttributes = [.foregroundColor: UIColor.accent]
        
        liveLabel.textColor = .foreground4
        startedLabel.textColor = .foreground4
        countLabel.textColor = .foreground4
        countIcon.tintColor = .foreground4
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 7
        descLabel.attributedText = .init(string: live.event.summary, attributes: [
            .paragraphStyle: paragraph,
            .font: UIFont.appFont(withSize: 15, weight: .regular),
            .foregroundColor: UIColor.foreground3
        ])
    }
}

extension LiveVideoDetailsController: NantesLabelDelegate {
    func attributedLabel(_ label: NantesLabel, didSelectLink link: URL) {
        let handler = PrimalWebsiteScheme.shared
        if handler.canOpenURL(link) {
            dismiss(animated: true) {
                handler.openURL(link)
            }
        } else {
            present(SFSafariViewController(url: link), animated: true)
        }
    }
}
