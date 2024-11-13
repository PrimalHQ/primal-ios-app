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

private struct PremiumLegendQuote: Codable {
    let membership_quote_id: String
    let amount_btc: String
    let qr_code: String
}

private struct MembershipPurchaseMonitorResponse: Codable {
    var completed_at: String?
    var created_at: String
    var requester_pubkey: String
    var receiver_pubkey: String
    var id: String
    var specification: String
}

class PremiumLegendPayController: UIViewController {
    var amount: Int
    
    var invoice: String?
    
    private var cancellables: Set<AnyCancellable> = []
    
    var trackPayment: ContinousConnection?
    
    var runOnce = true
    
    init(name: String, amount: Int) {
        self.amount = amount
        super.init(nibName: nil, bundle: nil)
        
        guard let object = NostrObject.purchasePrimalLegend(name: name, amount: amount) else { return }
    
        SocketRequest(name: "membership_purchase_product", payload: ["event_from_user": object.toJSON()], connection: .wallet)
            .publisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self, let quote: PremiumLegendQuote = result.events.first?["content"]?.stringValue?.decode() else { return }
                
                invoice = quote.qr_code
                
                qrCodeImageView.image = .createQRCode(quote.qr_code, dimension: 231, logo: UIImage(named: "qr-btc"))
                
                UIView.animate(withDuration: 0.3) {
                    self.qrCodeImageView.superview?.alpha = 1
                }
                
                Connection.wallet.isConnectedPublisher.filter { $0 }
                    .sink { [weak self] _ in
                        self?.trackPayment = Connection.wallet.requestCacheContinous(name: "membership_purchase_monitor", request: ["membership_quote_id": .string(quote.membership_quote_id)]) { result in

                            guard let response: MembershipPurchaseMonitorResponse = result.arrayValue?.last?.objectValue?["content"]?.stringValue?.decode() else { return }
                            
                            DispatchQueue.main.async {
                                guard response.completed_at != nil, self?.runOnce == true else { return }
                                
                                self?.runOnce = false
                                self?.cancellables = []
                                self?.trackPayment = nil
                                
                                WalletManager.instance.refreshPremiumState()
                                
                                self?.present(WalletTransferSummaryController(.success(title: "Success, payment received!", description: "You are now a Primal Legend")), animated: true) {
                                    guard let navigationController = self?.navigationController else { return }
                                    
                                    guard let rootVC = navigationController.viewControllers.first(where: { $0 as? PremiumViewController != nil }) else {
                                        navigationController.popToRootViewController(animated: false)
                                        return
                                    }
                                    navigationController.popToViewController(rootVC, animated: false)
                                }
                            }
                        }
                    }
                    .store(in: &cancellables)
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
        
        balanceView.animateBalanceChange = false
        balanceView.balance = amount
    }
}

