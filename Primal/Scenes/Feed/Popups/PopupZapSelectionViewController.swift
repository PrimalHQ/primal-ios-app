//
//  PopupZapSelectionViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 4.7.23..
//

import Combine
import UIKit

protocol ZapableEntity {
    var zappingName: String { get }
    var avatarURL: String { get }
}

extension PrimalUser: ZapableEntity {
    var avatarURL: String { picture }
    
    var zappingName: String { firstIdentifier }
}

final class PopupZapSelectionViewController: UIViewController {
    let entityToZap: ZapableEntity
    
    @Published var shouldShowAvatar: Bool = false
    
    private var zapOptions: [PrimalZapListSettings] = [] {
        didSet {
            zip(zapOptions, buttons).forEach { option, button in
                button.title = option.amount.shortened()
                button.emoji = option.emoji
            }
            
            messageField.text = zapOptions[safe: selectedOptionIndex]?.message ?? messageField.text
            amountField.text = zapOptions[safe: selectedOptionIndex]?.amount.localized()
            
            updateView()
        }
    }
    
    private var selectedOptionIndex: Int? = 0 {
        didSet {
            updateView()
            
            guard let selectedOptionIndex else { return }
            
            messageField.resignFirstResponder()
            amountField.resignFirstResponder()
            messageField.text = zapOptions[safe: selectedOptionIndex]?.message ?? messageField.text
            amountField.text = zapOptions[safe: selectedOptionIndex]?.amount.localized()
        }
    }
    
    private lazy var buttons = (0...5).map {
        let view = ZapAmountSelectionButton(emoji: "", title: "-")
        view.tag = $0
        view.addAction(.init(handler: { [weak self] _ in
            self?.selectedOptionIndex = view.tag
        }), for: .touchUpInside)
        return view
    }
    
    let avatarView = UIImageView().constrainToSize(50)
    let zapButton = LargeRoundedButton(title: "Zap")
    
    private let titleFirstLabel = UILabel()
    private let zapLabel = UILabel()
    private let usdLabel = UILabel()
    
