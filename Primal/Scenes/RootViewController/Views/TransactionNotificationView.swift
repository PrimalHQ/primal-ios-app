//
//  TransactionNotificationView.swift
//  Primal
//
//  Created by Pavle Stevanović on 5.2.24..
//

import UIKit
import FLAnimatedImage
import Lottie

final class TransactionNotificationView: UIView {
    private var animationBackgroundView = UIView()
    private let profileImage = FLAnimatedImageView().constrainToSize(44)
    
    private let nameLabel = UILabel()
    private let messageLabel = UILabel()
    
    private let amountLabel = UILabel()
    private let currencyLabel = UILabel()
    
    private let arrowIcon = UIImageView(image: UIImage(named: "income"))
    
    private let lottieView = LottieAnimationView(animation: AnimationType.notificationLightning.animation)
    private let flippedLottieView = LottieAnimationView(animation: AnimationType.notificationLightning.animation)
    
    weak var delegate: TransactionCellDelegate?
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    func setup(with transaction: (WalletTransaction, ParsedUser), showBTC: Bool) {
        let isDeposit = transaction.0.type == "DEPOSIT"
        
        if transaction.1.data.pubkey != IdentityManager.instance.userHexPubkey {
            profileImage.setUserImage(transaction.1)
            profileImage.contentMode = .scaleAspectFill
            nameLabel.text = (transaction.1).data.firstIdentifier
        } else if transaction.0.onchainAddress != nil {
            profileImage.kf.cancelDownloadTask()
            profileImage.image = UIImage(named: "onchainPayment")
            profileImage.contentMode = .scaleAspectFit
            nameLabel.text = "Bitcoin"
        } else {
            profileImage.kf.cancelDownloadTask()
            profileImage.image = UIImage(named: "nonZapPayment")
            profileImage.contentMode = .scaleAspectFit
            nameLabel.text = isDeposit ? "Received" : "Sent"
        }
        
        arrowIcon.transform = isDeposit ? .identity : .init(rotationAngle: .pi)
        arrowIcon.tintColor = isDeposit ? .receiveMoney : .sendMoney
        
        let isEmpty = !(transaction.0.note?.isEmpty == false)
        switch (isEmpty, transaction.0.is_zap) {
        case (false, _):
            messageLabel.text = transaction.0.note
        case (true, true):
            messageLabel.text = isDeposit ? "Zap received" : "Zap sent"
        case (true, false):
            messageLabel.text = isDeposit ? "Payment received" : "Payment sent"
        }
        
        let btcAmount = (Double(transaction.0.amount_btc) ?? 0)
        
        if showBTC {
            amountLabel.text = abs(btcAmount * .BTC_TO_SAT).localized()
            currencyLabel.text = "sats"
        } else {
            let usdAmount = Double(btcAmount * .BTC_TO_USD)
            
            let usdString = "$\(abs(usdAmount).twoDecimalPoints())"
            
            amountLabel.text = usdString
            currencyLabel.text = "USD"
        }
        
        animationBackgroundView.alpha = 1
        
        updateTheme()
    }
    
    func animate() {
        lottieView.play()
        
        UIView.animate(withDuration: 12 / 30) {
            self.animationBackgroundView.alpha = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(166)) {
            self.flippedLottieView.play()
        }
    }
    
    func updateTheme() {
        messageLabel.textColor = .foreground3
        nameLabel.textColor = .foreground
        
        amountLabel.textColor = .foreground
        currencyLabel.textColor = .foreground5
        
        animationBackgroundView.backgroundColor = Theme.current.isDarkTheme ? UIColor(rgb: 0x9D9D9D) : .white
        
        backgroundColor = .background3
    }
}

private extension TransactionNotificationView {
    func setup() {
        layer.cornerRadius = 8
        layer.masksToBounds = false
        clipsToBounds = false
        
        addSubview(animationBackgroundView)
        animationBackgroundView.pinToSuperview()
        animationBackgroundView.layer.cornerRadius = 8
        
        profileImage.layer.cornerRadius = 22
        profileImage.layer.masksToBounds = true
        profileImage.contentMode = .scaleAspectFill
        
        let firstVStack = UIStackView(axis: .vertical, [nameLabel, messageLabel])
        let secondVStack = UIStackView(axis: .vertical, [amountLabel, currencyLabel])
        secondVStack.alignment = .trailing
        secondVStack.transform = .init(translationX: 0, y: -1)
        
        messageLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        currencyLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        arrowIcon.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        let thirdStack = UIView()
        thirdStack.addSubview(arrowIcon)
        arrowIcon.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, padding: 4)
        
        let mainStack = UIStackView([profileImage, SpacerView(width: 6, priority: .required), firstVStack, secondVStack, SpacerView(width: 5), thirdStack])
        mainStack.alignment = .center
        mainStack.spacing = 2
        thirdStack.pin(to: secondVStack, edges: .vertical)
        
        addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 15).pinToSuperview(edges: .vertical, padding: 12)
        
        nameLabel.font = .appFont(withSize: 16, weight: .bold)
        messageLabel.font = .appFont(withSize: 14, weight: .regular)
        amountLabel.font = .appFont(withSize: 16, weight: .bold)
        currencyLabel.font = .appFont(withSize: 14, weight: .regular)
        
        addSubview(lottieView)
        lottieView.centerToSuperview()
        lottieView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.43 ).isActive = true
        lottieView.heightAnchor.constraint(equalTo: lottieView.widthAnchor, multiplier: 1 / 2.8).isActive = true
        
        addSubview(flippedLottieView)
        flippedLottieView.pin(to: lottieView)
        flippedLottieView.transform = .init(rotationAngle: .pi)
    }
}
