//
//  ChatInvoiceCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 15.4.24..
//

import UIKit
import Nantes
import SafariServices

extension UIButton.Configuration {
    static func payInvoiceInvertedButton() -> UIButton.Configuration {
        var configuration = UIButton.Configuration.borderless()
        configuration.attributedTitle = .init("Pay", attributes: AttributeContainer([
            .font: UIFont.appFont(withSize: 16, weight: .semibold)
        ]))
        configuration.baseForegroundColor = .accent
        configuration.background.backgroundColor = .white
        configuration.cornerStyle = .capsule
        return configuration
    }
}

class ChatInvoiceCell: ChatMessageCell {
    let invoiceView = LightningInvoiceView()
    
    public let copyButton = UIButton(configuration: .simpleImage(UIImage(named: "copyInvoice")))
    public let payButton = UIButton(configuration: .payInvoiceButton()).constrainToSize(width: 80, height: 36)
    
    private let lightningIcon = UIImageView(image: UIImage(named: "invoiceLightning")?.withRenderingMode(.alwaysTemplate))
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let amountLabel = UILabel()
    private let expireLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func setupWith(message: ProcessedMessage, roundSide: Bool) {
        cachedIsMine = message.user.isCurrentUser
        
        super.setupWith(message: message, roundSide: roundSide)
        
        guard case .invoice(let invoice) = message.message else { return }
        updateForInvoice(invoice)
    }
    
    var cachedAmount: UInt64?
    var cachedIsMine: Bool = true
    func updateForInvoice(_ invoice: Invoice) {
        descriptionLabel.text = invoice.description
        descriptionLabel.isHidden = descriptionLabel.text?.isEmpty != false
        
        if let amount = invoice.amount {
            let satAmount = amount / 1000
            cachedAmount = satAmount
            amountLabel.isHidden = false
            amountLabel.attributedText = amountString(satAmount)
        } else {
            amountLabel.isHidden = true
        }
        
        expireLabel.text = invoice.expirationText
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        titleLabel.textColor = cachedIsMine ? .white : .foreground
        descriptionLabel.textColor = cachedIsMine ? .white : .foreground
        expireLabel.textColor = cachedIsMine ? .white :.foreground3
        
        if let cachedAmount {
            amountLabel.attributedText = amountString(cachedAmount)
        }
        
        payButton.configuration = cachedIsMine ? .payInvoiceInvertedButton() : .payInvoiceButton()
        copyButton.tintColor = cachedIsMine ? .white : .foreground3
        
        lightningIcon.tintColor = cachedIsMine ? .white : .init(rgb: 0xFA9011)
    }
}

private extension ChatInvoiceCell {
    func setup() {
        let firstRow = UIStackView([lightningIcon, titleLabel, UIView(), copyButton])
        firstRow.alignment = .center
        firstRow.spacing = 6
        
        titleLabel.text = "Lightning Invoice"
        titleLabel.font = .appFont(withSize: 15, weight: .bold)
        
        descriptionLabel.font = .appFont(withSize: 15, weight: .regular)
        expireLabel.font = .appFont(withSize: 15, weight: .regular)
        
        amountLabel.adjustsFontSizeToFitWidth = true
        
        let lastRow = UIStackView([expireLabel, payButton])
        lastRow.alignment = .bottom
        lastRow.spacing = 12
        
        let mainStack = UIStackView(axis: .vertical, [firstRow, descriptionLabel, amountLabel, lastRow])
        
        labelBackground.addSubview(mainStack)
        mainStack.pinToSuperview(padding: 12)
        mainStack.spacing = 8
        
        label.removeFromSuperview()
        
        copyButton.addAction(.init(handler: { [unowned self] _ in
            delegate?.copyInvoiceForMessageCell(self)
        }), for: .touchUpInside)
        payButton.addAction(.init(handler: { [unowned self] _ in
            delegate?.payInvoiceForMessageCell(self)
        }), for: .touchUpInside)
    }
    
    func amountString(_ sats: UInt64) -> NSAttributedString {
        let st = NSMutableAttributedString(string: "\(sats.localized()) sats ", attributes: [
            .font: UIFont.appFont(withSize: 24, weight: .semibold),
            .foregroundColor: cachedIsMine ? UIColor.white : UIColor.foreground
        ])
        
        st.append(.init(string: "$\(sats.satsToUsdAmountString(.twoDecimals))", attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .foregroundColor: cachedIsMine ? UIColor.white : UIColor.foreground3
        ]))
        
        return st
    }
}
