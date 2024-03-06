//
//  LargeBalanceConversionInputView.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.10.23..
//

import Combine
import UIKit

final class LargeBalanceConversionInputView: UIStackView, Themeable {
    @Published var isBitcoinPrimary = true
    @Published var balance: Int = 0
    
    private let amountInput = UITextField()
    private let smallAmountLabel = UILabel()
    
    private let largeCurrencyLabel = UILabel()
    private let large$Label = UILabel()
    
    private let accessoryView = BalanceInputAccessoryView()
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let formatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 2
        return nf
    }()
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        large$Label.textColor = .foreground4
        amountInput.textColor = .foreground
        largeCurrencyLabel.textColor = .foreground4
        smallAmountLabel.textColor = .foreground4
        
        accessoryView.updateTheme()
    }
    
    @discardableResult override func becomeFirstResponder() -> Bool {
        guard isUserInteractionEnabled else { return false }
        return amountInput.becomeFirstResponder()
    }
    
    @discardableResult override func resignFirstResponder() -> Bool {
        return amountInput.resignFirstResponder()
    }
    
    override var isFirstResponder: Bool { amountInput.isFirstResponder }
}

extension LargeBalanceConversionInputView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard var newText = (textField.text as? NSString)?.replacingCharacters(in: range, with: string) else { return true }
        
        if let number = numberFromText(newText) {
            DispatchQueue.main.async {
                if self.isBitcoinPrimary {
                    self.balance = Int(number)
                } else {
                    self.balance = Int(number.usdToSAT)
                }
            }
            return true
        }
        return false
    }
}

private extension LargeBalanceConversionInputView {
    func numberFromText(_ text: String) -> Double? {
        if text.count > 10 { return nil }
        let updatedText = text.replacingOccurrences(of: formatter.groupingSeparator ?? "----", with: "")
        return text.isEmpty ? 0 : Double(updatedText)
    }
    
    func setup() {
        setupLayout()
        updateTheme()
        
        large$Label.text = "$"
        large$Label.font = .appFont(withSize: 28, weight: .medium)
        largeCurrencyLabel.font = .appFont(withSize: 16, weight: .medium)
        smallAmountLabel.font = .appFont(withSize: 14, weight: .medium)
        
        large$Label.setContentCompressionResistancePriority(.required, for: .horizontal)
        largeCurrencyLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        amountInput.font = .appFont(withSize: 48, weight: .bold)
        amountInput.delegate = self
        amountInput.keyboardType = .numberPad
        
        amountInput.inputAccessoryView = accessoryView
        accessoryView.groupingButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            var text = self.amountInput.text ?? ""
            text += self.formatter.groupingSeparator ?? ""
            
            if self.numberFromText(text) != nil {
                self.amountInput.text = text
            }
        }), for: .touchUpInside)
        accessoryView.decimalButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            var text = self.amountInput.text ?? ""
            text += self.formatter.decimalSeparator ?? ""
            
            if self.numberFromText(text) != nil {
                self.amountInput.text = text
            }
        }), for: .touchUpInside)
        accessoryView.doneButton.addAction(.init(handler: { [weak self] _ in
            self?.amountInput.resignFirstResponder()
        }), for: .touchUpInside)
    }
    
    func setupLayout() {
        let dollarParent = UIView()
        let currencyParent = UIView()
        
        dollarParent.addSubview(large$Label)
        large$Label.pinToSuperview(edges: .top, padding: 8).pinToSuperview(edges: .horizontal)
        
        currencyParent.addSubview(largeCurrencyLabel)
        largeCurrencyLabel.pinToSuperview(edges: .bottom, padding: 8).pinToSuperview(edges: .horizontal)
        
        let primaryRow = UIView()
        [dollarParent, amountInput, currencyParent].forEach { primaryRow.addSubview($0) }
        dollarParent.pinToSuperview(edges: [.vertical, .leading])
        currencyParent.pinToSuperview(edges: [.vertical, .trailing])
        amountInput.centerToSuperview(axis: .horizontal).pinToSuperview(edges: .vertical)
        NSLayoutConstraint.activate([
            amountInput.leadingAnchor.constraint(equalTo: dollarParent.trailingAnchor, constant: 6),
            currencyParent.leadingAnchor.constraint(equalTo: amountInput.trailingAnchor, constant: 6)
        ])
        
        let secondaryRow = UIStackView([smallAmountLabel, ThemeableImageView(image: UIImage(named: "exchange")).setTheme { $0.tintColor = .accent }])
        secondaryRow.spacing = 8
        secondaryRow.alignment = .center
        
        addArrangedSubview(primaryRow)        
        
        axis = .vertical
        spacing = 2
        alignment = .center
        
//        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        
        Publishers.CombineLatest($isBitcoinPrimary, $balance).sink { [weak self] _, _ in
            self?.updateLabels()
        }
        .store(in: &cancellables)
    }
    
    func updateLabels() {
        accessoryView.decimalButton.isHidden = isBitcoinPrimary
        large$Label.superview?.isHidden = isBitcoinPrimary
        largeCurrencyLabel.text = isBitcoinPrimary ? "sats" : "USD"
        
        let usdAmount = Double(balance).satToUSD
        let usdString = usdAmount.localized()
        
        if isBitcoinPrimary {
            if amountInput.text?.hasPrefix(balance.localized()) != true {
                amountInput.text = balance.localized()
            }
            smallAmountLabel.text = "$\(usdString) USD"
        } else {
            if amountInput.text?.hasPrefix(usdString) != true {
                amountInput.text = usdString
            }
            smallAmountLabel.text = "\(balance.localized()) sats"
        }
    }
    
    @objc func tapped() {
        isBitcoinPrimary.toggle()
    }
}

final class BalanceInputAccessoryView: UIView, Themeable {
    let groupingButton = UIButton()
    let decimalButton = UIButton()
    let doneButton = UIButton()
    
    init() {
        super.init(frame: .init(origin: .zero, size: .init(width: 100, height: 44)))
        
        let actionStack = UIStackView([UIView()])
        
        let formatter = NumberFormatter()
        
        if let groupingSeparator = formatter.groupingSeparator {
            groupingButton.titleLabel?.font = .appFont(withSize: 18, weight: .regular)
            groupingButton.setTitle(groupingSeparator, for: .normal)
            
            //actionStack.addArrangedSubview(groupingButton)
        }
        
        if let decimalSeparator = formatter.decimalSeparator {
            decimalButton.titleLabel?.font = .appFont(withSize: 18, weight: .regular)
            decimalButton.setTitle(decimalSeparator, for: .normal)
            
            actionStack.addArrangedSubview(decimalButton)
        }
        
        doneButton.titleLabel?.font = .appFont(withSize: 18, weight: .regular)
        doneButton.setTitle("Done", for: .normal)
        actionStack.addArrangedSubview(doneButton)
        
        addSubview(actionStack)
        actionStack.pinToSuperview(edges: .horizontal, padding: 20).centerToSuperview(axis: .vertical)
        doneButton.constrainToSize(width: 64)
        
        actionStack.alignment = .center
        actionStack.spacing = 8
        
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        backgroundColor = .background3
        
        [groupingButton, decimalButton, doneButton].forEach {
            $0.setTitleColor(.foreground, for: .normal)
            $0.backgroundColor = .background4
            $0.layer.cornerRadius = 8
        }
    }
}
