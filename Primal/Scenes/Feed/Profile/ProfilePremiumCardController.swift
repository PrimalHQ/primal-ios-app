//
//  ProfilePremiumCardController.swift
//  Primal
//
//  Created by Pavle Stevanović on 28.1.25..
//

import UIKit

extension LegendTheme {
    var simpleColors: [UIColor] {
        switch self {
        case .gold:
            return [.init(rgb: 0xFFB700), .init(rgb: 0xCB721E)]
        case .aqua:
            return [.init(rgb: 0x6BCCFF), .init(rgb: 0x247FFF)]
        case .silver:
            return [.init(rgb: 0xCCCCCC), .init(rgb: 0x777777)]
        case .purple:
            return [.init(rgb: 0xC803EC), .init(rgb: 0x5613FF)]
        case .purplehaze:
            return [.init(rgb: 0xFB00C4), .init(rgb: 0x04F7FC)]
        case .teal:
            return [.init(rgb: 0x40FCFF), .init(rgb: 0x007D9F)]
        case .brown:
            return [.init(rgb: 0xBB9971), .init(rgb: 0x5C3B22)]
        case .blue:
            return [.init(rgb: 0x01E0FF), .init(rgb: 0x0190F8)]
        case .sunfire:
            return [.init(rgb: 0xFFA722), .init(rgb: 0xFA3C3C), .init(rgb: 0xF00492)]
        }
    }
    
    var singleColor: UIColor {
        switch self {
        case .gold:
            return .init(rgb: 0xFFB701)
        case .aqua:
            return .init(rgb: 0x6BCCFF)
        case .silver:
            return .init(rgb: 0xCCCCCC)
        case .purple:
            return .init(rgb: 0xC803EC)
        case .purplehaze:
            return .init(rgb: 0xE812C8)
        case .teal:
            return .init(rgb: 0x40FCFF)
        case .brown:
            return .init(rgb: 0xBB9971)
        case .blue:
            return .init(rgb: 0x2394EF)
        case .sunfire:
            return .init(rgb: 0xCA077C)
        }
    }
}

extension UIButton.Configuration {
    static func coloredButton(_ title: String, color: UIColor) -> UIButton.Configuration {
        var config = UIButton.Configuration.plain()
        config.attributedTitle = .init(title, attributes: .init([
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .foregroundColor: color
        ]))
        return config
    }
    
    static func coloredFilledButton(_ title: String, color: UIColor, textColor: UIColor) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.attributedTitle = .init(title, attributes: .init([
            .font: UIFont.appFont(withSize: 16, weight: .semibold),
            .foregroundColor: textColor
        ]))
        config.baseBackgroundColor = color
        return config
    }
}

class ProfilePremiumCardController: UIViewController {
    let user: ParsedUser
    
    let cardView = UIView()
    
    let userImage = UserImageView(height: 120)
    
    let topLeftParent = UIView()
    let topRightParent = UIView()
    let botParent = UIView()
    let highlightParent = UIView()

    let checkbox = VerifiedView().constrainToSize(width: 24, height: 22)
    lazy var nameLabel = UILabel(user.data.firstIdentifier, color: .white, font: .appFont(withSize: 22, weight: .bold))
    lazy var userStack = UIStackView([nameLabel, checkbox])
    lazy var secondLabel = UILabel(user.data.secondIdentifier ?? "", color: .white, font: .appFont(withSize: 14, weight: .regular))
    let premiumBadge = PremiumUserTitleView()
    let userCopyStack = UIStackView(axis: .vertical, [])
    let becomeLegendButton = UIButton()
    
    var isLegend = false
    
    init(user: ParsedUser) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        overrideUserInterfaceStyle = .dark
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateAppear()
    }
}

