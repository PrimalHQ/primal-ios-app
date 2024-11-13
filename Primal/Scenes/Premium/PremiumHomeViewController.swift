//
//  PremiumHomeViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 8.11.24..
//

import Combine
import UIKit
import FLAnimatedImage
import StoreKit

extension PremiumState {
    var isExpired: Bool {
        guard let expires_on else { return false }
        return Date(timeIntervalSince1970: expires_on).timeIntervalSinceNow < 0
    }
    
    var isLegend: Bool { class_id == "legend" }
}

class PremiumHomeViewController: UIViewController {
    
    var cancellables: Set<AnyCancellable> = []

    let state: PremiumState
    
    init(state: PremiumState) {
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
}

private extension PremiumHomeViewController {
    func setup() {
        view.backgroundColor = .background
        
        let table = PremiumHomeTableView(state: state)
        
        let renewLabel = UILabel()
        renewLabel.numberOfLines = 0
        renewLabel.attributedText = actionLabelString()
        renewLabel.isUserInteractionEnabled = true
        renewLabel.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            guard let self else { return }
            switch extraLabelAction {
            case .cancel:
                if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            case .support:
                show(PremiumSupportPrimalController(state: state), sender: nil)
            case .nothing:
                return
            }
        }))
        
        renewLabel.isHidden = !(AppDelegate.contentSettings?.show_primal_support ?? true)
        
        let action = LargeRoundedButton(title: state.isExpired ? "Renew Subscription" : "Manage Premium")
        action.addAction(.init(handler: { [unowned self] _ in
            if state.isExpired == true {
                show(PremiumBuySubscriptionController(pickedName: state.name, state: .buySubscription), sender: nil)
                return
            }
            show(PremiumManageController(state: state), sender: nil)
        }), for: .touchUpInside)
        
        let mainStack = UIStackView(axis: .vertical, [
            UIView(),
            table, SpacerView(height: 20),
            renewLabel
        ])
        
        if let userStack = userStackView() {
            mainStack.insertArrangedSubview(userStack, at: 1)
            mainStack.setCustomSpacing(22, after: userStack)
        }
        
        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .horizontal, padding: 24)
            .centerToSuperview(axis: .vertical)
        
        view.addSubview(action)
        action.pinToSuperview(edges: .horizontal, padding: 24).pinToSuperview(edges: .bottom, padding: 20, safeArea: true)
    }
    
    func userStackView() -> UIView? {
        guard let user = IdentityManager.instance.parsedUser else { return nil }
        let image = FLAnimatedImageView().constrainToSize(80)
        image.layer.cornerRadius = 40
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.setUserImage(user, size: .init(width: 80, height: 80))
        
        let checkbox = VerifiedView().constrainToSize(24)
        checkbox.isExtraVerified = true
        
        let nameLabel = UILabel(user.data.firstIdentifier, color: .foreground, font: .appFont(withSize: 22, weight: .bold))
        let nameStack = UIStackView([nameLabel, checkbox])
        nameStack.alignment = .center
        nameStack.spacing = 6
        
        let titleView = PremiumUserTitleView(title: state.cohort_1, subtitle: state.cohort_2)
        let userStack = UIStackView(axis: .vertical, [
            image, SpacerView(height: 16),
            nameStack, SpacerView(height: 20),
            titleView
        ])
        
        if state.isExpired {
            titleView.alpha = 0.4
        } else if state.cohort_2.lowercased() == "free" {
            let label = UILabel("Hey there! You are an early Primal user who interacted with our team, so we gave you 6 months of Primal Premium for free. ♥️🫂", color: .foreground3, font: .appFont(withSize: 14, weight: .regular))
            label.textAlignment = .center
            label.numberOfLines = 0
            let labelParent = UIView()
            labelParent.addSubview(label)
            label.pinToSuperview(edges: .vertical).pinToSuperview(edges: .horizontal, padding: 15)
            userStack.addArrangedSubview(SpacerView(height: 12))
            userStack.addArrangedSubview(labelParent)
        }
        
        userStack.alignment = .center
        
        return userStack
    }
    
    enum ExtraLabelAction { case cancel, nothing, support }
    var extraLabelAction: ExtraLabelAction {
        if state.isExpired {
            return .nothing
        }
        return .support
    }
    
    func actionLabelString() -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 6
        paragraph.alignment = .center
        
        let strings: (String, String?) = {
            if state.isExpired {
                return ("Your Primal Premium subscription has expired.\nYou can renew it below:", nil)
            }
            return ("Are you enjoying Primal?\nIf so, see how you can ", "support us.")
        }()
        
        let mutable = NSMutableAttributedString(string: strings.0, attributes: [
            .font: UIFont.appFont(withSize: 14, weight: .regular),
            .foregroundColor: UIColor.foreground3,
            .paragraphStyle: paragraph
        ])
        if let accent = strings.1 {
            mutable.append(.init(string: accent, attributes: [
                .font: UIFont.appFont(withSize: 14, weight: .regular),
                .foregroundColor: UIColor.accent,
                .paragraphStyle: paragraph
            ]))
        }
        return mutable
    }
}

