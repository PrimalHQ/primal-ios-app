//
//  LiveVideoMessageDetailsController.swift
//  Primal
//
//  Created by Pavle Stevanović on 13. 8. 2025..
//

import UIKit
import Nantes
import SafariServices

extension UIButton.Configuration {
    static func liveMuteButton() -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        
        config.cornerStyle = .capsule
        config.image = .menuMute.withTintColor(.foreground, renderingMode: .alwaysTemplate).scalePreservingAspectRatio(size: 16)
        config.baseBackgroundColor = .background3
        config.imagePadding = 8
        config.attributedTitle = .init("Mute", attributes: .init([
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .foregroundColor: UIColor.foreground
        ]))
        
        return config
    }
    
    static func reportLiveMessageButton() -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        
        config.cornerStyle = .capsule
        config.image = .menuReport.withTintColor(.foreground, renderingMode: .alwaysTemplate).scalePreservingAspectRatio(size: 16)
        config.baseBackgroundColor = .foreground6
        config.imagePadding = 8
        config.attributedTitle = .init("Report message", attributes: .init([
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .foregroundColor: UIColor.foreground
        ]))
        
        return config
    }
}

class LiveVideoMessageDetailsController: UIViewController, LiveVideoUserDetailsViewControllerProtocol, Themeable {
    let live: ParsedLiveEvent
    let message: ParsedLiveComment
    init(live: ParsedLiveEvent, message: ParsedLiveComment) {
        self.live = live
        self.message = message
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    var userForDetails: ParsedUser { message.user }
    
    private let pullbar = PullBarView(color: .foreground5.withAlphaComponent(0.8))
    private lazy var nameLabel = UILabel(userForDetails.data.firstIdentifier, color: .foreground, font: .appFont(withSize: 18, weight: .bold))
    private lazy var nipLabel = UILabel(userForDetails.data.secondIdentifier ?? "", color: .foreground5, font: .appFont(withSize: 14, weight: .regular))
    private lazy var followersLabel = UILabel(userForDetails.followersSafe.shortened(), color: .foreground, font: .appFont(withSize: 14, weight: .bold))
    private lazy var followersInfoLabel = UILabel("followers", color: .foreground5, font: .appFont(withSize: 14, weight: .regular))
    private let verifiedView = VerifiedView().constrainToSize(13)
    private let infoBackground = UIView()
    private let descBackground = UIScrollView()
    private let border = SpacerView(height: 1, color: .foreground6)
    
    private let muteButton = UIButton(configuration: .liveMuteButton()).constrainToSize(width: 94)
    private let qrButton = CircleIconButton(icon: UIImage(named: "profileQR"))
    private let zapButton = CircleIconButton(icon: UIImage(named: "profileZap"))
    private let messageButton = CircleIconButton(icon: UIImage(named: "profileMessage"))
    internal let followButton = BrightSmallButton(title: "follow").constrainToSize(width: 100)
    internal let unfollowButton = RoundedSmallButton(text: "unfollow").constrainToSize(width: 100)
    
    private let chatMessageLabel = UILabel("Chat Message", color: .foreground4, font: .appFont(withSize: 15, weight: .regular))
    private let messagePreview = LiveVideoChatMessageView()
    private let zapPreview = LiveVideoChatZapView()
    let zapPreviewBackground = UIView()
    private let reportButton = UIButton(configuration: .reportLiveMessageButton()).constrainToSize(width: 180)
    
    private let backgroundExtender = SpacerView(height: 200, priority: .required)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoBackground.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        infoBackground.layer.cornerRadius = 16
        
        let imageView = UserImageView(height: 36)
        imageView.setUserImage(userForDetails)
        let nameStack = UIStackView([nameLabel, verifiedView, followersLabel])
        nameStack.alignment = .center
        nameStack.spacing = 4
        nameLabel.setContentHuggingPriority(.required, for: .horizontal)
        followersLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        let subnameStack = UIStackView([nipLabel, followersInfoLabel])
        subnameStack.alignment = .center
        subnameStack.spacing = 4
        followersInfoLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        followersInfoLabel.textAlignment = .right
        followersLabel.textAlignment = .right
        
        let infoStack = UIStackView([imageView, UIStackView(axis: .vertical, [nameStack, subnameStack])])
        let actionStack = UIStackView([muteButton, UIView(), qrButton, zapButton, messageButton, followButton, unfollowButton])
        
        let topStack = UIStackView(axis: .vertical, [pullbar, infoStack, actionStack])
        
        infoBackground.addSubview(topStack)
        topStack.pinToSuperview(edges: .horizontal, padding: 24).pinToSuperview(edges: .vertical, padding: 16)
        
        let isFollowing = FollowManager.instance.isFollowing(userForDetails.data.pubkey)
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
        
        zapPreviewBackground.layer.cornerRadius = 8
        zapPreviewBackground.addSubview(zapPreview)
        zapPreview.pinToSuperview()
        
        let reportStack = UIStackView(axis: .vertical, [messagePreview, zapPreviewBackground, reportButton])
        reportStack.alignment = .leading
        reportStack.spacing = 16
        
        let descStack = UIStackView(axis: .vertical, [chatMessageLabel, SpacerView(height: 18), reportStack])
        zapPreviewBackground.pin(to: descStack, edges: .horizontal)
        
        descBackground.addSubview(descStack)
        descStack.pinToSuperview(padding: 24).pin(to: view, edges: .horizontal, padding: 24)
        
        zapPreviewBackground.isHidden = message.zapAmount < 1
        messagePreview.isHidden = message.zapAmount > 0
        
        zapPreview.commentLabel.delegate = self
        messagePreview.commentLabel.delegate = self
        
        updateTheme()
        
        view.addGestureRecognizer(LivePopupDismissGesture(vc: self))
        followButton.addAction(.init(handler: { [weak self] _ in self?.followTapped() }), for: .touchUpInside)
        unfollowButton.addAction(.init(handler: { [weak self] _ in self?.unfollowTapped() }), for: .touchUpInside)
        qrButton.addAction(.init(handler: { [weak self] _ in self?.qrTapped() }), for: .touchUpInside)
        zapButton.addAction(.init(handler: { [weak self] _ in self?.zapTapped() }), for: .touchUpInside)
        messageButton.addAction(.init(handler: { [weak self] _ in self?.messageTapped() }), for: .touchUpInside)
        imageView.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in self?.openUserProfile() }))
        
        muteButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            
            if !MuteManager.instance.isMutedUser(userForDetails.data.pubkey) {
                MuteManager.instance.toggleMuteUser(userForDetails.data.pubkey)
            }
            dismissAsLivePopup()
        }), for: .touchUpInside)
        
        reportButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            
            present(PopupReportContentController(message), animated: true)
        }), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateFollowButtons()
    }
    
    func updateTheme() {
        zapPreviewBackground.backgroundColor = .background
        infoBackground.backgroundColor = .background4
        descBackground.backgroundColor = .background3
        backgroundExtender.backgroundColor = .background3
        
        pullbar.pullBar.backgroundColor = .foreground5.withAlphaComponent(0.8)
        
        muteButton.configuration = .liveMuteButton()
        reportButton.configuration = .reportLiveMessageButton()
        
        zapPreview.updateForComment(message)
        messagePreview.updateForComment(message)
    }
}

extension LiveVideoMessageDetailsController: NantesLabelDelegate {
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

extension ParsedLiveComment: PostingReferenceObject {
    var reference: (tagLetter: String, universalID: String)? {
        ("e", event["id"]?.stringValue ?? "")
    }
    
    var referencePubkey: String {
        user.data.pubkey
    }
}
