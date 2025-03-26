//
//  PremiumManageLegendController.swift
//  Primal
//
//  Created by Pavle Stevanović on 18.11.24..
//

import Combine
import UIKit
import FLAnimatedImage
import StoreKit
import GenericJSON

extension UIButton.Configuration {
    static func pill(text: String, foregroundColor: UIColor, backgroundColor: UIColor, font: UIFont) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        
        config.attributedTitle = .init(text, attributes: .init([
            .font: font
        ]))
        config.baseForegroundColor = foregroundColor
        config.baseBackgroundColor = backgroundColor
        return config
    }
    
    static func accentPill(text: String, font: UIFont) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        
        config.attributedTitle = .init(text, attributes: .init([
            .font: font
        ]))
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .accent
        return config
    }
}



class PremiumManageLegendController: UIViewController {
    
    var cancellables: Set<AnyCancellable> = []

    let state: PremiumState
    
    let table = LegendThemeSelectionTable()
    
    let titleView = PremiumUserTitleView()
    
    let badgeSwitch = UISwitch(frame: .zero)
    let avatarSwitch = UISwitch(frame: .zero)
    let leaderboardSwitch = UISwitch(frame: .zero)
    let shoutoutInput = UITextView()
    let shoutoutLabel = UILabel()
    let highlightInputView = UIView()
    
    let editsUnderReviewLabel = UILabel("EDITS UNDER REVIEW", color: .foreground3, font: .appFont(withSize: 12, weight: .bold), multiline: true)
    let infoLabel = UILabel("Legend cards contain a personalized shoutout from\nPrimal to all our legends.", color: .foreground3, font: .appFont(withSize: 12, weight: .regular), multiline: true)
    
    let countLabel = UILabel("", color: .foreground5, font: .appFont(withSize: 12, weight: .regular))
    
    let profileImage = UserImageView(height: 80, showLegendGlow: false)
    
    let checkboxImage = UIImageView()
    
    @Published var isBadgeOn = true
    @Published var isAvatarOn = true
    @Published var isLeaderboardOn = true
    
    var hasShoutoutEdits = false
    