private extension ProfilePremiumCardController {
    func setup() {
        view.backgroundColor = .black.withAlphaComponent(0.4)
        
        view.addSubview(cardView)
        cardView.centerToSuperview().pinToSuperview(edges: .horizontal, padding: 20)
        cardView.backgroundColor = .init(rgb: 0x222222)
        cardView.layer.cornerRadius = 12
        cardView.layer.masksToBounds = true
        
        let background = UIView()
        view.insertSubview(background, at: 0)
        background.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.animateClose()
        }))
        background.pinToSuperview()
        
        let colors = PremiumCustomizationManager.instance.getCustomization(pubkey: user.data.pubkey)?.theme?.simpleColors ?? [UIColor.init(rgb: 0x444444), .init(rgb: 0x444444)]
        let firstColor = PremiumCustomizationManager.instance.getCustomization(pubkey: user.data.pubkey)?.theme?.singleColor ?? .init(rgb: 0x444444)
        
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
        topRightGradient.gradientLayer.startPoint = .init(x: 0, y: 0.5)
        topRightGradient.gradientLayer.endPoint = .init(x: 1, y: 0.5)
        topRightParent.addSubview(topRightGradient)
        topRightGradient
            .constrainToSize(width: 500, height: 440)
            .pinToSuperview(edges: .top, padding: -230)
            .pinToSuperview(edges: .trailing, padding: -220)
        topRightGradient.transform = .init(rotationAngle: 11 * .pi / 48)
        
        userImage.noBackgroundCircle = true
        userImage.setUserImage(user)
        
        checkbox.user = user.data
        userStack.spacing = 6
        userStack.alignment = .center
        
        let sinceLabel = UILabel("", color: .white, font: .appFont(withSize: 16, weight: .semibold))
        let aboutLabel =  UILabel()
        aboutLabel.isHidden = true
        aboutLabel.numberOfLines = 0
        
        let otherLegendsButton = UIButton(configuration: .coloredButton("See other Legends", color: firstColor))
        let becomeLegendParent = UIView()
        becomeLegendParent.addSubview(becomeLegendButton)
        becomeLegendButton.pinToSuperview()
        
        var isButtonTextBlack = true
        if let custom = PremiumCustomizationManager.instance.getPremiumInfo(pubkey: user.data.pubkey) {
            premiumBadge.titleLabel.text = custom.cohort_1
            premiumBadge.subtitleLabel.text = custom.cohort_2
            
            if custom.tier == "premium-legend" {
                isLegend = true
                
                if let data = PremiumCustomizationManager.instance.getCustomization(pubkey: user.data.pubkey), let customLegend = data.theme {
                    
                    if let since = custom.legend_since {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "MMMM d, yyyy"
                        sinceLabel.text = "Legend since \(formatter.string(from: Date(timeIntervalSince1970: since)))"
                        
                    } else {
                        sinceLabel.text = "Legend since \(custom.cohort_2)"
                    }
                    
                    let paragraph = NSMutableParagraphStyle()
                    paragraph.alignment = .center
                    paragraph.lineSpacing = 7
                    aboutLabel.attributedText = .init(string: data.current_shoutout, attributes: [
                        .paragraphStyle: paragraph,
                        .foregroundColor: UIColor(rgb: 0xAAAAAA),
                        .font: UIFont.appFont(withSize: 15, weight: .regular)
                    ])
                    aboutLabel.isHidden = false
                    
                    premiumBadge.theme = customLegend
                    premiumBadge.isHidden = false
                    
                    isButtonTextBlack = customLegend.blackButtonText
                } else {
                    premiumBadge.isHidden = true
                }
                
                if WalletManager.instance.hasLegend {
                    becomeLegendParent.alpha = 0.001
                    becomeLegendParent.isUserInteractionEnabled = false
                }
                
            } else {
                sinceLabel.font = .appFont(withSize: 16, weight: .regular)
                
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM d, yyyy"
                sinceLabel.text = "\(custom.cohort_1) since \(formatter.string(from: Date(timeIntervalSince1970: custom.premium_since)))"
                 
                otherLegendsButton.configuration = .coloredButton("See other Primal OGs", color: .accent)
                becomeLegendParent.alpha = 0.001
                becomeLegendParent.isUserInteractionEnabled = false
            }
        }
        
        becomeLegendButton.addAction(.init(handler: { [weak self] _ in
            guard let nav: UINavigationController = self?.presentingViewController?.findInChildren() else { return }
            
            nav.pushViewController(PremiumBecomeLegendController(), animated: true)
            self?.animateClose()
        }), for: .touchUpInside)
        
        otherLegendsButton.addAction(.init(handler: { [weak self] _ in
            guard let nav: UINavigationController = self?.presentingViewController?.findInChildren() else { return }
            
            if self?.isLegend == true {
                nav.pushViewController(LegendListController(), animated: true)
            } else {
                nav.pushViewController(PremiumListController(), animated: true)
            }
            self?.animateClose()
        }), for: .touchUpInside)
        
        if PremiumCustomizationManager.instance.getCustomization(pubkey: user.data.pubkey) != nil, user.data.pubkey == IdentityManager.instance.userHexPubkey {
            let threeDotsButton = UIButton(configuration: .simpleImage("threeDots"))
            threeDotsButton.tintColor = .init(rgb: 0x1E1E1E)
            threeDotsButton.showsMenuAsPrimaryAction = true
            threeDotsButton.menu = .init(children: [
                UIAction(title: "Close", image: UIImage(named: "close")?.withRenderingMode(.alwaysTemplate), handler: { [weak self] _ in
                    self?.animateClose()
                }),
                UIAction(title: "Legend settings", image: UIImage(named: "menuSidebarSettings"), handler: { [weak self] _ in
                    guard let nav: UINavigationController = self?.presentingViewController?.findInChildren(), let state = WalletManager.instance.premiumState else { return }
                    
                    self?.animateClose()
                    nav.pushViewController(PremiumManageLegendController(state: state), animated: true)
                })
            ])
            
            cardView.addSubview(threeDotsButton)
            threeDotsButton.pinToSuperview(edges: [.trailing, .top], padding: 8)
        } else {
            let closeButton = UIButton(configuration: .simpleImage(UIImage(named: "close")?.withRenderingMode(.alwaysTemplate)), primaryAction: .init(handler: { [weak self] _ in
                self?.animateClose()
            }))
            closeButton.tintColor = .init(rgb: 0x1E1E1E)
            cardView.addSubview(closeButton)
            closeButton.pinToSuperview(edges: [.trailing, .top], padding: 8)
        }
        
        becomeLegendButton.configuration = .coloredFilledButton("Become a Legend", color: firstColor, textColor: isButtonTextBlack ? .black : .white)
                
        let premiumUserExtraSpace = SpacerView(height: 50)
        [sinceLabel, aboutLabel, premiumUserExtraSpace, otherLegendsButton].forEach { userCopyStack.addArrangedSubview($0) }
        userCopyStack.alignment = .center
        userCopyStack.setCustomSpacing(8, after: sinceLabel)
        userCopyStack.setCustomSpacing(34, after: aboutLabel)
        
        aboutLabel.pinToSuperview(edges: .horizontal, padding: 20)
        
        let mainStack = UIStackView(axis: .vertical, [
            userImage, SpacerView(height: 28),
            userStack, SpacerView(height: 6),
            secondLabel, SpacerView(height: 12),
            premiumBadge, SpacerView(height: 46),
            userCopyStack,
            becomeLegendParent.constrainToSize(height: 44)
        ])
        
        becomeLegendParent.pinToSuperview(edges: .horizontal)
        userCopyStack.pinToSuperview(edges: .horizontal)
        
        cardView.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .top, padding: 85)
            .pinToSuperview(edges: [.horizontal, .bottom], padding: 20)
        mainStack.alignment = .center
        mainStack.setCustomSpacing(16, after: userCopyStack)
        
        let highlight = UIView()
        highlight.backgroundColor = .white.withAlphaComponent(0.3)
        highlight.transform = .init(rotationAngle: 11 * .pi / 48)
        highlight.constrainToSize(width: 700, height: 100)
        cardView.addSubview(highlightParent)
        highlightParent.pinToSuperview(edges: [.top, .leading]).constrainToSize(0)
        highlightParent.addSubview(highlight)
        highlight.centerToView(cardView)
        
        view.alpha = 0.01
        cardView.transform = .init(translationX: 0, y: 500)
        
        cardView.addGestureRecognizer(BindablePanGestureRecognizer(action: { [unowned self] sender in
            let trans = sender.translation(in: view)
            
            switch sender.state {
            case .began:
//                view.backgroundColor = .clear
                fallthrough
            case .changed:
                let rotationProgress = (trans.x / 400).clamp(-1, 1)
                let rotation = (.pi * 0.2) * rotationProgress
                
                cardView.transform = CGAffineTransform(translationX: trans.x, y: trans.y).rotated(by: rotation)
                
                let totalTrans = sqrt(trans.x * trans.x + trans.y * trans.y)
                let progress = (totalTrans / 500).clamp(0, 1)
                background.alpha = 1 - progress
            case .ended, .cancelled:
                let velocity = sender.velocity(in: view)
                let extendedTrans = CGPoint(x: trans.x + velocity.x / 20, y: trans.y + velocity.y / 20)
                            
                let totalTrans = sqrt(extendedTrans.x * extendedTrans.x + extendedTrans.y * extendedTrans.y)
                if totalTrans > 200 {
                    UIView.animate(withDuration: 0.4) { [self] in
                        cardView.transform = cardView.transform.translatedBy(x: velocity.x / 5, y: velocity.y / 5)
                        view.alpha = 0
                    } completion: { _ in
                        self.dismiss(animated: false)
                    }
                } else {
                    UIView.animate(withDuration: 0.3) {
                        self.cardView.transform = .identity
                        self.view.alpha = 1
                    }
                }
            default:
                break
            }
        }))
        
        if isLegend {
            // If legend
            userImage.transform = .init(rotationAngle: .pi / -4).scaledBy(x: 0.05, y: 0.05)
            userImage.alpha = 0.01
            
            [userStack, secondLabel, premiumBadge, userCopyStack, becomeLegendButton].forEach {
                $0.alpha = 0.01
                $0.transform = .init(translationX: 0, y: 40)
            }
            
            premiumUserExtraSpace.isHidden = true
            
            topRightParent.transform = .init(translationX: 350, y: 0)
            topLeftParent.transform = .init(translationX: -200, y: 0)
            botParent.transform = .init(translationX: -200, y: 0)
            highlightParent.transform = .init(translationX: -300, y: 300)
        } else {
            highlightParent.removeFromSuperview()
        }
    }
    
    func animateClose() {
        UIView.animate(withDuration: 0.2, animations: {
            self.view.alpha = 0
        }) { _ in
            self.dismiss(animated: false)
        }
    }
    
    func animateAppear() {
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(.easeInOutQuart)

        UIView.animate(withDuration: 24 / 60, delay: 0) {
            self.view.alpha = 1
            self.cardView.transform = .identity
        }
        
        UIView.animate(withDuration: 43 / 60, delay: 12 / 60) {
            self.topRightParent.transform = .identity
            self.topLeftParent.transform = .identity
            self.botParent.transform = .identity
        }
        
        [userImage, userStack, secondLabel, premiumBadge, userCopyStack, becomeLegendButton].enumerated().forEach { index, view in
            UIView.animate(withDuration: 30 / 60, delay: TimeInterval(20 + (index * 2)) / 60, animations: {
//                view.transform = .identity
                view.alpha = 1
            })
        }
        
        CATransaction.commit()
        
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut))
        
        UIView.animate(withDuration: 35 / 60, delay: 45 / 60) {
            self.highlightParent.transform = .init(translationX: 300, y: -300)
        }
        
        CATransaction.commit()
            
//        CATransaction.begin()
//        CATransaction.setAnimationTimingFunction(.signinEaseOut)
//        
        [userImage, userStack, secondLabel, premiumBadge, userCopyStack, becomeLegendButton].enumerated().forEach { index, view in
            UIView.animate(withDuration: 30 / 60, delay: TimeInterval(20 + (index * 2)) / 60, animations: {
                view.transform = .identity
//                view.alpha = 1
            })
        }
//        CATransaction.commit()
        
    }
}
