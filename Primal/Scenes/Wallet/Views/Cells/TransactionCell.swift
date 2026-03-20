//
//  TransactionCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.10.23..
//

import UIKit
import PrimalShared
import FLAnimatedImage
import Combine

extension UIColor {
    static var receiveMoney = UIColor(rgb: 0x2CA85E)
    static var sendMoney = UIColor(rgb: 0xCC331E)
}

protocol TransactionCellDelegate: AnyObject {
    func transactionCellDidTapAvatar(_ cell: TransactionCell)
}

final class TransactionCell: UITableViewCell, Themeable {
    
    let profileImage = UserImageView(height: 44)
    private let timeIcon = UIImageView(image: UIImage(named: "walletTimeIcon"))
    
    let nameLabel = UILabel()
    private let separator = UIView().constrainToSize(width: 1, height: 18)
    private let timeLabel = UILabel()
    let messageLabel = UILabel()
    
    let amountLabel = UILabel()
    private let currencyLabel = UILabel()
    
    private let arrowIcon = UIImageView(image: UIImage(named: "income"))
    
    private let coverView = UIView()
    
    weak var delegate: TransactionCellDelegate?

    private var profileCancellable: AnyCancellable?

    var wasPulsing = false
    var oldProfileId = ""
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    var oldWasBtc: Bool?
    func setup(with transaction: PrimalShared.Transaction, showBTC: Bool) {
        profileCancellable = nil
        let isDeposit = transaction.type == .deposit
        var isZap = false
        
        let otherUserProfile: PrimalShared.ProfileData? = {
            if let zap = transaction as? Transaction.Zap { return zap.otherUserProfile }
            if let lightning = transaction as? Transaction.Lightning { return lightning.otherUserProfile }
            return nil
        }()

        if let user = otherUserProfile {
            if oldProfileId != user.profileId {
                profileImage.setSharedUserImage(user)
                oldProfileId = user.profileId
            }
            profileImage.contentMode = .scaleAspectFill
            nameLabel.text = user.firstIdentifier
            if !user.hasDisplayName {
                profileCancellable = DatabaseManager.instance.getProfilePublisher(user.profileId)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] parsedUser in
                        self?.nameLabel.text = parsedUser.data.firstIdentifier
                    })
            }
            isZap = transaction is Transaction.Zap
        } else if let onchain = transaction as? Transaction.OnChain {
            oldProfileId = ""
            profileImage.image = UIImage(named: "onchainPayment")
            profileImage.contentMode = .scaleAspectFit
            nameLabel.text = isDeposit ? "Received on-chain" : "Sent on-chain"
        } else {
            oldProfileId = ""
            profileImage.image = .nonZapPayment
            profileImage.contentMode = .scaleAspectFit
            nameLabel.text = isDeposit ? "Received via Lightning" : "Sent via Lightning"
        }

        if let completedAt = transaction.completedAt {
            timeIcon.isHidden = true
            timeLabel.text = Date(timeIntervalSince1970: TimeInterval(truncating: completedAt)).timeAgoDisplay()
            coverView.alpha = 0
            
            wasPulsing = false
        } else {
            timeIcon.isHidden = false
            timeLabel.text = "Pending"
            
            if !wasPulsing {
                wasPulsing = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4)) {
                    if self.wasPulsing {
                        self.wasPulsing = false
                    }
                }
                
                coverView.alpha = 0
                UIView.animate(withDuration: 1, delay: 0, options: [.autoreverse, .repeat]) {
                    self.coverView.alpha = 0.6
                }
            }
        }

        arrowIcon.transform = isDeposit ? .identity : .init(rotationAngle: .pi)
        arrowIcon.tintColor = isDeposit ? .receiveMoney : .sendMoney
        
        let isEmpty = !(transaction.note?.isEmpty == false)
        switch (isEmpty, isZap) {
        case (false, _):
            messageLabel.text = transaction.note
        case (true, true):
            messageLabel.text = isDeposit ? "Zap received" : "Zap sent"
        case (true, false):
            messageLabel.text = isDeposit ? "Payment received" : "Payment sent"
        }
        
        let btcAmount = transaction.amountInBtc
        
        if showBTC {
            amountLabel.text = abs(btcAmount * .BTC_TO_SAT).localized()
            currencyLabel.text = "sats"
        } else {
            let usdAmount = Double(btcAmount * .BTC_TO_USD)
            amountLabel.text = "$\(abs(usdAmount).nDecimalPoints(n: 2))"
            currencyLabel.text = "USD"
        }
        
        oldWasBtc = showBTC
        
        updateTheme()
    }
    
    func updateTheme() {
        separator.backgroundColor = .foreground5
        timeLabel.textColor = .foreground5
        messageLabel.textColor = .foreground3
        nameLabel.textColor = .foreground
        
        amountLabel.textColor = .foreground
        currencyLabel.textColor = .foreground5
        
        coverView.backgroundColor = .background
        
        contentView.backgroundColor = .clear
        backgroundColor = .clear
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImage.alpha = 1
        nameLabel.alpha = 1
        messageLabel.alpha = 1
        amountLabel.alpha = 1
    }
}

private extension TransactionCell {
    func setup() {
        selectionStyle = .none
        layer.masksToBounds = false
                
        let nameStack = UIStackView([nameLabel, separator, timeLabel, UIView()])
        nameStack.spacing = 8
        
        let firstVStack = UIStackView(axis: .vertical, [nameStack, messageLabel])
        let secondVStack = UIStackView(axis: .vertical, [amountLabel, currencyLabel])
        secondVStack.alignment = .trailing
        secondVStack.transform = .init(translationX: 0, y: -1)
        
        messageLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        timeLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        currencyLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        arrowIcon.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        let thirdStack = UIView()
        thirdStack.addSubview(arrowIcon)
        arrowIcon.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, padding: 4)
        
        let mainStack = UIStackView([profileImage, SpacerView(width: 8, priority: .required), firstVStack, secondVStack, SpacerView(width: 5), thirdStack])
        mainStack.alignment = .center
        mainStack.spacing = 2
        thirdStack.pin(to: secondVStack, edges: .vertical)
        
        contentView.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .vertical, padding: 12)
        
        contentView.addSubview(timeIcon)
        timeIcon.pin(to: profileImage, edges: [.bottom, .trailing], padding: -2)
        
        contentView.addSubview(coverView)
        coverView.pinToSuperview()
        coverView.alpha = 0
        coverView.isUserInteractionEnabled = false
        
        nameLabel.font = .appFont(withSize: 18, weight: .bold)
        timeLabel.font = .appFont(withSize: 16, weight: .regular)
        messageLabel.font = .appFont(withSize: 16, weight: .regular)
        amountLabel.font = .appFont(withSize: 18, weight: .bold)
        currencyLabel.font = .appFont(withSize: 14, weight: .regular)
        
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileTapped)))
        profileImage.showLivePill = false
    }
    
    @objc func profileTapped() {
        delegate?.transactionCellDidTapAvatar(self)
    }
}