    init(state: PremiumState) {
        self.state = state
        
        if let custom = PremiumCustomizationManager.instance.getCustomization(pubkey: IdentityManager.instance.userHexPubkey) {
            table.selectTheme(.init(rawValue: custom.style?.lowercased() ?? ""))
            
            avatarSwitch.isOn = custom.avatar_glow
            isAvatarOn = custom.avatar_glow
            
            badgeSwitch.isOn =  custom.custom_badge
            isBadgeOn = custom.custom_badge
            
            leaderboardSwitch.isOn = custom.in_leaderboard
            isLeaderboardOn = custom.in_leaderboard
            
            shoutoutLabel.text = custom.edited_shoutout ?? custom.current_shoutout
            shoutoutInput.text = custom.edited_shoutout ?? custom.current_shoutout
            
            countLabel.text = "\(shoutoutInput.text.count)/140"
            
            hasShoutoutEdits = custom.edited_shoutout?.isEmpty == false
        } else {
            avatarSwitch.isOn = true
            badgeSwitch.isOn = true
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        mainTabBarController?.setTabBarHidden(true, animated: animated)
    }
}

private extension PremiumManageLegendController {
    func setup() {
        title = "Legendary Profile"
        navigationItem.leftBarButtonItem = customBackButton
        view.backgroundColor = .background
        
        let badgeStack = UIStackView([UILabel("Legend badge", color: .foreground, font: .appFont(withSize: 16, weight: .regular)), badgeSwitch])
        let avatarStack = UIStackView([UILabel("Legend ring", color: .foreground, font: .appFont(withSize: 16, weight: .regular)), avatarSwitch])
        let leaderBoardStack = UIStackView([UILabel("Appear in leaderboard", color: .foreground, font: .appFont(withSize: 16, weight: .regular)), leaderboardSwitch])
        [badgeStack, avatarStack, leaderBoardStack].forEach {
            $0.isLayoutMarginsRelativeArrangement = true
            $0.layoutMargins = .init(top: 9, left: 16, bottom: 9, right: 16)
            $0.alignment = .center
        }
        let switchVStack = UIStackView(axis: .vertical, [
            badgeStack, SpacerView(height: 1, color: .foreground6), avatarStack, SpacerView(height: 1, color: .foreground6), leaderBoardStack
        ])
        let switchParentView = SpacerView(color: .background3)
        switchParentView.layer.cornerRadius = 12
        switchParentView.addSubview(switchVStack)
        switchVStack.pinToSuperview()
        
        titleView.titleLabel.text = state.cohort_1
        titleView.subtitleLabel.text = state.cohort_2
        
        let shoutoutParent = UIView().constrainToSize(height: 150)
        let shoutoutButton = UIButton(configuration: .accent("suggest edits", font: .appFont(withSize: 12, weight: .regular)))
        let shoutoutStack = UIStackView(axis: .vertical, [shoutoutLabel, shoutoutButton])
        shoutoutParent.addSubview(shoutoutStack)
        shoutoutStack.pinToSuperview(edges: .horizontal, padding: 15).pinToSuperview(edges: .top, padding: 5).pinToSuperview(edges: .bottom, padding: 16)
        shoutoutParent.layer.cornerRadius = 12
        shoutoutParent.backgroundColor = .background3
        shoutoutLabel.textColor = .foreground2
        shoutoutLabel.font = .appFont(withSize: 15, weight: .regular)
        shoutoutLabel.numberOfLines = 0
        shoutoutLabel.textAlignment = .center
        
        let mainStack = UIStackView(axis: .vertical, [
            SpacerView(height: 1, color: .background3), SpacerView(height: 16),
            table,
            switchParentView,
            UILabel("LEGEND CARD SHOUTOUT", color: .foreground, font: .appFont(withSize: 14, weight: .medium), multiline: true), SpacerView(height: 16),
            shoutoutParent, SpacerView(height: 8),
            editsUnderReviewLabel, SpacerView(height: 8),
            infoLabel
        ])
        
        if hasShoutoutEdits {
            editsUnderReviewLabel.isHidden = false
            infoLabel.text = "Your edits have been sent to primal for review. The updated content should be live soon."
        } else {
            editsUnderReviewLabel.isHidden = true
        }
        
        if let userStack = userStackView() {
            mainStack.insertArrangedSubview(userStack, at: 0)
            mainStack.setCustomSpacing(32, after: userStack)
        }
        
        mainStack.setCustomSpacing(22, after: table)
        mainStack.setCustomSpacing(36, after: switchParentView)
        mainStack.setCustomSpacing(8, after: editsUnderReviewLabel)
        
        let scroll = UIScrollView()
        scroll.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: [.horizontal, .bottom], padding: 24)
            .pinToSuperview(edges: .top, padding: 50)
        
        view.addSubview(scroll)
        scroll.pinToSuperview(edges: [.horizontal, .bottom]).pinToSuperview(edges: .top, safeArea: true)
        
        view.addSubview(highlightInputView)
        highlightInputView.pinToSuperview()
        highlightInputView.isHidden = true
        
        mainStack.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -48).isActive = true
        
        badgeSwitch.addAction(.init(handler: { [weak self] _ in
            self?.isBadgeOn = self?.badgeSwitch.isOn ?? false
        }), for: .valueChanged)
        
        avatarSwitch.addAction(.init(handler: { [weak self] _ in
            self?.isAvatarOn = self?.avatarSwitch.isOn ?? false
        }), for: .valueChanged)
        
        leaderboardSwitch.addAction(.init(handler: { [weak self] _ in
            self?.isLeaderboardOn = self?.leaderboardSwitch.isOn ?? false
        }), for: .valueChanged)
        
