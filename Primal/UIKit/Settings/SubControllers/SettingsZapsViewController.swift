//
//  SettingsZapsViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 10.7.23..
//

import Combine
import UIKit

class SettingsZapsViewController: UIViewController, Themeable {
    private lazy var inputFields = emojis.map { emoji in
        let view = SettingsDoubleInputView()
        view.first.text = emoji
        return view
    }
    private let emojis = ["👍", "🌿", "🤙", "💜", "🔥", "🚀"]
    private let defaultAmounts: [Int64] = [21, 420, 1000, 5000, 10000, 100000]
    private var zapOptions: [Int64] = [] {
        didSet {
            updateView()
        }
    }
    let defaultInput = SettingsZapInputView().constrainToSize(width: 120, height: 44)
    
    private var defaultZapAmount: Int64 = 100 {
        didSet {
            defaultInput.field.text = defaultZapAmount.localized()
        }
    }
    
    weak var currentlyEditingField: UITextField? {
        didSet {
            updateView()
        }
    }
    
    var cancellables: Set<AnyCancellable> = []
    
    var didChange = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        updateTheme()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let currentlyEditingField {
            textFieldDidEndEditing(currentlyEditingField)
        }
        
        if didChange {
            guard var settings = IdentityManager.instance.userSettings else { return }
            settings.content.defaultZapAmount = defaultZapAmount
            settings.content.zapOptions = zapOptions
            IdentityManager.instance.updateSettings(settings)
        }
    }
    
    func updateTheme() {
        view.backgroundColor = .background
        
        navigationItem.leftBarButtonItem = customBackButton
    }
}

private extension SettingsZapsViewController {
    func updateView() {
        zip(zapOptions, inputFields).forEach { option, field in
            if field.second == currentlyEditingField {
                field.second.text = "\(option)"
                field.second.textColor = .foreground
                field.backgroundColor = .background2
            } else {
                field.second.text = option.localized()
                field.second.textColor = .foreground3
                field.backgroundColor = .background3
            }
        }
        
        if defaultInput.field == currentlyEditingField {
            defaultInput.field.text = "\(defaultZapAmount)"
        } else {
            defaultInput.field.text = defaultZapAmount.localized()
        }
    }
    
    func setupView() {
        title = "Zaps"
        
        let inputContainer = UIView()
        inputContainer.addSubview(defaultInput)
        defaultInput.pinToSuperview(edges: [.vertical, .leading])
        
        let border = ThemeableView().setTheme({ $0.backgroundColor = .background3 }).constrainToSize(height: 1)
        
        lazy var topButtonStack = UIStackView(arrangedSubviews: Array(inputFields.prefix(3)))
        lazy var bottomButtonStack = UIStackView(arrangedSubviews: Array(inputFields.suffix(3)))
        
        let restore = AccentUIButton(title: "restore defaults")
        let restoreParent = UIView()
        restoreParent.addSubview(restore)
        restore.pinToSuperview(edges: [.vertical, .trailing])
        
        [topButtonStack, bottomButtonStack].forEach {
            $0.distribution = .fillEqually
            $0.spacing = 14
        }
        
        let stack = UIStackView(arrangedSubviews: [
            SettingsTitleViewVibrant(title: "SET DEFAULT ZAP AMOUNT"),                  SpacerView(height: 16),
            inputContainer,                                                             SpacerView(height: 16),
            border,                                                                     SpacerView(height: 28),
            SettingsTitleViewVibrant(title: "SET CUSTOM ZAP AMOUNT AND EMOJI PRESETS"), SpacerView(height: 16),
            topButtonStack, SpacerView(height: 16), bottomButtonStack,                  SpacerView(height: 28),
            restoreParent,                                                              UIView()
        ])
        
        view.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 24).pinToSuperview(edges: .vertical, padding: 12, safeArea: true)
        
        stack.axis = .vertical
        
