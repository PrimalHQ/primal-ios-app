//
//  WalletNavView.swift
//  Primal
//
//  Created by Pavle Stevanović on 13.10.23..
//

import Combine
import UIKit

final class WalletNavView: UIView, Themeable {
    // MARK: - Public
    var sendPressedEvent = PassthroughSubject<UIControl, Never>()
    var scanPressedEvent = PassthroughSubject<UIControl, Never>()
    var receivePressedEvent = PassthroughSubject<UIControl, Never>()
    
    @Published var shouldExpand: Bool = true
    
    let expandedHeight: CGFloat = 295
    let tightenedHeight: CGFloat = 82
    
    let blockerView = UIView()
    
    // MARK: - Private
    let balanceConversionView = SmallBalanceConversionView()
    private let send = ThemeableButton().constrainToSize(48).setTheme {
        $0.backgroundColor = .background3
        $0.tintColor = .foreground
    }
    private let scan = ThemeableButton().constrainToSize(48).setTheme {
        $0.backgroundColor = .background3
        $0.tintColor = .foreground
    }
    private let receive = ThemeableButton().constrainToSize(48).setTheme {
        $0.backgroundColor = .background3
        $0.tintColor = .foreground
    }
    
    private lazy var smallButtonStack = UIStackView([send, scan, receive])
    
    private lazy var smallView = UIStackView([balanceConversionView, UIView(), smallButtonStack])
    let largeView = WalletInfoLargeView()
        
    private var cancellables: Set<AnyCancellable> = []
    
    private var heightConstraint: NSLayoutConstraint?
    
    private var oldAnimViews: [UIView?] = []
    
    @Published private(set) var isAnimating = false
    @Published private var isExpanded: Bool = true
    
    init() {
        super.init(frame: .zero)
        
        updateTheme()
        
        send.setImage(LargeWalletButton.Variant.send.smallIcon, for: .normal)
        scan.setImage(LargeWalletButton.Variant.scan.smallIcon, for: .normal)
        receive.setImage(LargeWalletButton.Variant.receive.smallIcon, for: .normal)
        smallButtonStack.spacing = 6
        
        [send, scan, receive].forEach {
            $0.layer.cornerRadius = 24
        }
        
        addSubview(smallView)
        smallView.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .top, padding: 18)
        smallView.isHidden = true
        
        addSubview(largeView)
        largeView.pinToSuperview(edges: [.horizontal, .top])
        
        heightConstraint = heightAnchor.constraint(equalToConstant: expandedHeight)
        heightConstraint?.isActive = true
        
        balanceConversionView.isBitcoinPrimary = WalletManager.instance.isBitcoinPrimary
        largeView.balanceConversionView.isBitcoinPrimary = WalletManager.instance.isBitcoinPrimary
        
        balanceConversionView.$isBitcoinPrimary.receive(on: DispatchQueue.main).sink { [weak self] isPrimary in
            if self?.largeView.balanceConversionView.isBitcoinPrimary != isPrimary {
                self?.largeView.balanceConversionView.isBitcoinPrimary = isPrimary
            }
        }
        .store(in: &cancellables)
        
        largeView.balanceConversionView.$isBitcoinPrimary.receive(on: DispatchQueue.main).sink { [weak self] isPrimary in
            if self?.balanceConversionView.isBitcoinPrimary != isPrimary {
                self?.balanceConversionView.isBitcoinPrimary = isPrimary
            }
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest3($shouldExpand, $isExpanded, $isAnimating)
            .filter { shouldE, isE, isAnimating in !isAnimating && shouldE != isE }
            .map { shouldE, _, _ in shouldE }
            .sink { [weak self] shouldE in
                self?.animateExpansion(shouldE)
            }
            .store(in: &cancellables)
        
        [send, largeView.send].forEach { button in
            button.addAction(.init(handler: { [weak self] _ in
                self?.sendPressedEvent.send(button)
            }), for: .touchUpInside)
        }
        
        [scan, largeView.scan].forEach { button in
            button.addAction(.init(handler: { [weak self] _ in
                self?.scanPressedEvent.send(button)
            }), for: .touchUpInside)
        }
        
        [receive, largeView.receive].forEach { button in
            button.addAction(.init(handler: { [weak self] _ in
                self?.receivePressedEvent.send(button)
            }), for: .touchUpInside)
        }
        
        addSubview(blockerView)
        blockerView.pinToSuperview()
        blockerView.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        backgroundColor = .background
        
        blockerView.backgroundColor = .background.withAlphaComponent(0.5)
    }
    