        shoutoutButton.addAction(.init(handler: { [weak self] _ in
            self?.openInputView()
        }), for: .touchUpInside)
        
        Publishers.CombineLatest3(table.$selectedTheme, $isBadgeOn, $isAvatarOn)
            .sink { [weak self] theme, isBadgeOn, isAvatarOn in
                self?.titleView.theme = theme
                if let theme, isAvatarOn {
                    self?.profileImage.legendaryGradient.setLegendGradient(theme)
                    self?.profileImage.legendaryGradient.isHidden = false
                    self?.profileImage.legendaryBackgroundCircleView.isHidden = false
                } else {
                    self?.profileImage.legendaryGradient.isHidden = true
                    self?.profileImage.legendaryBackgroundCircleView.isHidden = true
                }
                
                if let theme, isBadgeOn {
                    self?.checkboxImage.image = theme.checkmarkBackgroundImage ?? UIImage(named: "verifiedBackground")
                } else {
                    self?.checkboxImage.image = UIImage(named: "verifiedBackground")
                }
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest4(table.$selectedTheme, $isBadgeOn, $isAvatarOn, $isLeaderboardOn)
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.sendUpdate()
            }
            .store(in: &cancellables)
        
        setupInputView()
    }
    
    func sendUpdate(shoutoutEdit: String? = nil) {
        var customization: [String: JSON] = [
            "style": .string(table.selectedTheme?.rawValue.uppercased() ?? ""),
            "custom_badge": .bool(isBadgeOn),
            "avatar_glow": .bool(isAvatarOn),
            "in_leaderboard": .bool(isLeaderboardOn)
        ]
        
        if let shoutoutEdit {
            customization["edited_shoutout"] = .string(shoutoutEdit)
        }
        
        guard
            let customizationString = customization.encodeToString(),
            let nostrObject = NostrObject.create(content: customizationString, kind: 30078)
        else { return }
        
        PremiumCustomizationManager.instance.addLegendCustomizations([IdentityManager.instance.userHexPubkey: .init(
            style: table.selectedTheme?.rawValue.uppercased() ?? "",
            custom_badge: isBadgeOn,
            avatar_glow: isAvatarOn,
            in_leaderboard: isLeaderboardOn,
            current_shoutout: shoutoutLabel.text ?? "",
            edited_shoutout: shoutoutEdit
        )])
        
        ThemingManager.instance.themeDidChange()
        
        SocketRequest(name: "membership_legend_customization", payload: ["event_from_user": nostrObject.toJSON()], connection: .wallet)
            .publisher()
            .sink { res in
                if let message = res.message {
                    print("ERROR: " + message)
                }
            }
            .store(in: &cancellables)
    }
    
    func openInputView() {
        highlightInputView.alpha = 0
        highlightInputView.isHidden = false
        UIView.animate(withDuration: 0.2) {
            self.highlightInputView.alpha = 1
        }
        
        shoutoutInput.becomeFirstResponder()
    }
    
    func closeInputView() {
        shoutoutInput.resignFirstResponder()
        
        UIView.animate(withDuration: 0.2) {
            self.highlightInputView.alpha = 0
        } completion: { _ in
            self.highlightInputView.isHidden = true
        }
    }
    
    func setupInputView() {
        let shoutoutParent = UIView().constrainToSize(height: 150)
        shoutoutParent.addSubview(shoutoutInput)
        shoutoutInput.pinToSuperview(edges: .horizontal, padding: 15).pinToSuperview(edges: .top, padding: 5).pinToSuperview(edges: .bottom, padding: 16)
        shoutoutParent.layer.cornerRadius = 12
        shoutoutParent.backgroundColor = .background3
        
        shoutoutInput.backgroundColor = .clear
        shoutoutInput.textColor = .foreground2
        shoutoutInput.font = .appFont(withSize: 15, weight: .regular)
        shoutoutInput.textAlignment = .center
        
        let cancelButton = UIButton(configuration: .pill(text: "Cancel", foregroundColor: .foreground, backgroundColor: .background3, font: .appFont(withSize: 14, weight: .regular)))
        let sendButton = UIButton(configuration: .accentPill(text: "Send", font: .appFont(withSize: 14, weight: .regular)))
        let actionStack = UIStackView([countLabel, UIView(), cancelButton, SpacerView(width: 8), sendButton])
        
        let mainView = UIView()
        let contentStack = UIStackView(axis: .vertical, [
            UILabel("LEGEND CARD SHOUTOUT", color: .foreground, font: .appFont(withSize: 14, weight: .medium), multiline: true), SpacerView(height: 16),
            shoutoutParent, SpacerView(height: 16),
            actionStack
        ])
        mainView.addSubview(contentStack)
        contentStack.pinToSuperview(edges: .horizontal, padding: 35).pinToSuperview(edges: .vertical, padding: 14)
        mainView.backgroundColor = .background
        
        shoutoutInput.delegate = self
        
        let keyboardView = KeyboardSizingView()
        keyboardView.updateHeightCancellable().store(in: &cancellables)
        
        let screenStack = UIStackView(axis: .vertical, [
            SpacerView(color: UIColor.background.withAlphaComponent(0.7)), mainView, keyboardView
        ])
        
        highlightInputView.addSubview(screenStack)
        screenStack.pinToSuperview()
        
        cancelButton.addAction(.init(handler: { [weak self] _ in
            self?.closeInputView()
        }), for: .touchUpInside)
        
        sendButton.addAction(.init(handler: { [weak self] _ in
            if self?.shoutoutInput.text.count ?? 0 > 140 {
                self?.countLabel.shake()
                return
            }
            
            self?.sendUpdate(shoutoutEdit: self?.shoutoutInput.text ?? "")
            self?.editsUnderReviewLabel.isHidden = false
            self?.infoLabel.text = "Your edits have been sent to primal for review. The updated content should be live soon."
            self?.closeInputView()
        }), for: .touchUpInside)
    }
    
    func userStackView() -> UIView? {
        guard let user = IdentityManager.instance.parsedUser else { return nil }
        profileImage.setUserImage(user)
        
        let checkbox = UIView().constrainToSize(24)
        checkbox.addSubview(checkboxImage)
        checkboxImage.pinToSuperview()
        let checkImage = UIImageView(image: UIImage(named: "verifiedCheck"))
        checkbox.addSubview(checkImage)
        checkImage.pinToSuperview()
        checkboxImage.tintColor = .accent
        checkImage.tintColor = .white
        
        let nameLabel = UILabel(user.data.firstIdentifier, color: .foreground, font: .appFont(withSize: 22, weight: .bold))
        let nameStack = UIStackView([nameLabel, checkbox])
        nameStack.alignment = .center
        nameStack.spacing = 6
        
        let userStack = UIStackView(axis: .vertical, [
            profileImage, SpacerView(height: 16),
            nameStack, SpacerView(height: 20),
            titleView
        ])
        
        userStack.alignment = .center
        
        return userStack
    }
}

extension PremiumManageLegendController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        countLabel.text = "\(textView.text.count)/140"
        countLabel.textColor = textView.text.count <= 140 ? .foreground5 : .red
    }
}

class LegendaryRoundedButton: LargeRoundedButton {
    let gradient = GradientView(colors: [])
    
    var theme: LegendTheme? {
        didSet {
            guard let theme else {
                gradient.isHidden = true
                return
            }
            gradient.isHidden = false
            gradient.setLegendGradient(theme)
        }
    }
    
    override init(title: String) {
        super.init(title: title)
        
        insertSubview(gradient, at: 0)
        gradient.pinToSuperview()
        gradient.isHidden = true
        
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
