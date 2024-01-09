//
//  LargeBalanceConversionView.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.10.23..
//

import Combine
import UIKit

class LargeBalanceConversionView: UIStackView, Themeable {
    enum RoundingStyle {
        case twoDecimals, removeZeros
    }
    
    @Published var isBitcoinPrimary = true
    @Published var balance: Int = 0
    
    var balanceUSD: Double { Double(balance) * .SAT_TO_USD }
    
    let largeAmountLabel = UILabel()
    let smallAmountLabel = UILabel()
    
    let largeCurrencyLabel = UILabel()
    let large$Label = UILabel()
    
    let secondaryRow = UIStackView()
    
    private var cancellables: Set<AnyCancellable> = []
    
    var roundingStyle: RoundingStyle = .removeZeros
    
    init(showWalletBalance: Bool = true, showSecondaryRow: Bool = false) {
        super.init(frame: .zero)
        setup()
        
        secondaryRow.isHidden = !showSecondaryRow
        
        if showWalletBalance {
            WalletManager.instance.$balance.assign(to: \.balance, onWeak: self).store(in: &cancellables)
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var labelOffset: CGFloat { 8 }
    
    var rowSpacing: CGFloat { 6 }
    
    func updateTheme() {
        large$Label.textColor = .foreground4
        largeAmountLabel.textColor = .foreground
        largeCurrencyLabel.textColor = .foreground4
        smallAmountLabel.textColor = .foreground4
    }
}

private extension LargeBalanceConversionView {
    func setup() {
        setupLayout()
        updateTheme()
        updateLabels()
        
        large$Label.text = "$"
        large$Label.font = .appFont(withSize: 28, weight: .medium)
        largeAmountLabel.font = .appFont(withSize: 48, weight: .bold)
        largeCurrencyLabel.font = .appFont(withSize: 16, weight: .medium)
        
        smallAmountLabel.font = .appFont(withSize: 16, weight: .regular)
    }
    
    func setupLayout() {
        let dollarParent = UIView()
        let currencyParent = UIView()
        
        dollarParent.addSubview(large$Label)
        large$Label.pinToSuperview(edges: .top, padding: labelOffset).pinToSuperview(edges: .horizontal)
        
        currencyParent.addSubview(largeCurrencyLabel)
        largeCurrencyLabel.pinToSuperview(edges: .bottom, padding: labelOffset).pinToSuperview(edges: .horizontal)
        
        let primaryRow = UIStackView([dollarParent, largeAmountLabel, currencyParent])
        primaryRow.spacing = rowSpacing
        
        [smallAmountLabel, ThemeableImageView(image: UIImage(named: "exchange")).setTheme { $0.tintColor = .accent }].forEach { secondaryRow.addArrangedSubview($0) }
        secondaryRow.spacing = rowSpacing
        secondaryRow.alignment = .center
        
        addArrangedSubview(primaryRow)
        addArrangedSubview(secondaryRow)
        
        axis = .vertical
        spacing = 2
        alignment = .center
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        
        Publishers.CombineLatest($isBitcoinPrimary, $balance).receive(on: DispatchQueue.main).sink { [weak self] _, _ in
            self?.updateLabels()
        }
        .store(in: &cancellables)
    }
    
    func updateLabels() {
        large$Label.superview?.isHidden = isBitcoinPrimary
        largeCurrencyLabel.text = isBitcoinPrimary ? "sats" : "USD"
        
        let usdAmount = balanceUSD
        let usdString: String = {
            switch roundingStyle {
            case .twoDecimals:
                return usdAmount.twoDecimalPoints()
            case .removeZeros:
                return usdAmount.localized()
            }
        }()
        
        if isBitcoinPrimary {
            largeAmountLabel.text = balance.localized()
            smallAmountLabel.text = "$\(usdString) USD"
        } else {
            largeAmountLabel.text = usdString
            smallAmountLabel.text = "\(balance.localized()) sats"
        }
    }
    
    @objc func tapped() {
        isBitcoinPrimary.toggle()
    }
}
