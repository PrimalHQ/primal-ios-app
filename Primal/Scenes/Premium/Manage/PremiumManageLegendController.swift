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

class PremiumManageLegendController: UIViewController {
    
    var cancellables: Set<AnyCancellable> = []

    let state: PremiumState
    
    let table = LegendThemeSelectionTable()
    
    let titleView = PremiumUserTitleView()
    
    let badgeSwitch = UISwitch(frame: .zero)
    let avatarSwitch = UISwitch(frame: .zero)
    
    let profileImage = UserImageView(height: 80, showLegendGlow: false)
    
    let checkboxImage = UIImageView()
    
    @Published var isBadgeOn = true
    @Published var isAvatarOn = true
    
    init(state: PremiumState) {
        self.state = state
        
        if let custom = PremiumCustomizationManager.instance.getCustomization(pubkey: IdentityManager.instance.userHexPubkey) {
            table.selectTheme(.init(rawValue: custom.style.lowercased()))
            
            avatarSwitch.isOn = custom.avatar_glow
            isAvatarOn = custom.avatar_glow
            
            badgeSwitch.isOn =  custom.custom_badge
            isBadgeOn = custom.custom_badge
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
        
        let badgeStack = UIStackView([UILabel("Custom badge", color: .foreground, font: .appFont(withSize: 16, weight: .regular)), badgeSwitch])
        let avatarStack = UIStackView([UILabel("Avatar ring", color: .foreground, font: .appFont(withSize: 16, weight: .regular)), avatarSwitch])
        [badgeStack, avatarStack].forEach {
            $0.isLayoutMarginsRelativeArrangement = true
            $0.layoutMargins = .init(top: 9, left: 16, bottom: 9, right: 16)
            $0.alignment = .center
        }
        let switchVStack = UIStackView(axis: .vertical, [badgeStack, SpacerView(height: 1, color: .foreground6), avatarStack])
        let switchParentView = SpacerView(color: .background3)
        switchParentView.layer.cornerRadius = 12
        switchParentView.addSubview(switchVStack)
        switchVStack.pinToSuperview()
        
        titleView.titleLabel.text = state.cohort_1
        titleView.subtitleLabel.text = state.cohort_2
        
        let action = LegendaryRoundedButton(title: "Apply")
        
        let mainStack = UIStackView(axis: .vertical, [
            SpacerView(height: 1, color: .background3), SpacerView(height: 16),
            table,
            switchParentView,
            UILabel("Don’t want to stand out?", color: .foreground3, font: .appFont(withSize: 12, weight: .regular), multiline: true),
            UILabel("If you disable the custom badge and avatar ring,", color: .foreground3, font: .appFont(withSize: 12, weight: .regular), multiline: true),
            UILabel("your profile will look like any other profile on  Primal.", color: .foreground3, font: .appFont(withSize: 12, weight: .regular), multiline: true),
        ])
        
        mainStack.setCustomSpacing(22, after: table)
        mainStack.setCustomSpacing(16, after: switchParentView)
        
        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .horizontal, padding: 24)
            .centerToSuperview(axis: .vertical)
        
        if let userStack = userStackView() {
            mainStack.insertArrangedSubview(userStack, at: 0)
            mainStack.setCustomSpacing(32, after: userStack)
        }
        
        view.addSubview(action)
        action.pinToSuperview(edges: .horizontal, padding: 24).pinToSuperview(edges: .bottom, padding: 20, safeArea: true)
        
        badgeSwitch.addAction(.init(handler: { [weak self] _ in
            self?.isBadgeOn = self?.badgeSwitch.isOn ?? false
        }), for: .valueChanged)
        
        avatarSwitch.addAction(.init(handler: { [weak self] _ in
            self?.isAvatarOn = self?.avatarSwitch.isOn ?? false
        }), for: .valueChanged)
        
        action.addAction(.init(handler: { [unowned self] _ in
            let customization = LegendCustomization(
                style: table.selectedTheme?.rawValue.uppercased() ?? "",
                custom_badge: isBadgeOn,
                avatar_glow: isAvatarOn,
                in_leaderboard: true,
                current_shoutout: "Test"
            )
            guard
                let customizationString = customization.encodeToString(),
                let nostrObject = NostrObject.create(content: customizationString, kind: 30078)
            else { return }
            
            PremiumCustomizationManager.instance.addLegendCustomizations([IdentityManager.instance.userHexPubkey: customization])
            ThemingManager.instance.themeDidChange()
            
            SocketRequest(name: "membership_legend_customization", payload: ["event_from_user": nostrObject.toJSON()], connection: .wallet)
                .publisher()
                .sink { res in
                    if let message = res.message {
                        print("ERROR: " + message)
                    }
                }
                .store(in: &cancellables)
            
            navigationController?.popViewController(animated: true)
        }), for: .touchUpInside)
        
        Publishers.CombineLatest3(table.$selectedTheme, $isBadgeOn, $isAvatarOn)
            .sink { [weak self] theme, isBadgeOn, isAvatarOn in
                action.theme = theme
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