        updateTheme()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
        restore.addTarget(self, action: #selector(restoreDefaults), for: .touchUpInside)
        
        IdentityManager.instance.$userSettings.receive(on: DispatchQueue.main).sink { [weak self] settings in
            self?.defaultZapAmount = settings?.content.defaultZapAmount ?? 100
            self?.zapOptions = settings?.content.zapOptions ?? self?.defaultAmounts ?? []
        }
        .store(in: &cancellables)
        
        IdentityManager.instance.requestUserSettings()
        
        let inputFields: [UITextField] = view.findAllSubviews()
        inputFields.forEach { $0.delegate = self }
    }
    
    @objc func viewTapped() {
        let inputFields: [UITextField] = view.findAllSubviews()
        inputFields.forEach { $0.resignFirstResponder() }
    }
    
    @objc func restoreDefaults() {
        defaultZapAmount = 100
        zapOptions = defaultAmounts
        didChange = true
    }
}

extension SettingsZapsViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentlyEditingField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        defer {
            if currentlyEditingField == textField {
                currentlyEditingField = nil
            }
        }
        
        guard let amount = Int64(textField.text ?? "") else { return }
        
        didChange = true
        
        if textField == defaultInput.field {
            defaultZapAmount = amount
        }
        
        guard !zapOptions.isEmpty else { return }
        
        for (index, field) in inputFields.enumerated() {
            if field.second == textField {
                zapOptions[index] = amount
            }
        }
    }
}

final class SettingsDoubleInputView: UIView, Themeable {
    let first = UITextField().constrainToSize(height: 72)
    let second = UITextField().constrainToSize(height: 40)
    
    let border1 = ThemeableView().setTheme({ $0.backgroundColor = .foreground6 }).constrainToSize(height: 1)
    let border2 = ThemeableView().setTheme({ $0.backgroundColor = .foreground6 }).constrainToSize(height: 1)
    let background = ThemeableView().setTheme({ $0.backgroundColor = .background }).constrainToSize(height: 4)
    
    let completeBackground = ThemeableView().setTheme({
        $0.backgroundColor = .background3
        $0.layer.cornerRadius = 6
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.foreground6.cgColor
    })
    
    var borderColor: UIColor {
        get { border1.backgroundColor ?? .foreground6 }
        set {
            border1.backgroundColor = newValue
            border2.backgroundColor = newValue
            completeBackground.layer.borderColor = newValue.cgColor
        }
    }
    
    override var backgroundColor: UIColor? {
        get { completeBackground.backgroundColor }
        set { completeBackground.backgroundColor = newValue }
    }
    
    init() {
        super.init(frame: .zero)
        
        let stack = UIStackView(arrangedSubviews: [first, border1, background, border2, second])
        stack.axis = .vertical
        
        [first, second].forEach { field in
            field.textAlignment = .center
            field.font = .appFont(withSize: 16, weight: .bold)
            field.keyboardType = .numberPad
        }
        
        first.isEnabled = false
        first.font = .appFont(withSize: 28, weight: .bold)
        
        addSubview(completeBackground)
        completeBackground.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .vertical)
        
        addSubview(stack)
        stack.pinToSuperview()
        
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        second.textColor = .foreground3
    }
}

final class SettingsZapInputView: UIView, Themeable {
    let field = UITextField()
    
    init() {
        super.init(frame: .zero)
        
        addSubview(field)
        field.pinToSuperview()
        field.textAlignment = .center
        field.font = .appFont(withSize: 16, weight: .bold)
        field.keyboardType = .numberPad
        
        layer.borderWidth = 1
        layer.cornerRadius = 6
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        field.textColor = .foreground3
        backgroundColor = .background3
        layer.borderColor = UIColor.foreground6.cgColor
    }
}

final class AccentUIButton: UIButton, Themeable {
    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        titleLabel?.font = .appFont(withSize: 18, weight: .medium)
        
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        setTitleColor(.accent, for: .normal)
        setTitleColor(.accent.withAlphaComponent(0.5), for: .highlighted)
    }
}
