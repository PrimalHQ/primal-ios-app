//
//  LargeBalanceConversionView.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.10.23..
//

import Combine
import UIKit

class LargeBalanceConversionView: UIStackView, Themeable {
    @Published var isBitcoinPrimary = true
    @Published var balance: Int = 0
    
    let largeAmountLabel = UILabel()
    let smallAmountLabel = UILabel()
    
    let largeCurrencyLabel = UILabel()
    let large$Label = UILabel()
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var labelOffset: CGFloat { 8 }
    
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
        
        large$Label.text = "$"
        large$Label.font = .appFont(withSize: 28, weight: .medium)
        largeAmountLabel.font = .appFont(withSize: 48, weight: .bold)
        largeCurrencyLabel.font = .appFont(withSize: 16, weight: .medium)
        
        smallAmountLabel.font = .appFont(withSize: 14, weight: .medium)
    }
    
    func setupLayout() {
        let dollarParent = UIView()
        let currencyParent = UIView()
        
        dollarParent.addSubview(large$Label)
        large$Label.pinToSuperview(edges: .top, padding: labelOffset).pinToSuperview(edges: .horizontal)
        
        currencyParent.addSubview(largeCurrencyLabel)
        largeCurrencyLabel.pinToSuperview(edges: .bottom, padding: labelOffset).pinToSuperview(edges: .horizontal)
        
        let primaryRow = UIStackView([dollarParent, largeAmountLabel, currencyParent])
        primaryRow.spacing = 6
        
        let secondaryRow = UIStackView([smallAmountLabel, ThemeableImageView(image: UIImage(named: "exchange")).setTheme { $0.tintColor = .accent }])
        secondaryRow.spacing = 8
        secondaryRow.alignment = .center
        secondaryRow.isHidden = true
        
        addArrangedSubview(primaryRow)
        addArrangedSubview(secondaryRow)
        
        axis = .vertical
        spacing = 2
        alignment = .center
        
//        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        
        Publishers.CombineLatest($isBitcoinPrimary, $balance).receive(on: DispatchQueue.main).sink { [weak self] _, _ in
            self?.updateLabels()
        }
        .store(in: &cancellables)
    }
    
    func updateLabels() {
        large$Label.superview?.isHidden = isBitcoinPrimary
        largeCurrencyLabel.text = isBitcoinPrimary ? "sats" : "USD"
        
        let usdAmount = Double(WalletManager.instance.balance) * .SAT_TO_USD
        let usdString = usdAmount.localized()
        
        if isBitcoinPrimary {
            largeAmountLabel.text = WalletManager.instance.balance.localized()
            smallAmountLabel.text = "$\(usdString) USD"
        } else {
            largeAmountLabel.text = usdString
            smallAmountLabel.text = "\(WalletManager.instance.balance.localized()) sats"
        }
    }
    
    @objc func tapped() {
        isBitcoinPrimary.toggle()
    }
}
