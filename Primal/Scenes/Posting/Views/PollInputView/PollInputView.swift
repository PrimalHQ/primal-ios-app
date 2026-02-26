//
//  PollInputView.swift
//  Primal
//
//  Created by Pavle Stevanović on 25. 2. 2026..
//

import Combine
import UIKit

class PollInputView: UIView {

    private let maxCharacters = 35

    private let choicesStack = UIStackView(axis: .vertical, spacing: 8, [])
    private let addChoiceButton = UIButton(configuration: .accent("+ Add choice", font: .appFont(withSize: 16, weight: .regular))).constrainToSize(height: 42)

    let pollTypeRow = PollInputRowView(title: "Poll type")
    private let pollLengthRow = PollLengthRowView()
    private let minZapRow = PollSatsRowView(title: "Min zap")
    private let maxZapRow = PollSatsRowView(title: "Max zap")

    private var cancellables: Set<AnyCancellable> = []
    let manager: PostingTextViewManager

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(manager: PostingTextViewManager) {
        self.manager = manager
        super.init(frame: .zero)
        setup()
    }
    
    func reset() {
        choicesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Start with 2 choices
        addChoiceField(placeholder: "Choice 1")
        addChoiceField(placeholder: "Choice 2")

        updateLabels()
    }

    private func setup() {
        addChoiceButton.contentHorizontalAlignment = .leading
        addChoiceButton.addTarget(self, action: #selector(addChoiceTapped), for: .touchUpInside)

        // Main stack
        let mainStack = UIStackView(axis: .vertical, [
            choicesStack,
            addChoiceButton,
            pollTypeRow,
            pollLengthRow,
            minZapRow,
            maxZapRow
        ])

        addSubview(mainStack)
        mainStack.pinToSuperview()
    }

    // MARK: - Choice Fields

    private func addChoiceField(placeholder: String) {
        let container = UIView()
        container.backgroundColor = .background3
        container.layer.cornerRadius = 8

        let textField = UITextField()
        textField.font = .appFont(withSize: 16, weight: .regular)
        textField.textColor = .foreground
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
            .foregroundColor: UIColor.foreground4,
            .font: UIFont.appFont(withSize: 16, weight: .regular)
        ])
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)

        let countLabel = UILabel("0/\(maxCharacters)", color: .foreground4, font: .appFont(withSize: 14, weight: .regular))
        countLabel.setContentHuggingPriority(.required, for: .horizontal)
        countLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let innerStack = UIStackView(arrangedSubviews: [textField, countLabel])
        innerStack.spacing = 8
        innerStack.alignment = .center

        container.addSubview(innerStack)
        innerStack.pinToSuperview(edges: .horizontal, padding: 12).pinToSuperview(edges: .vertical, padding: 10)

        // Tag the count label on the container for later lookup
        container.tag = choicesStack.arrangedSubviews.count

        choicesStack.addArrangedSubview(container)
    }

    @objc private func addChoiceTapped() {
        let index = choicesStack.arrangedSubviews.count + 1
        addChoiceField(placeholder: "Choice \(index)")
    }

    @objc private func textFieldChanged(_ textField: UITextField) {
        // Find the container and count label
        guard let container = textField.superview?.superview else { return }
        if let innerStack = container.subviews.first(where: { $0 is UIStackView }) as? UIStackView,
           let countLabel = innerStack.arrangedSubviews.last as? UILabel {
            let count = textField.text?.count ?? 0
            countLabel.text = "\(count)/\(maxCharacters)"
        }
        syncOptionsToManager()
    }

    private func syncOptionsToManager() {
        let options: [String] = choicesStack.arrangedSubviews.compactMap { container in
            guard let innerStack = container.subviews.first(where: { $0 is UIStackView }) as? UIStackView,
                  let textField = innerStack.arrangedSubviews.first as? UITextField else { return nil }
            let text = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            return text.isEmpty ? nil : text
        }
        manager.pollOptions?.options = options
    }

    // MARK: - Labels

    func updateLabels() {
        guard let pollOptions = manager.pollOptions else { return }
        
        pollTypeRow.valueLabel.text = pollOptions.type.name
        pollLengthRow.valueLabel.text = timeStringForTime(pollOptions.length)
        
        switch pollOptions.type {
        case .user:
            minZapRow.isHidden = true
            maxZapRow.isHidden = true
        case .zap(let min, let max):
            minZapRow.isHidden = false
            maxZapRow.isHidden = false
            
            minZapRow.satsValue = min
            maxZapRow.satsValue = max
        }
    }
    
    func timeStringForTime(_ time: (Int, Int, Int)) -> String {
        let (days, hours, minutes) = time
        
        var string = ""
        if days > 0 {
            string += "\(days) day"
            if days > 1 {
                string += "s"
            }
        }
        
        if hours > 1 {
            string += " \(hours) hour"
            if hours > 1 {
                string += "s"
            }
        }
        
        if minutes > 1 {
            string += " \(minutes) minute"
            if minutes > 1 {
                string += "s"
            }
        }
        
        return string.isEmpty ? "Unlimited" : string
    }
}

// MARK: - UITextFieldDelegate

extension PollInputView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= maxCharacters
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
