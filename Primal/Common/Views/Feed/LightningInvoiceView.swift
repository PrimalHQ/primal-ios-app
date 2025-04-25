//
//  LightningInvoiceView.swift
//  Primal
//
//  Created by Pavle Stevanović on 15.4.24..
//

import UIKit

extension UIButton.Configuration {
    static func payInvoiceButton() -> UIButton.Configuration {
        var configuration = UIButton.Configuration.borderless()
        configuration.attributedTitle = .init("Pay", attributes: AttributeContainer([
            .font: UIFont.appFont(withSize: 16, weight: .semibold)
        ]))
        configuration.baseForegroundColor = .white
        configuration.background.backgroundColor = .accent
        configuration.cornerStyle = .capsule
        return configuration
    }
}

final class LightningInvoiceView: UIView, Themeable {
    public let copyButton = UIButton(configuration: .simpleImage(UIImage(named: "copyInvoice")))
    public let payButton = UIButton(configuration: .payInvoiceButton()).constrainToSize(width: 80, height: 36)
    
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let amountLabel = UILabel()
    private let expireLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    var cachedAmount: UInt64?
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
    
    func updateTheme() {
        titleLabel.textColor = .foreground
        descriptionLabel.textColor = .foreground
        expireLabel.textColor = .foreground3
        
        if let cachedAmount {
            amountLabel.attributedText = amountString(cachedAmount)
        }
        
        payButton.configuration = .payInvoiceButton()
        copyButton.tintColor = .foreground3
        
        backgroundColor = .background3
    }
}

private extension LightningInvoiceView {
    func amountString(_ sats: UInt64) -> NSAttributedString {
        let st = NSMutableAttributedString(string: "\(sats.localized()) sats ", attributes: [
            .font: UIFont.appFont(withSize: 24, weight: .semibold),
            .foregroundColor: UIColor.foreground
        ])
        
        st.append(.init(string: "$\(sats.satsToUsdAmountString(.twoDecimals))", attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .foregroundColor: UIColor.foreground3
        ]))
        
        return st
    }
    
    func setup() {
        let firstRow = UIStackView([UIImageView(image: UIImage(named: "invoiceLightning")), titleLabel, UIView(), copyButton])
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
        
        addSubview(mainStack)
        mainStack.pinToSuperview(padding: 12)
        mainStack.spacing = 8
        
        layer.cornerRadius = 8
        
        updateTheme()
    }
}

extension Invoice {
    var expirationText: String {
        let expirationDate = Date(timeIntervalSince1970: TimeInterval(created_at + expiry))
        if expirationDate > Date() {
            return "Expires: \(expirationDate.timeInFutureDisplayLong())"
        } else {
            return "Expired: \(expirationDate.timeAgoDisplayLong())"
        }
    }
}
