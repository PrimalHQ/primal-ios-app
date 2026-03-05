//
//  PopupZapPollVoteViewController.swift
//  Primal
//
//  Created on 5.3.26..
//

import Combine
import UIKit

final class PopupZapPollVoteViewController: UIViewController {
    private let valueMinimum: Int?
    private let valueMaximum: Int?
    private let callback: (Int, String) -> Void

    private let computedAmounts: [Int]

    private var selectedAmountIndex: Int? = 0 {
        didSet {
            updateView()

            guard let selectedAmountIndex else { return }

            messageField.resignFirstResponder()
            amountField.resignFirstResponder()
            amountField.text = computedAmounts[safe: selectedAmountIndex]?.localized()
        }
    }

    static func generateAmounts(min: Int, max: Int) -> [Int] {
        let span = max - min
        guard span > 0 else { return [min] }

        let count = Swift.min(span + 1, 6)
        if count <= 1 { return min == max ? [min] : [min, max] }

        let step = span / (count - 1)
        guard step > 0 else {
            return (min...max).map { $0 }
        }

        var amounts: [Int] = []
        for i in 0..<count {
            amounts.append(min + step * i)
        }
        // Ensure max is always included as the last value
        if amounts.last != max {
            amounts[amounts.count - 1] = max
        }
        return amounts
    }

    private var buttons: [ZapPollAmountButton] = []

    private let titleFirstLabel = UILabel()
    private let zapLabel = UILabel()
    private let title2Label = UILabel()
    private let usdLabel = UILabel()

    private let customAmountLabel = UILabel()
    private let amountParent = UIView()
    private let amountField = UITextField()
    private let messageField = UITextField()
    private let voteButton = LargeRoundedButton(title: "Vote")

    private var cancellables: Set<AnyCancellable> = []

