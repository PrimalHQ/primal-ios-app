//
//  PremiumLegendPayController.swift
//  Primal
//
//  Created by Pavle Stevanović on 12.11.24..
//

import Combine
import FLAnimatedImage
import UIKit
import GenericJSON

class PremiumLegendPayController: UIViewController {
    let amount: Int
    
    var invoice: String?
    
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(name: String, amount: Int) {
        self.amount = amount
        super.init(nibName: nil, bundle: nil)
        
        guard let object = NostrObject.purchasePrimalLegend(name: name, amount: amount) else { return }
    
        SocketRequest(name: "membership_purchase_product", payload: ["event_from_user": object.toJSON()], connection: .wallet)
            .publisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard
                    let self,
                    let contentJson: [String: JSON] = result.events.first?["content"]?.stringValue?.decode(),
                    let qrCode = contentJson["qr_code"]?.stringValue
                else { return }
                
                invoice = qrCode
                
                qrCodeImageView.image = .createQRCode(qrCode, dimension: 231, logo: UIImage(named: "qr-btc"))
                
                UIView.animate(withDuration: 0.3) {
                    self.qrCodeImageView.superview?.alpha = 1
                }
            }
            .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    let balanceView = LargeBalanceConversionView(showWalletBalance: false, showSecondaryRow: true)
    let qrCodeImageView = UIImageView().constrainToSize(231)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let action = LargeRoundedButton(title: "Copy Invoice")
        
        let imageBackground = UIView()
        imageBackground.addSubview(qrCodeImageView)
        qrCodeImageView.pinToSuperview(padding: 8)
        imageBackground.backgroundColor = .white
        imageBackground.layer.cornerRadius = 12
        imageBackground.alpha = 0
        
        let imageParent = UIView()
        imageParent.addSubview(imageBackground)
        imageBackground.pinToSuperview(edges: .vertical).centerToSuperview(axis: .horizontal)
        
        let infoStack = UIStackView(axis: .vertical, [
            UILabel("Pay this on-chain invoice to", color: .foreground3, font: .appFont(withSize: 16, weight: .regular)),
            UILabel("complete your purchase.", color: .foreground3, font: .appFont(withSize: 16, weight: .regular)),
            UILabel("Your legendary status will be", color: .foreground3, font: .appFont(withSize: 16, weight: .regular)),
            UILabel("active immediately.", color: .foreground3, font: .appFont(withSize: 16, weight: .regular)),
        ])
        infoStack.alignment = .center
        infoStack.spacing = 4
        
        let mainStack = UIStackView(axis: .vertical, [imageParent, balanceView, infoStack, action])
        mainStack.distribution = .equalSpacing
        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .top, padding: 44, safeArea: true)
            .pinToSuperview(edges: .horizontal, padding: 35)
            .pinToSuperview(edges: .bottom, padding: 20, safeArea: true)
        
        balanceView.largeAmountLabel.centerToView(view, axis: .horizontal)
        
        title = "On-Chain Payment"
        view.backgroundColor = .background
        navigationItem.leftBarButtonItem = customBackButton
        
        action.addAction(.init(handler: { [weak self] _ in
            guard let invoice = self?.invoice else { return }
            UIPasteboard.general.string = invoice
            RootViewController.instance.showToast("Copied")
        }), for: .touchUpInside)
        
        balanceView.balance = amount
        balanceView.animateBalanceChange = false
    }
}

