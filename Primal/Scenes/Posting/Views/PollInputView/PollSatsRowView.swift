//
//  PollSatsRowView.swift
//  Primal
//
//  Created by Pavle Stevanović on 26. 2. 2026..
//

import UIKit

class PollSatsRowView: PollInputRowView {
    let satsInput = PollTextInputView(name: "sats")

    var tapGesture: BindableTapGestureRecognizer?

    var satsValue: Int {
        get { Int(satsInput.textField.text ?? "") ?? 0 }
        set {
            satsInput.textField.text = "\(newValue)"
            updateValueLabel()
        }
    }
    
    var currentlyEditing: UITextField? {
        didSet {
            satsInput.isHidden = currentlyEditing == nil
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(title: String) {
        super.init(title: title)

        satsInput.isHidden = true

        addSubview(satsInput)
        satsInput.pinToSuperview(edges: .trailing).centerToSuperview(axis: .vertical).constrainToSize(width: 120)

        valueStack.isUserInteractionEnabled = false

        satsInput.textField.addTarget(self, action: #selector(inputChanged), for: .editingChanged)
        satsInput.textField.delegate = self

        let g = BindableTapGestureRecognizer(action: { [weak self] in
            self?.satsInput.becomeFirstResponder()
        })
        g.delegate = self
        tapGesture = g
        addGestureRecognizer(g)
    }

    @objc private func inputChanged() {
        updateValueLabel()
    }

    private func updateValueLabel() {
        let sats = Int(satsInput.textField.text ?? "") ?? 0
        valueLabel.text = "\(sats.localized()) sats"
    }
}

extension PollSatsRowView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentlyEditing = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if currentlyEditing == textField {
            currentlyEditing = nil
        }
    }
}

extension PollSatsRowView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        currentlyEditing == nil
    }
}