class PremiumUserTitleView: UIView, Themeable {
    let titleLabel = UILabel("Primal OG", color: .white, font: .appFont(withSize: 14, weight: .bold))
    let subtitleLabel = UILabel("Class of 2024", color: .white, font: .appFont(withSize: 14, weight: .regular))
    
    init(title: String = "Primal OG", subtitle: String = "Class of 2024") {
        super.init(frame: .zero)
        
        titleLabel.text = title
        subtitleLabel.text = subtitle
        
        let subtitleParent = UIView().constrainToSize(height: 24)
        subtitleParent.layer.cornerRadius = 12
        subtitleParent.backgroundColor = .black.withAlphaComponent(0.4)
        subtitleParent.addSubview(subtitleLabel)
        subtitleLabel.centerToSuperview(axis: .vertical).pinToSuperview(edges: .horizontal, padding: 10)
        
        let stack = UIStackView([titleLabel, subtitleParent])
        stack.alignment = .center
        stack.spacing = 6
        
        addSubview(stack)
        stack.pinToSuperview(edges: [.vertical, .trailing], padding: 2).pinToSuperview(edges: .leading, padding: 10)
        
        layer.cornerRadius = 14
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        backgroundColor = .accent
    }
}

class PremiumHomeTableView: UIView {
    let addressRow = PremiumEditTableRowView(title: "Nostr Address")
    let lightningRow = PremiumEditTableRowView(title: "Lightning Address")
    let profileRow = PremiumInfoTableRowView(title: "VIP profile")
    let endRow: PremiumInfoTableRowView
    
    var updateCancellable: AnyCancellable?
    
