//
//  LargeBalanceConversionView.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.10.23..
//

import Combine
import UIKit

enum RoundingStyle {
    case twoDecimals, removeZeros
}

class LargeBalanceConversionView: UIStackView, Themeable {
    @Published var isBitcoinPrimary = true
    @Published var balance: Int = 0
    
    let largeAmountLabel = UILabel()
    let smallAmountLabel = UILabel()
    
    let largeCurrencyLabel = UILabel()
    let large$Label = UILabel()
    
    let exchangeIcon = ThemeableImageView(image: UIImage(named: "exchange")).setTheme { $0.tintColor = .accent }
    
    let primaryRow = UIStackView()
    let secondaryRow = UIStackView()
    
    var animateReversed = true
    
    private var cancellables: Set<AnyCancellable> = []
    
    var roundingStyle: RoundingStyle = .removeZeros
    
    var isSettingFirstTime = true
    
    init(showWalletBalance: Bool = true, showSecondaryRow: Bool = false) {
        super.init(frame: .zero)
        setup()
        
        secondaryRow.isHidden = !showSecondaryRow
        
        if showWalletBalance {
            Publishers.Merge(
                WalletManager.instance.$balance.first(),
                WalletManager.instance.$balance.delay(for: 1.5, scheduler: RunLoop.main)
            )
            .receive(on: DispatchQueue.main)
            .assign(to: \.balance, onWeak: self)
            .store(in: &cancellables)
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
    
    var isAnimating = false
    var onAnimationEnd: (() -> ())?
    
    func setLargeLabel(_ text: String, animating: Bool) {
        if isAnimating {
            onAnimationEnd = { [weak self] in
                self?.setLargeLabel(text, animating: animating)
            }
            return
        }
        
        let oldText = largeAmountLabel.text ?? ""
        
        if oldText.isEmpty || !animating {
            largeAmountLabel.text = text
            return
        }
        
        if oldText == "0" && isSettingFirstTime {
            isSettingFirstTime = text == "0"
            largeAmountLabel.text = text
            return
        }
        
        isAnimating = true
        
        var views: [UIView] = []
        let attributedText = NSMutableAttributedString(string: text, attributes: largeLabelAttributes(.foreground))
        
        let newTextArray = text.enumerated().filter { $0.element.isNumber }
        var oldTextArray = oldText.enumerated().filter { $0.element.isNumber }
        
        while oldTextArray.count < newTextArray.count {
            oldTextArray.append((oldText.count - 1, " "))
        }
        
        var animationIndex: CGFloat = 1
        
        let oldCount = oldTextArray.count
        
        if oldCount > newTextArray.count {
            let list = oldTextArray.suffix(oldCount - newTextArray.count)
            for (index, _) in (animateReversed ? Array(list.reversed()) : Array(list)) {
                let oldChar = copyLabel(type: 1)
                oldChar.attributedText = attributedTextOneCharVisible(oldText, index)
                
                UIView.animate(withDuration: 0.1, delay: animationIndex * 0.1) {
                    oldChar.transform = .init(translationX: 0, y: 40)
                    oldChar.alpha = 0
                }
                
                animationIndex += 1
                views.append(oldChar)
            }
        }
        
        let list = zip(newTextArray, oldTextArray)
        for ((index, char), (oldIndex, oldChar)) in (animateReversed ? Array(list.reversed()) : Array(list)) {
            if char == oldChar { continue }
            
            attributedText.setAttributes(largeLabelAttributes(.clear), range: .init(location: index, length: 1))
            
            let oldCharLabel = copyLabel(type: 1)
            
            if oldChar != " " {
                oldCharLabel.attributedText = attributedTextOneCharVisible(oldText, oldIndex)
            }
            
            let newChar = copyLabel(type: 0)
            newChar.attributedText = attributedTextOneCharVisible(text, index)
            newChar.transform = .init(translationX: 0, y: -40)
            newChar.alpha = 0
            
            UIView.animate(withDuration: 0.1, delay: animationIndex * 0.1) {
                oldCharLabel.transform = .init(translationX: 0, y: 40)
                oldCharLabel.alpha = 0
                
                newChar.transform = .identity
                newChar.alpha = 1
            }
            
            animationIndex += 1
            views += [oldCharLabel, newChar]
        }
        
        largeAmountLabel.attributedText = attributedText
        
        if oldText.count != text.count {
            let translationX: CGFloat
            if abs(oldText.count - text.count) == 2 {
                translationX = CGFloat((text.count - oldText.count)) * 12.5
            } else if oldText.count > text.count {
                translationX = CGFloat(oldText.count - text.count) * -20
            } else {
                translationX = CGFloat(text.count - oldText.count) * 18
            }
            
            largeAmountLabel.transform = .init(translationX: translationX, y: 0)
            largeCurrencyLabel.transform = .init(translationX: -translationX / 2, y: 0)
            large$Label.transform = .init(translationX: translationX, y: 0)
            
            let oldLabel = copyLabel(type: 3)
            oldLabel.attributedText = NSAttributedString(string: oldText, attributes: largeLabelAttributes(.foreground))
            
            let normalLabel = copyLabel(type: 3)
            normalLabel.attributedText = attributedText
            largeAmountLabel.attributedText = NSAttributedString(string: text, attributes: largeLabelAttributes(.clear))
            normalLabel.alpha = 0
            
            views += [oldLabel, normalLabel]
            
            UIView.animate(withDuration: 0.2) { [self] in
                largeAmountLabel.transform = .identity
                largeCurrencyLabel.transform = .identity
                large$Label.transform = .identity
                oldLabel.alpha = 0
                normalLabel.alpha = 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(animationIndex + 1) * 100)) {
            views.forEach { $0.removeFromSuperview() }
            self.largeAmountLabel.text = text
            self.largeAmountLabel.textColor = .foreground
            self.isAnimating = false
            self.onAnimationEnd?()
            self.onAnimationEnd = nil
        }
    }
}

private extension LargeBalanceConversionView {
    func setup() {
        setupLayout()
        updateTheme()
        updateLabels(isBitcoinPrimary, balance)
        
        large$Label.text = "$"
        large$Label.font = .appFont(withSize: 28, weight: .light)
        largeAmountLabel.font = .appFont(withSize: 48, weight: .bold)
        largeCurrencyLabel.font = .appFont(withSize: 16, weight: .regular)
        
        smallAmountLabel.font = .appFont(withSize: 16, weight: .regular)
        
        largeAmountLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    func setupLayout() {
        let dollarParent = UIView()
        let currencyParent = UIView()
        
        dollarParent.addSubview(large$Label)
        large$Label.pinToSuperview(edges: .top, padding: labelOffset).pinToSuperview(edges: .horizontal)
        
        currencyParent.addSubview(largeCurrencyLabel)
        largeCurrencyLabel.pinToSuperview(edges: .bottom, padding: labelOffset).pinToSuperview(edges: .horizontal)
        
        [dollarParent, largeAmountLabel, currencyParent].forEach { primaryRow.addArrangedSubview($0) }
        primaryRow.spacing = rowSpacing
        primaryRow.clipsToBounds = false
        
        [smallAmountLabel, exchangeIcon].forEach { secondaryRow.addArrangedSubview($0) }
        secondaryRow.spacing = rowSpacing
        secondaryRow.alignment = .center
        
        addArrangedSubview(primaryRow)
        addArrangedSubview(secondaryRow)
        
        axis = .vertical
        spacing = 2
        alignment = .center
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        
        Publishers.CombineLatest($isBitcoinPrimary, $balance).sink { [weak self] isBitcoinPrimary, balance in
            self?.updateLabels(isBitcoinPrimary, balance)
        }
        .store(in: &cancellables)
    }
    
    func updateLabels(_ isBitcoinPrimary: Bool, _ balance: Int) {
        large$Label.superview?.isHidden = isBitcoinPrimary
        largeCurrencyLabel.text = isBitcoinPrimary ? "sats" : "USD"
        
        let shouldAnimate = isBitcoinPrimary == self.isBitcoinPrimary
        
        let usdAmount = balance.satsToUsdAmountString(roundingStyle)
        
        if isBitcoinPrimary {
            setLargeLabel(balance.localized(), animating: shouldAnimate)
            smallAmountLabel.text = "$\(usdAmount) USD"
        } else {
            setLargeLabel(usdAmount, animating: shouldAnimate)
            smallAmountLabel.text = "\(balance.localized()) sats"
        }
    }
    
    @objc func tapped() {
        if secondaryRow.isHidden {
            isBitcoinPrimary.toggle()
        } else {
            animateSwap()
        }
    }
    
    func animateSwap() {
        let views = [
            largeAmountLabel.animateColorTransitionTo(smallAmountLabel, duration: 0.2, in: self, forceHeight: true),
            largeCurrencyLabel.animateColorTransitionTo(smallAmountLabel, duration: 0.2, in: self, forceHeight: true),
            smallAmountLabel.animateColorTransitionTo(largeCurrencyLabel, duration: 0.2, in: self, forceHeight: true)
        ]
        
        (views.last as? UILabel)?.textAlignment = .right
        
        primaryRow.transform = .init(scaleX: 1 / 2.1, y: 1 / 2.1).translatedBy(x: 0, y: 80)
        
        smallAmountLabel.alpha = 0.01
        smallAmountLabel.transform = .init(scaleX: 2.1, y: 2.1).translatedBy(x: 0, y: -20)
        
        primaryRow.alpha = 0.01
        largeAmountLabel.alpha = 1
        largeCurrencyLabel.alpha = 1
        large$Label.alpha = 1
        
        UIView.animate(withDuration: 0.2) { [self] in
            views.forEach { $0?.alpha = 0 }
            
            self.isBitcoinPrimary.toggle()
            
            primaryRow.transform = .identity
            primaryRow.alpha = 1
            
            smallAmountLabel.transform = .identity
            smallAmountLabel.alpha = 1
            
            exchangeIcon.transform = .init(rotationAngle: -1 * .pi)
            
            layoutSubviews()
        } completion: { [self] _ in
            smallAmountLabel.alpha = 1
            exchangeIcon.transform = .identity
        }
    }
    
    func attributedTextOneCharVisible(_ text: String, _ charIndex: Int) -> NSAttributedString {
        let str = NSMutableAttributedString(string: text, attributes: largeLabelAttributes(.clear))
        str.setAttributes(largeLabelAttributes(.foreground), range: .init(location: charIndex, length: 1))
        return str
    }
    
    func smallLabelAttributes() -> [NSAttributedString.Key: Any] {
        [
            .font: smallAmountLabel.font ?? .appFont(withSize: 16, weight: .regular),
            .foregroundColor: smallAmountLabel.textColor ?? UIColor.foreground4
        ]
    }
    
    func largeLabelAttributes(_ color: UIColor) -> [NSAttributedString.Key: Any] {
        [
            .font: largeAmountLabel.font ?? .appFont(withSize: 48, weight: .bold),
            .foregroundColor: color
        ]
    }
    
    func copyLabel(type: Int) -> UILabel {
        let label = UILabel()
        if type == 0 {
            addSubview(label)
            label.pin(to: largeAmountLabel, edges: [.vertical, .trailing])
            label.layoutIfNeeded()
        } else if type == 1 {
            largeAmountLabel.addSubview(label)
            label.frame = largeAmountLabel.bounds
            label.textAlignment = .center
        } else if type == 2 {
            addSubview(label)
            label.frame = largeAmountLabel.superview?.convert(largeAmountLabel.frame, to: self) ?? .zero
            label.textAlignment = .right
        } else if type == 3 {
            largeAmountLabel.addSubview(label)
            label.frame = largeAmountLabel.bounds
            label.frame.size = .init(width: 400, height: label.frame.height)
        }
        return label
    }
}
