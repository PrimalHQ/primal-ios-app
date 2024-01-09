//
//  WalletNavView.swift
//  Primal
//
//  Created by Pavle Stevanović on 13.10.23..
//

import Combine
import UIKit

final class WalletNavView: UIView, Themeable{
    let balanceConversionView = SmallBalanceConversionView()
    let send = ThemeableButton().constrainToSize(48).setTheme {
        $0.backgroundColor = .background3
        $0.tintColor = .foreground
    }
    let scan = ThemeableButton().constrainToSize(48).setTheme {
        $0.backgroundColor = .background3
        $0.tintColor = .foreground
    }
    let receive = ThemeableButton().constrainToSize(48).setTheme {
        $0.backgroundColor = .background3
        $0.tintColor = .foreground
    }
        
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        super.init(frame: .zero)
        
        updateTheme()
        
        send.setImage(LargeWalletButton.Variant.send.icon?.scalePreservingAspectRatio(size: 22).withRenderingMode(.alwaysTemplate), for: .normal)
        scan.setImage(LargeWalletButton.Variant.scan.icon?.scalePreservingAspectRatio(size: 22).withRenderingMode(.alwaysTemplate), for: .normal)
        receive.setImage(LargeWalletButton.Variant.receive.icon?.scalePreservingAspectRatio(size: 22).withRenderingMode(.alwaysTemplate), for: .normal)
        
        [send, scan, receive].forEach {
            $0.layer.cornerRadius = 24
        }
        
        let hStack = UIStackView([balanceConversionView, UIView(), send, scan, receive])
        hStack.spacing = 6
        
        addSubview(hStack)
        hStack.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .top, padding: 18).pinToSuperview(edges: .bottom, padding: 16)
        
        WalletManager.instance.$balance.receive(on: DispatchQueue.main).sink { [weak self] balance in
            self?.balanceConversionView.balance = balance
        }
        .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        backgroundColor = .background
    }
}

final class SmallBalanceConversionView: LargeBalanceConversionView {
    override init(showWalletBalance: Bool = true, showSecondaryRow: Bool = false) {
        super.init(showWalletBalance: showWalletBalance, showSecondaryRow: showSecondaryRow)
        
        large$Label.font = .appFont(withSize: 22, weight: .medium)
        largeAmountLabel.font = .appFont(withSize: 28, weight: .bold)
        largeCurrencyLabel.font = .appFont(withSize: 16, weight: .medium)
        
        largeAmountLabel.adjustsFontSizeToFitWidth = true
        
        transform = .init(translationX: 0, y: 10)
        
        roundingStyle = .twoDecimals
    }
    
    override var labelOffset: CGFloat { 10 }
    
    override var rowSpacing: CGFloat { 4 }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
