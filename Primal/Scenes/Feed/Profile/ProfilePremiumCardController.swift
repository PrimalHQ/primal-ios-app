//
//  ProfilePremiumCardController.swift
//  Primal
//
//  Created by Pavle Stevanović on 28.1.25..
//

import UIKit

class ProfilePremiumCardController: UIViewController {
    let user: ParsedUser
    
    let cardView = UIView()
    
    let topLeftParent = UIView()
    let topRightParent = UIView()
    let botParent = UIView()
    
    init(user: ParsedUser) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        topRightParent.transform = .init(translationX: 300, y: -300)
        topLeftParent.transform = .init(translationX: -150, y: -150)
        botParent.transform = .init(translationX: -150, y: 150)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.3) {
            self.view.alpha = 1
            self.cardView.transform = .identity
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.topRightParent.transform = .identity
                self.topLeftParent.transform = .identity
                self.botParent.transform = .identity
            }
        }
    }
}

private extension ProfilePremiumCardController {
    func setup() {
        view.backgroundColor = .black.withAlphaComponent(0.4)
        
        view.alpha = 0
        cardView.transform = .init(translationX: 0, y: 500)
        
        view.addSubview(cardView)
        cardView.centerToSuperview().pinToSuperview(edges: .horizontal, padding: 20)
        cardView.backgroundColor = .background3
        cardView.layer.cornerRadius = 12
        cardView.layer.masksToBounds = true
        
        let background = UIView()
        view.insertSubview(background, at: 0)
        background.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            UIView.animate(withDuration: 0.2, animations: {
                self?.view.alpha = 0
            }) { _ in
                self?.dismiss(animated: false)
            }
        }))
        background.pinToSuperview()
        
        let colors = PremiumCustomizationManager.instance.getCustomization(pubkey: user.data.pubkey)?.theme?.simpleColors ?? [UIColor.init(rgb: 0xFFB700), .init(rgb: 0xCB721E)]
        let firstColor = colors.last ?? UIColor.init(rgb: 0xFFB700)
        
        [botParent, topLeftParent, topRightParent].forEach {
            cardView.addSubview($0)
            $0.pinToSuperview()
        }
        
        let botGradient = UIView()
        botGradient.backgroundColor = firstColor.withAlphaComponent(0.25)
        botParent.addSubview(botGradient)
        botGradient
            .constrainToSize(width: 400, height: 200)
            .pinToSuperview(edges: .bottom, padding: -146)
            .pinToSuperview(edges: .leading, padding: -150)
        botGradient.transform = .init(rotationAngle: 11 * .pi / 48)
        
        let topLeftGradient = UIView()
        topLeftGradient.backgroundColor = firstColor.withAlphaComponent(0.25)
        topLeftParent.addSubview(topLeftGradient)
        topLeftGradient
            .constrainToSize(width: 200, height: 400)
            .pinToSuperview(edges: .top, padding: -120)
            .pinToSuperview(edges: .leading, padding: -110)
        topLeftGradient.transform = .init(rotationAngle: 11 * .pi / 48)
        
        let topRightGradient = GradientView(colors: colors)
        topRightParent.addSubview(topRightGradient)
        topRightGradient
            .constrainToSize(width: 640, height: 440)
            .pinToSuperview(edges: .top, padding: -255)
            .pinToSuperview(edges: .trailing, padding: -260)
        topRightGradient.transform = .init(rotationAngle: 11 * .pi / 48)
        
        let userImage = UserImageView(height: 120)
        userImage.setUserImage(user)
        
        let nameLabel = UILabel(user.data.firstIdentifier, color: .foreground, font: .appFont(withSize: 22, weight: .bold))
        let checkbox = VerifiedView()
        checkbox.user = user.data
        let userStack = UIStackView([nameLabel, checkbox])
        userStack.spacing = 6
        userStack.alignment = .center
        
        let premiumBadge = PremiumUserTitleView()
        
        if let custom = PremiumCustomizationManager.instance.getPremiumInfo(pubkey: user.data.pubkey) {
            premiumBadge.titleLabel.text = custom.cohort_1
            premiumBadge.subtitleLabel.text = custom.cohort_2
            
            if custom.tier == "premium-legend" {
                if let custom = PremiumCustomizationManager.instance.getCustomization(pubkey: user.data.pubkey)?.theme {
                    premiumBadge.theme = custom
                    premiumBadge.isHidden = false
                } else {
                    premiumBadge.isHidden = true
                }
            } else if (custom.tier == "premium" && Date(timeIntervalSince1970: custom.expires_on ?? 0).timeIntervalSinceNow > 0) {
                premiumBadge.isHidden = false
                premiumBadge.theme = nil
            }
        } else {
            premiumBadge.isHidden = true
        }
        
        let mainStack = UIStackView(axis: .vertical, [
            userImage, SpacerView(height: 28),
            userStack, SpacerView(height: 6),
            // secondIdentifier
            SpacerView(height: 12),
            premiumBadge, SpacerView(height: 46),
            UILabel("Legend since December 21, 2024", color: .foreground, font: .appFont(withSize: 16, weight: .semibold)), SpacerView(height: 8),
            UILabel(
                "A bitcoin shaman with a rare ability to communicate complex topics clearly to a wide audience. On a mission to onboard millions to Nostr. ",
                color: .foreground,
                font: .appFont(withSize: 15, weight: .regular),
                multiline: true
            ),
            UIButton(configuration: .accent18("See other Legends"))
        ])
        
        if let second = user.data.secondIdentifier {
            mainStack.insertArrangedSubview(UILabel(second, color: .foreground, font: .appFont(withSize: 14, weight: .regular)), at: 4)
        }
        
        mainStack.alignment = .center
        
        cardView.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .top, padding: 85)
            .pinToSuperview(edges: [.bottom, .horizontal], padding: 20)
    }
}
