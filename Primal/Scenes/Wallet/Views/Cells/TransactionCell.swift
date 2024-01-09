//
//  TransactionCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.10.23..
//

import UIKit
import FLAnimatedImage

extension UIColor {
    static var receiveMoney = UIColor(rgb: 0x2CA85E)
    static var sendMoney = UIColor(rgb: 0xCC331E)
}

protocol TransactionCellDelegate: AnyObject {
    func transactionCellDidTapAvatar(_ cell: TransactionCell)
}

final class TransactionCell: UITableViewCell, Themeable {
    
    private let profileImage = FLAnimatedImageView().constrainToSize(44)
    
    private let nameLabel = UILabel()
    private let separator = UIView().constrainToSize(width: 1, height: 18)
    private let timeLabel = UILabel()
    private let messageLabel = UILabel()
    
    private let amountLabel = UILabel()
    private let currencyLabel = UILabel()
    
    private let arrowIcon = UIImageView(image: UIImage(named: "income"))
    
    weak var delegate: TransactionCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
        } else {
            profileImage.kf.cancelDownloadTask()
            profileImage.image = UIImage(named: "nonZapPayment")
            profileImage.contentMode = .scaleAspectFit
            nameLabel.text = isDeposit ? "Received" : "Sent"
        }
        
        timeLabel.text = Date(timeIntervalSince1970: TimeInterval(transaction.0.created_at)).timeAgoDisplay()
        
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
            amountLabel.text = (btcAmount * .BTC_TO_SAT).localized()
            currencyLabel.text = "sats"
        } else {
            let usdAmount = Double(btcAmount * .BTC_TO_USD)
            
            let usdString = (usdAmount < 0 ? "-$" : "$") + abs(usdAmount).twoDecimalPoints()
            
            amountLabel.text = usdString
            currencyLabel.text = "USD"
        }
        
        updateTheme()
    }
    
    func updateTheme() {
        separator.backgroundColor = .foreground5
        timeLabel.textColor = .foreground5
        messageLabel.textColor = .foreground3
        nameLabel.textColor = .foreground
        
        amountLabel.textColor = .foreground
        currencyLabel.textColor = .foreground5
        
        contentView.backgroundColor = .background
    }
}

private extension TransactionCell {
    func setup() {
        selectionStyle = .none
        
        profileImage.layer.cornerRadius = 22
        profileImage.layer.masksToBounds = true
        profileImage.contentMode = .scaleAspectFill
                
        let nameStack = UIStackView([nameLabel, separator, timeLabel, UIView()])
        nameStack.spacing = 8
        
        let firstVStack = UIStackView(axis: .vertical, [nameStack, messageLabel])
        let secondVStack = UIStackView(axis: .vertical, [amountLabel, currencyLabel])
        secondVStack.alignment = .trailing
        secondVStack.transform = .init(translationX: 0, y: -1)
        
        messageLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        timeLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        let thirdStack = UIView()
        thirdStack.addSubview(arrowIcon)
        arrowIcon.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, padding: 4)
        
        let mainStack = UIStackView([profileImage, SpacerView(width: 8), firstVStack, secondVStack, SpacerView(width: 5), thirdStack])
        mainStack.alignment = .center
        mainStack.spacing = 2
        thirdStack.pin(to: secondVStack, edges: .vertical)
        
        contentView.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .vertical, padding: 12)
        
        nameLabel.font = .appFont(withSize: 18, weight: .bold)
        timeLabel.font = .appFont(withSize: 16, weight: .regular)
        messageLabel.font = .appFont(withSize: 16, weight: .regular)
        amountLabel.font = .appFont(withSize: 18, weight: .bold)
        currencyLabel.font = .appFont(withSize: 14, weight: .regular)
        
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileTapped)))
    }
    
    @objc func profileTapped() {
        delegate?.transactionCellDidTapAvatar(self)
    }
}