    private let amountParent = UIView()
    private let amountField = UITextField()
    private let messageField = UITextField()
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(entityToZap: ZapableEntity, _ callback: @escaping (Int, String) -> Void) {
        self.entityToZap = entityToZap
        super.init(nibName: nil, bundle: nil)
        
        overrideUserInterfaceStyle = Theme.current.userInterfaceStyle
        
        setup()
        
        IdentityManager.instance.$userSettings.receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] settings in
                guard let options = settings?.zapConfig else { return }
                self?.zapOptions = options
            })
            .store(in: &cancellables)
        
        zapButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            self.dismiss(animated: true) { 
                let amount = self.zapOptions[safe: self.selectedOptionIndex]?.amount ?? self.inputAmount ?? 0
                callback(amount, self.messageField.text ?? "")
            }
        }), for: .touchUpInside)
    }
    
    var inputAmount: Int? {
        Int((amountField.text ?? "").filter({ $0.isWholeNumber }))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension PopupZapSelectionViewController {
    func updateView() {
        for (index, button) in buttons.enumerated() {
            button.zapSelected = index == selectedOptionIndex
        }
        
        if !entityToZap.avatarURL.isEmpty {
            avatarView.kf.setImage(with: URL(string: entityToZap.avatarURL))
            shouldShowAvatar = true
        } else {
            shouldShowAvatar = false
        }

        if selectedOptionIndex != nil {
            amountParent.layer.borderWidth = 0
            amountParent.backgroundColor = .background3
        } else {
            amountParent.backgroundColor = .background2
            amountParent.layer.borderWidth = 1
        }
        
        let selectedZapAmount = zapOptions[safe: selectedOptionIndex]?.amount ?? inputAmount ?? 0
        
        titleFirstLabel.attributedText = NSAttributedString(string: "Zap \(entityToZap.zappingName) ", attributes: [
            .font: UIFont.appFont(withSize: 20, weight: .bold),
            .foregroundColor: UIColor.foreground3
        ])
        zapLabel.attributedText = .init(string: selectedZapAmount.localized(), attributes: [
            .font: UIFont.appFont(withSize: 20, weight: .black),
            .foregroundColor: UIColor.foreground
        ])
        
        usdLabel.text = "$\(selectedZapAmount.satsToUsdAmountString(.threeDecimals)) USD"
    }
    
    func setup() {
        view.backgroundColor = .background4
        if let pc = presentationController as? UISheetPresentationController {
            pc.detents = [.custom(resolver: { _ in 579 })]
        }
        
        let pullBar = UIView()
        
        lazy var topButtonStack = UIStackView(arrangedSubviews: Array(buttons.prefix(3)))
        lazy var bottomButtonStack = UIStackView(arrangedSubviews: Array(buttons.suffix(3)))
        lazy var actionStack = UIStackView(arrangedSubviews: [topButtonStack, bottomButtonStack])
        
        [topButtonStack, bottomButtonStack].forEach {
            $0.spacing = 16
        }
        
        actionStack.spacing = 16
        actionStack.axis = .vertical
        actionStack.alignment = .center
        
        avatarView.layer.cornerRadius = 25
        avatarView.clipsToBounds = true
        avatarView.contentMode = .scaleAspectFill
        
        usdLabel.font = .appFont(withSize: 16, weight: .regular)
        usdLabel.textColor = .foreground3
        
        let inputParent = UIView()
        
        let title2Label = UILabel()
        title2Label.attributedText = .init(string: " sats", attributes: [
            .font: UIFont.appFont(withSize: 20, weight: .bold),
            .foregroundColor: UIColor.foreground3
        ])
        titleFirstLabel.lineBreakMode = .byTruncatingTail
        zapLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        title2Label.setContentCompressionResistancePriority(.required, for: .horizontal)
        let titleStack = UIStackView([titleFirstLabel, zapLabel, title2Label])
        let topStack = UIStackView(axis: .vertical, [avatarView, titleStack, SpacerView(height: 2, priority: .required), usdLabel])
        topStack.setCustomSpacing(8, after: avatarView)
        topStack.alignment = .center
        
        let buttonStack = UIStackView(axis: .vertical, [
            topStack, SpacerView(height: 8, priority: .required), SpacerView(height: 16, priority: .defaultLow),
            actionStack, SpacerView(height: 12, priority: .required), SpacerView(height: 8, priority: .init(1)),
            amountParent, SpacerView(height: 4, priority: .required), SpacerView(height: 8, priority: .defaultLow),
            inputParent
        ])
        
        let mainStack = UIStackView(axis: .vertical, [
            pullBar,
            buttonStack,
            zapButton
        ])
        mainStack.distribution = .equalSpacing
        mainStack.alignment = .center
        buttonStack.pinToSuperview(edges: .horizontal)
        zapButton.pinToSuperview(edges: .horizontal)
        
        let keyboardSpacerView = KeyboardSizingView()
        let bodyStack = UIStackView(axis: .vertical, [
            mainStack, SpacerView(height: 8, priority: .required), SpacerView(height: 8, priority: .defaultLow),
            keyboardSpacerView
        ])
        keyboardSpacerView.updateHeightCancellable().store(in: &cancellables)
        
        var smallScreen = true
        if UIScreen.main.bounds.height > 900 {
            smallScreen = false
            $shouldShowAvatar.map({ !$0 }).assign(to: \.isHidden, on: avatarView).store(in: &cancellables)
        } else {
            Publishers.CombineLatest($shouldShowAvatar.removeDuplicates(), KeyboardManager.instance.$keyboardHeight.map { $0 < 5 })
                .map({ ($0 && $1) })
                .sink(receiveValue: { [weak self] shouldShow in
                    self?.avatarView.alpha = shouldShow ? 1 : 0
                    self?.avatarView.isHidden = !shouldShow
                })
                .store(in: &cancellables)
        }
        
        KeyboardManager.instance.$keyboardHeight.map { $0 > 5 }.sink(receiveValue: { [weak self] keyboardShown in
            self?.usdLabel.isHidden = smallScreen && keyboardShown
            if keyboardShown {
                mainStack.distribution = .fill
                mainStack.spacing = 12
            } else {
                mainStack.distribution = .equalSpacing
                mainStack.spacing = UIStackView.spacingUseDefault
            }
        })
        .store(in: &cancellables)
        
        view.addSubview(bodyStack)
        bodyStack.pinToSuperview(edges: .top, padding: 16).pinToSuperview(edges: .horizontal, padding: 32).pinToSuperview(edges: .bottom)
        zapButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        amountParent.backgroundColor = .background3
        amountParent.layer.cornerRadius = 22
        amountParent.layer.borderColor = UIColor.accent.cgColor
        amountParent.addSubview(amountField)
        amountParent.constrainToSize(height: 44)
        amountField.pinToSuperview(edges: .leading, padding: 16).pinToSuperview(edges: .trailing, padding: 8).centerToSuperview(axis: .vertical)
        amountField.attributedPlaceholder = NSAttributedString(string: "Custom amount...", attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .foregroundColor: UIColor.foreground5
        ])
        
        amountField.font = .appFont(withSize: 16, weight: .regular)
        amountField.textColor = .foreground
        amountField.delegate = self
        amountField.keyboardType = .numberPad
        amountField.clearButtonMode = .always
        
        inputParent.backgroundColor = .background3
        inputParent.layer.cornerRadius = 22
        inputParent.addSubview(messageField)
        inputParent.constrainToSize(height: 44)
        messageField.pinToSuperview(edges: .leading, padding: 16).pinToSuperview(edges: .trailing, padding: 8).centerToSuperview(axis: .vertical)
        messageField.attributedPlaceholder = NSAttributedString(string: "Add a comment...", attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .foregroundColor: UIColor.foreground5
        ])
        messageField.font = .appFont(withSize: 16, weight: .regular)
        messageField.textColor = .foreground
        messageField.delegate = self
        messageField.clearButtonMode = .always
        
        pullBar.constrainToSize(width: 60, height: 5)
        pullBar.backgroundColor = .foreground.withAlphaComponent(0.8)
        pullBar.layer.cornerRadius = 2.5
        
        view.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.messageField.resignFirstResponder()
            self?.amountField.resignFirstResponder()
        }))
    }
}

extension PopupZapSelectionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == amountField {
            selectedOptionIndex = nil
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == amountField {
            updateView()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == messageField { return true }
        
        let text = (textField.text ?? "") as NSString
        let newText = text.replacingCharacters(in: range, with: string)
        
        if newText.isEmpty {
            DispatchQueue.main.async { self.updateView() }
            return true
        }
        
        let oldNumber = Int((textField.text ?? "").filter { $0.isWholeNumber }) ?? 0
        let number = Int(newText.filter { $0.isWholeNumber }) ?? 0
        textField.text = number.localized()
        
        let oldDelimitersCount = (oldNumber.digitCount - 1) / 3
        let newDelimitersCount = (number.digitCount - 1) / 3
        let delta = newDelimitersCount - oldDelimitersCount
        
        if let newPosition = textField.position(from: textField.beginningOfDocument, offset: range.location + string.count + delta) {
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
        updateView()
        
        return false
    }
}