    init(state: PremiumState) {
        let tableStack = UIStackView(axis: .vertical, [
            addressRow, SpacerView(height: 1, color: .foreground6),
            lightningRow, SpacerView(height: 1, color: .foreground6),
            profileRow, SpacerView(height: 1, color: .foreground6)
        ])
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .long
        
        if state.recurring, let renews_on = state.renews_on {
            let renewDate = Date(timeIntervalSince1970: renews_on)
            if renewDate.timeIntervalSinceNow < 30 * 24 * 3600 {
                endRow = .init(title: "Renews on")
                endRow.infoLabel.text = dateFormatter.string(from: renewDate)
            } else if let expires_on = state.expires_on {
                let expireDate = Date(timeIntervalSince1970: expires_on)
                endRow = .init(title: "Expires on")
                endRow.infoLabel.text = dateFormatter.string(from: expireDate)
            } else {
                endRow = .init(title: "Expires on")
                endRow.infoLabel.text = "Never"
            }
        } else {
            if let expires_on = state.expires_on {
                let expireDate = Date(timeIntervalSince1970: expires_on)
                endRow = .init(title: expireDate.timeIntervalSinceNow > 0 ? "Expires on" : "Status")
                endRow.infoLabel.text = expireDate.timeIntervalSinceNow > 0 ? dateFormatter.string(from: expireDate) : "EXPIRED"
            } else {
                endRow = .init(title: "Expires on")
                endRow.infoLabel.text = "Never"
            }
            
        }
        tableStack.addArrangedSubview(endRow)
        
        super.init(frame: .zero)
        
        addSubview(tableStack)
        tableStack.pinToSuperview()
        backgroundColor = .background5
        layer.cornerRadius = 16
        
        profileRow.infoLabel.text = state.primal_vip_profile
        lightningRow.target = state.lightning_address
        addressRow.target = state.nostr_address
        
        updateCancellable = IdentityManager.instance.$parsedUser.debounce(for: 2, scheduler: RunLoop.main)
            .prepend(IdentityManager.instance.parsedUser)
            .receive(on: DispatchQueue.main).sink { [unowned self] user in
                guard let user else {
                    lightningRow.current = state.lightning_address
                    addressRow.current = state.nostr_address
                    return
                }
                lightningRow.current = user.data.lud16
                addressRow.current = user.data.nip05
            }
        
        addressRow.applyButton.addAction(.init(handler: { [weak self] _ in
            guard var user = IdentityManager.instance.parsedUser?.data.profileData else { return }
            user.nip05 = state.nostr_address

            IdentityManager.instance.updateProfile(user) { _ in
                IdentityManager.instance.requestUserProfile()
            }
            
            self?.addressRow.current = state.nostr_address
        }), for: .touchUpInside)
        
        lightningRow.applyButton.addAction(.init(handler: { [weak self] _ in
            guard var user = IdentityManager.instance.parsedUser?.data.profileData else { return }
            user.lud16 = state.lightning_address

            IdentityManager.instance.updateProfile(user) { _ in
                IdentityManager.instance.requestUserProfile()
            }
            
            self?.lightningRow.current = state.lightning_address
        }), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIButton.Configuration {
    static func smallApplyButton() -> UIButton.Configuration {
        var config = UIButton.Configuration.accent("apply", font: .appFont(withSize: 14, weight: .regular))
        config.contentInsets = .init(top: 0, leading: 4, bottom: 0, trailing: 0)
        return config
    }
}

class PremiumEditTableRowView: UIStackView {
    let infoLabel = UILabel()
    let targetLabel = UILabel()
    let applyButton = UIButton(configuration: .smallApplyButton())
    
    lazy var applyStack = UIStackView([targetLabel, applyButton])
    
    var target: String = "" { didSet { updateDisplay() } }
    var current: String = "" { didSet { updateDisplay() } }
    
    init(title: String) {
        super.init(frame: .zero)
        let titleLabel = UILabel()
        titleLabel.font = .appFont(withSize: 15, weight: .regular)
        titleLabel.textColor = .foreground3
        titleLabel.text = title
        titleLabel.numberOfLines = 2
//        titleLabel.constrainToSize(width: 70)
        addArrangedSubview(titleLabel)
        
        let rightStack = UIStackView(axis: .vertical, [infoLabel, applyStack])
        rightStack.spacing = 4
        rightStack.alignment = .trailing
        addArrangedSubview(rightStack)
        
        infoLabel.font = .appFont(withSize: 15, weight: .semibold)
        infoLabel.textColor = .foreground
        
        targetLabel.font = .appFont(withSize: 14, weight: .regular)
        targetLabel.textColor = .foreground3
        
        spacing = 8
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        
        infoLabel.setContentHuggingPriority(.required, for: .horizontal)
        infoLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        titleLabel.lineBreakMode = .byTruncatingTail
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateDisplay() {
        if current.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            infoLabel.text = "[not set]"
        } else {
            infoLabel.text = current
        }
        targetLabel.text = target
        applyStack.isHidden = target == current
    }
}