    init(valueMinimum: Int?, valueMaximum: Int?, callback: @escaping (Int, String) -> Void) {
        self.valueMinimum = valueMinimum
        self.valueMaximum = valueMaximum
        self.callback = callback

        if let min = valueMinimum, let max = valueMaximum {
            self.computedAmounts = Self.generateAmounts(min: min, max: max)
        } else {
            self.computedAmounts = []
        }

        super.init(nibName: nil, bundle: nil)

        overrideUserInterfaceStyle = Theme.current.userInterfaceStyle

        setup()

        voteButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            self.dismiss(animated: true) {
                let amount: Int
                if let idx = self.selectedAmountIndex {
                    amount = self.computedAmounts[safe: idx] ?? self.inputAmount ?? 0
                } else {
                    amount = self.inputAmount ?? 0
                }
                self.callback(amount, self.messageField.text ?? "")
            }
        }), for: .touchUpInside)
    }

    var inputAmount: Int? {
        Int((amountField.text ?? "").filter({ $0.isWholeNumber }))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Private

private extension PopupZapPollVoteViewController {
    var selectedAmount: Int {
        if let idx = selectedAmountIndex {
            return computedAmounts[safe: idx] ?? 0
        }
        return inputAmount ?? 0
    }

    var isInputOutOfRange: Bool {
        guard selectedAmountIndex == nil, let amount = inputAmount, amount > 0 else { return false }
        if let min = valueMinimum, amount < min { return true }
        if let max = valueMaximum, amount > max { return true }
        return false
    }

    func updateView() {
        for (index, button) in buttons.enumerated() {
            button.isChosen = index == selectedAmountIndex
        }

        let outOfRange = isInputOutOfRange

        if selectedAmountIndex != nil {
            amountParent.layer.borderWidth = 0
            amountParent.layer.borderColor = UIColor.accent.cgColor
            amountParent.backgroundColor = .background3
        } else if outOfRange {
            amountParent.backgroundColor = .background2
            amountParent.layer.borderWidth = 1
            amountParent.layer.borderColor = UIColor.failureRed.cgColor
        } else {
            amountParent.backgroundColor = .background2
            amountParent.layer.borderWidth = 1
            amountParent.layer.borderColor = UIColor.accent.cgColor
        }

        voteButton.isEnabled = !outOfRange

        let amount = selectedAmount

        titleFirstLabel.attributedText = NSAttributedString(string: "Zap ", attributes: [
            .font: UIFont.appFont(withSize: 20, weight: .bold),
            .foregroundColor: UIColor.foreground3
        ])
        zapLabel.attributedText = .init(string: amount.localized(), attributes: [
            .font: UIFont.appFont(withSize: 20, weight: .black),
            .foregroundColor: UIColor.foreground
        ])
        title2Label.attributedText = .init(string: " sats", attributes: [
            .font: UIFont.appFont(withSize: 20, weight: .bold),
            .foregroundColor: UIColor.foreground3
        ])

        usdLabel.text = "$\(amount.satsToUsdAmountString(.threeDecimals)) USD"
    }

    func setup() {
        view.backgroundColor = .background4
        if let pc = presentationController as? UISheetPresentationController {
            pc.detents = [.custom(resolver: { _ in 540 })]
        }

        let pullBar = UIView()
        pullBar.constrainToSize(width: 60, height: 5)
        pullBar.backgroundColor = .foreground.withAlphaComponent(0.8)
        pullBar.layer.cornerRadius = 2.5

        // Title
        zapLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        title2Label.setContentCompressionResistancePriority(.required, for: .horizontal)
        let titleStack = UIStackView([titleFirstLabel, zapLabel, title2Label])

        usdLabel.font = .appFont(withSize: 16, weight: .regular)
        usdLabel.textColor = .foreground3

        let topStack = UIStackView(axis: .vertical, [titleStack, SpacerView(height: 2, priority: .required), usdLabel])
        topStack.alignment = .center

        // Preset buttons (hide when only 1 amount)
        let amounts = computedAmounts
        let showButtons = amounts.count > 1
        let showCustomAmount = amounts.count >= 6

        var contentViews: [UIView] = [
            topStack,
            SpacerView(height: 8, priority: .required), SpacerView(height: 16, priority: .defaultLow)
        ]

        if showButtons {
            buttons = amounts.enumerated().map { index, amount in
                let btn = ZapPollAmountButton(amount: amount)
                btn.addAction(.init(handler: { [weak self] _ in
                    self?.selectedAmountIndex = index
                }), for: .touchUpInside)
                return btn
            }

            let actionStack: UIView
            if amounts.count <= 3 {
                let row = UIStackView(arrangedSubviews: buttons)
                row.spacing = 12
                row.distribution = .fillEqually
                actionStack = row
            } else {
                let topRow = UIStackView(arrangedSubviews: Array(buttons.prefix(3)))
                topRow.spacing = 12
                topRow.distribution = .fillEqually
                let bottomRow = UIStackView(arrangedSubviews: Array(buttons.suffix(from: 3).map { $0 }))
                bottomRow.spacing = 12
                bottomRow.distribution = .fillEqually
                let stack = UIStackView(axis: .vertical, [topRow, bottomRow])
                stack.spacing = 12
                topRow.pinToSuperview(edges: .horizontal)
                bottomRow.pinToSuperview(edges: .horizontal)
                actionStack = stack
            }

            contentViews.append(actionStack)
            contentViews.append(SpacerView(height: 12, priority: .required))
            contentViews.append(SpacerView(height: 8, priority: .init(1)))
        }
        
        // Custom amount label
        var rangeText = "This poll allows votes"
        if let min = valueMinimum, let max = valueMaximum {
            if min != max {
                rangeText += " between \(min.localized()) - \(max.localized()) sats"
            } else {
                rangeText = "This poll only allows votes of \(min.localized()) sats"
            }
        } else if let min = valueMinimum {
            rangeText += " greater than \(min.localized()) sats"
        } else if let max = valueMaximum {
            rangeText += " lesser than \(max.localized()) sats"
        }
        customAmountLabel.text = rangeText
        customAmountLabel.font = .appFont(withSize: 14, weight: .regular)
        customAmountLabel.textColor = .foreground5
        customAmountLabel.textAlignment = .center
        
        contentViews.append(customAmountLabel)
        contentViews.append(SpacerView(height: 4, priority: .required))

        if showCustomAmount {

            // Amount field
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

            contentViews.append(amountParent)
            contentViews.append(SpacerView(height: 4, priority: .required))
            contentViews.append(SpacerView(height: 8, priority: .defaultLow))
        }

        // Message field
        let inputParent = UIView()
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
        contentViews.append(inputParent)

        // Layout
        let contentStack = UIStackView(axis: .vertical, contentViews)
        contentStack.arrangedSubviews.compactMap({ $0 as? UIStackView }).forEach { $0.pinToSuperview(edges: .horizontal) }

        let mainStack = UIStackView(axis: .vertical, [
            pullBar,
            contentStack,
            voteButton
        ])
        mainStack.distribution = .equalSpacing
        mainStack.alignment = .center
        contentStack.pinToSuperview(edges: .horizontal)
        voteButton.pinToSuperview(edges: .horizontal)

        let keyboardSpacerView = KeyboardSizingView()
        let bodyStack = UIStackView(axis: .vertical, [
            mainStack,
            SpacerView(height: 8, priority: .required), SpacerView(height: 8, priority: .defaultLow),
            keyboardSpacerView
        ])
        keyboardSpacerView.updateHeightCancellable().store(in: &cancellables)

        KeyboardManager.instance.$keyboardHeight.map { $0 > 5 }.sink(receiveValue: { [weak self] keyboardShown in
            self?.usdLabel.isHidden = keyboardShown
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
        voteButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        view.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.messageField.resignFirstResponder()
            self?.amountField.resignFirstResponder()
        }))

        // Set initial selection
        if computedAmounts.isEmpty {
            selectedAmountIndex = nil
        } else {
            amountField.text = computedAmounts[0].localized()
        }
        updateView()
    }
}

// MARK: - UITextFieldDelegate

extension PopupZapPollVoteViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == amountField {
            selectedAmountIndex = nil
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

// MARK: - ZapPollAmountButton

private final class ZapPollAmountButton: MyButton, Themeable {
    private let amountLabel = UILabel()
    private let satsLabel = UILabel()

    var isChosen = false {
        didSet { updateTheme() }
    }

    override var isPressed: Bool {
        didSet { alpha = isPressed ? 0.5 : 1 }
    }

    init(amount: Int) {
        super.init(frame: .zero)

        amountLabel.text = amount.localized()
        amountLabel.font = .appFont(withSize: 16, weight: .bold)

        satsLabel.text = " sats"
        satsLabel.font = .appFont(withSize: 16, weight: .regular)

        let stack = UIStackView([amountLabel, satsLabel])
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        addSubview(stack)
        stack.centerToSuperview()

        constrainToSize(height: 44)
        layer.cornerRadius = 22
        layer.borderWidth = 1

        updateTheme()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func updateTheme() {
        if isChosen {
            layer.borderColor = UIColor.accent.cgColor
            backgroundColor = .background3
        } else {
            layer.borderColor = UIColor.foreground6.cgColor
            backgroundColor = .clear
        }
        amountLabel.textColor = .foreground
        satsLabel.textColor = .foreground3
    }
}
