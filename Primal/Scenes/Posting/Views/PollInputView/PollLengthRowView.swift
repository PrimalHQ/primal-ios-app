//
//  PollLengthRowView.swift
//  Primal
//
//  Created by Pavle Stevanović on 25. 2. 2026..
//

import UIKit

class PollTextInputView: UIView {
    let textField = UITextField()
    private let unitLabel = UILabel("", color: .foreground3, font: .appFont(withSize: 16, weight: .regular))

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(name: String, value: Int = 0) {
        super.init(frame: .zero)

        unitLabel.text = name
        unitLabel.isUserInteractionEnabled = false
        unitLabel.setContentHuggingPriority(.required, for: .horizontal)

        textField.font = .appFont(withSize: 16, weight: .regular)
        textField.textColor = .foreground
        textField.keyboardType = .numberPad
        textField.text = "\(value)"

        addSubview(textField)
        textField.pinToSuperview(edges: .vertical).pinToSuperview(edges: .horizontal, padding: 12)
        
        addSubview(unitLabel)
        unitLabel.pinToSuperview(edges: .trailing, padding: 12).centerToSuperview(axis: .vertical)
        
        backgroundColor = .background3
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.foreground6.cgColor
            
        constrainToSize(height: 36)
        
        addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.becomeFirstResponder()
        }))
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }
}

class PollLengthRowView: PollInputRowView {
    let dayInput = PollTextInputView(name: "day", value: 1)
    let hourInput = PollTextInputView(name: "hrs", value: 0)
    let minuteInput = PollTextInputView(name: "min", value: 0)
    
    lazy var inputStack = UIStackView(spacing: 8, [dayInput, hourInput, minuteInput])
    
    var tapGesture: BindableTapGestureRecognizer?
    
    var currentlyEditing: UITextField? {
        didSet {
            inputStack.isHidden = currentlyEditing == nil
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init() {
        super.init(title: "Poll length")
        inputStack.distribution = .fillEqually
        inputStack.isHidden = true

        mainStack.addArrangedSubview(inputStack)
        mainStack.addArrangedSubview(SpacerView(height: 8))

        updateValueLabel()

        [dayInput, hourInput, minuteInput].forEach {
            $0.textField.addTarget(self, action: #selector(inputChanged), for: .editingChanged)
            $0.textField.delegate = self
        }
        
        valueStack.isUserInteractionEnabled = false
        
        let g = BindableTapGestureRecognizer(action: { [weak self] in
            self?.dayInput.becomeFirstResponder()
        })
        g.delegate = self
        tapGesture = g
        addGestureRecognizer(g)
    }

    @objc private func inputChanged() {
        if let day = Int(dayInput.textField.text ?? ""), day > 100 {
            dayInput.textField.text = "100"
        }
        if let hour = Int(hourInput.textField.text ?? ""), hour > 23 {
            hourInput.textField.text = "23"
        }
        if let minutes = Int(minuteInput.textField.text ?? ""), minutes > 59 {
            minuteInput.textField.text = "59"
        }
        updateValueLabel()
    }

    func updateValueLabel() {
        let days = Int(dayInput.textField.text ?? "") ?? 0
        let hours = Int(hourInput.textField.text ?? "") ?? 0
        let minutes = Int(minuteInput.textField.text ?? "") ?? 0

        var parts: [String] = []
        if days > 0 { parts.append("\(days) day\(days == 1 ? "" : "s")") }
        if hours > 0 { parts.append("\(hours) hr\(hours == 1 ? "" : "s")") }
        if minutes > 0 { parts.append("\(minutes) min") }

        valueLabel.text = parts.isEmpty ? "0 min" : parts.joined(separator: " ")
    }

    var totalSeconds: Int {
        let days = Int(dayInput.textField.text ?? "") ?? 0
        let hours = Int(hourInput.textField.text ?? "") ?? 0
        let minutes = Int(minuteInput.textField.text ?? "") ?? 0
        return (days * 86400) + (hours * 3600) + (minutes * 60)
    }
}

extension PollLengthRowView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentlyEditing = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if currentlyEditing == textField {
            currentlyEditing = nil
        }
    }
}

extension PollLengthRowView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        currentlyEditing == nil
    }
}