    func animateExpansion(_ shouldExpand: Bool) {
        // Prepare
        smallView.isHidden = true
        largeView.isHidden = false

        setToDefaults()
        
        heightConstraint?.constant = shouldExpand ? expandedHeight : tightenedHeight
        
        let actionTranslation = largeView.scan.iconView.centerDistanceVectorToView(scan)
        
        // Animate
        UIView.animate(withDuration: 6 / 30) {
            [self.largeView.scan, self.largeView.send, self.largeView.receive].forEach {
                $0.titleLabel.alpha = shouldExpand ? 1 : 0
            }
        }
        
        isAnimating = true
        
        if shouldExpand {
            oldAnimViews = [
                balanceConversionView.largeAmountLabel.animateTransitionTo(largeView.balanceConversionView.largeAmountLabel, duration: 13 / 30, in: self),
                balanceConversionView.largeCurrencyLabel.animateTransitionTo(largeView.balanceConversionView.largeCurrencyLabel, duration: 13 / 30, in: self),
            ]
            if !balanceConversionView.isBitcoinPrimary {
                oldAnimViews.append(
                    balanceConversionView.large$Label.animateTransitionTo(largeView.balanceConversionView.large$Label, duration: 13 / 30, in: self)
                )
            }
        } else {
            oldAnimViews = [
                largeView.balanceConversionView.largeAmountLabel.animateTransitionTo(balanceConversionView.largeAmountLabel, duration: 13 / 30, in: self),
                largeView.balanceConversionView.largeCurrencyLabel.animateTransitionTo(balanceConversionView.largeCurrencyLabel, duration: 13 / 30, in: self),
                
                largeView.send.iconView.superview?.animateViewTo(send, duration: 13 / 30, in: self),
                largeView.scan.iconView.superview?.animateViewTo(scan, duration: 13 / 30, in: self),
                largeView.receive.iconView.superview?.animateViewTo(receive, duration: 13 / 30, in: self),
                
                largeView.send.iconView.animateTransitionTo(send.imageView, duration: 13 / 30, in: self),
                largeView.scan.iconView.animateTransitionTo(scan.imageView, duration: 13 / 30, in: self),
                largeView.receive.iconView.animateTransitionTo(receive.imageView, duration: 13 / 30, in: self)
            ]
            
            if !balanceConversionView.isBitcoinPrimary {
                oldAnimViews.append(
                    largeView.balanceConversionView.large$Label.animateTransitionTo(balanceConversionView.large$Label, duration: 13 / 30, in: self)
                )
            }
        }
        
        
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(.easeInOutQuart)
        
        UIView.animate(withDuration: 13 / 30) {
            let scale: CGFloat = 45 / 80
            
            self.largeView.actionStack.transform = shouldExpand ? .identity : .init(translationX: actionTranslation.x, y: actionTranslation.y - 7).scaledBy(x: scale, y: scale)
            
            self.superview?.layoutIfNeeded()
        } completion: { completed in
            self.smallView.isHidden = shouldExpand
            self.largeView.isHidden = !shouldExpand
            self.setToDefaults()
            self.isExpanded = shouldExpand
            self.isAnimating = false
        }
        
        CATransaction.commit()
    }
    
    func setToDefaults() {
        [
            balanceConversionView.largeAmountLabel, balanceConversionView.largeCurrencyLabel, balanceConversionView.large$Label,
            largeView.balanceConversionView.largeAmountLabel, largeView.balanceConversionView.largeCurrencyLabel, largeView.balanceConversionView.large$Label,
            largeView.send.iconView, largeView.scan.iconView, largeView.receive.iconView, send, scan, receive,
            largeView.send.iconView.superview, largeView.scan.iconView.superview, largeView.receive.iconView.superview
        ].forEach { $0?.alpha = 1 }
        
        oldAnimViews.forEach { $0?.removeFromSuperview() }
    }
}

final class SmallBalanceConversionView: LargeBalanceConversionView {
    override init(showWalletBalance: Bool = true, showSecondaryRow: Bool = false) {
        super.init(showWalletBalance: showWalletBalance, showSecondaryRow: showSecondaryRow)
        
        large$Label.font = .appFont(withSize: 22, weight: .light)
        largeAmountLabel.font = .appFont(withSize: 28, weight: .bold)
        largeCurrencyLabel.font = .appFont(withSize: 16, weight: .regular)
        
        largeAmountLabel.adjustsFontSizeToFitWidth = true
        
        roundingStyle = .twoDecimals
        
        guard let dollarParent = large$Label.superview, let currencyParent = largeCurrencyLabel.superview, dollarParent != currencyParent else { return }
        let stack = UIStackView([dollarParent, largeAmountLabel, currencyParent])
        primaryRow.addSubview(stack)
        stack
            .pinToSuperview(edges: .horizontal)
            .pinToSuperview(edges: .bottom, padding: -10)
            .pinToSuperview(edges: .top, padding: 20)
        stack.spacing = 4
    }
    
    override var labelOffset: CGFloat { 4 }
    
    override var rowSpacing: CGFloat { 4 }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
