//
//  SettingsZapsViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 10.7.23..
//

import Combine
import UIKit

class SettingsZapsViewController: UIViewController, Themeable {
    
    var defaultZapSettings: PrimalZapDefaultSettings?
    var zapOptions: [PrimalZapListSettings] = []
    
    let defaultZapInfo = ZapInfoView()
    
    let zapOptionsStack = UIStackView(axis: .vertical, [])
    
    var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        updateTheme()
    }
    
    func updateTheme() {
        view.backgroundColor = .background
        
        navigationItem.leftBarButtonItem = customBackButton
    }
}

private extension SettingsZapsViewController {
    func updateViews() {
        if let defaultZapSettings {
            defaultZapInfo.set(defaultZapSettings)
        }
        zapOptionsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, zapOption) in zapOptions.enumerated() {
            let info = ZapInfoView()
            zapOptionsStack.addArrangedSubview(info)
            info.set(zapOption)
            info.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
                self?.show(SettingsEditZapController(.editOptionInArray(index)), sender: nil)
            }))
        }
    }
    
    func setupView() {
        title = "Zap Settings"
        
        let restore = AccentUIButton(title: "restore defaults")
        let restoreParent = UIView()
        restoreParent.addSubview(restore)
        restore.pinToSuperview(edges: [.vertical, .trailing])
        
        updateTheme()
        
        let infoLabel = ThemeableLabel().setTheme { $0.textColor = .foreground4 }
        infoLabel.font = .appFont(withSize: 14, weight: .regular)
        infoLabel.numberOfLines = 0
        
        let stack = UIStackView(axis: .vertical, [
            defaultZapInfo, SpacerView(height: 8),
            infoLabel, SpacerView(height: 24),
            zapOptionsStack, SpacerView(height: 24),
            restoreParent
        ])
        
        zapOptionsStack.spacing = 1
        zapOptionsStack.layer.cornerRadius = 12
        zapOptionsStack.layer.masksToBounds = true
        
        defaultZapInfo.layer.cornerRadius = 12
        defaultZapInfo.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.show(SettingsEditZapController(.editDefault), sender: nil)
        }))
        
        restore.addAction(.init(handler: { _ in
            IdentityManager.instance.requestDefaultSettings { defaultS in
                guard var settings = IdentityManager.instance.userSettings else { return }

                settings.zapDefault = defaultS.zapDefault
                settings.zapConfig = defaultS.zapConfig
                
                IdentityManager.instance.updateSettings(settings)
            }
        }), for: .touchUpInside)
        
        view.addSubview(stack)
        stack.pinToSuperview(edges: [.top, .horizontal], padding: 20, safeArea: true)
        
        IdentityManager.instance.$userSettings.receive(on: DispatchQueue.main).sink { [weak self] settings in
            self?.defaultZapSettings = settings?.zapDefault
            self?.zapOptions = settings?.zapConfig ?? []
            self?.updateViews()
        }
        .store(in: &cancellables)
        
        IdentityManager.instance.requestUserSettings()
    }
}

final class ZapInfoView: MyButton, Themeable {
    let emojiLabel = UILabel()
    let messageLabel = UILabel()
    let amountLabel = UILabel()
    let arrowImageView = UIImageView(image: UIImage(named: "settingsSmallArrow"))
    
    override var isPressed: Bool {
        didSet {
            backgroundColor = isPressed ? .background3.withAlphaComponent(0.6) : .background3
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        let stack = UIStackView([
//            emojiLabel, SpacerView(width: 16, priority: .required),
            messageLabel, SpacerView(width: 17, priority: .required), UIView(),
            amountLabel, SpacerView(width: 12, priority: .required), arrowImageView
        ])
        
        addSubview(stack)
        stack.centerToSuperview().pinToSuperview(edges: .horizontal, padding: 16)
        stack.alignment = .center
        
        constrainToSize(height: 48)
        
        updateTheme()
        
        messageLabel.lineBreakMode = .byTruncatingTail
        emojiLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        arrowImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        messageLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        messageLabel.font = .appFont(withSize: 16, weight: .regular)
        amountLabel.font = .appFont(withSize: 16, weight: .regular)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        backgroundColor = .background3
        messageLabel.textColor = .foreground
        emojiLabel.textColor = .foreground3
        amountLabel.textColor = .foreground3
        arrowImageView.tintColor = .foreground3
    }
    
    func set(_ settings: PrimalZapDefaultSettings) {
        emojiLabel.font = .appFont(withSize: 16, weight: .regular)
        emojiLabel.text = "Default"
        messageLabel.text = settings.message
        amountLabel.text = settings.amount.localized()
    }
    
    func set(_ settings: PrimalZapListSettings) {
        emojiLabel.font = .appFont(withSize: 24, weight: .bold)
        emojiLabel.text = settings.emoji
        messageLabel.text = settings.message
        amountLabel.text = settings.amount.localized()
    }
}

final class AccentUIButton: UIButton, Themeable {
    init(title: String, font: UIFont = .appFont(withSize: 18, weight: .semibold)) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        titleLabel?.font = font
        
        updateTheme()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        setTitleColor(.accent2, for: .normal)
        setTitleColor(.accent2.withAlphaComponent(0.5), for: .highlighted)
    }
}
