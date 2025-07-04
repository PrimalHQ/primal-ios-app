//
//  PremiumManageSubscriptionController.swift
//  Primal
//
//  Created by Pavle Stevanović on 18.11.24..
//

import Combine
import UIKit
import GenericJSON

struct SubscriptionHistoryResponse: Codable {
    var purchased_at: Double
    var product_id: String
    var product_label: String
    var amount_btc: String
    var amount_usd: String
    var currency: String
}

class PremiumManageSubscriptionController: UITableViewController {
    
    private var cancellables: Set<AnyCancellable> = []
    
    var history: [SubscriptionHistoryResponse] = [] { didSet { tableView.reloadData() }}
    
    var didReachEnd = false
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        navigationItem.leftBarButtonItem = customBackButton
        title = "Manage Subscription"
        
        tableView.register(PremiumManageSubscriptionHeaderCell.self, forCellReuseIdentifier: "header")
        tableView.register(PremiumManageSubscriptionDataCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        
        guard let event = NostrObject.create(content: #"{"limit":100}"#, kind: 30078) else { return }

        SocketRequest(name: "membership_purchase_history", payload: ["event_from_user": event.toJSON()], connection: .wallet)
            .publisher()
            .mapEventsOfKind(.premiumSubscriptionHistory)
            .receive(on: DispatchQueue.main)
            .assign(to: \.history, onWeak: self)
            .store(in: &cancellables)
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int { 2 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { section == 0 ? 1 : history.count }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell =  tableView.dequeueReusableCell(withIdentifier: "header", for: indexPath)
            (cell as? PremiumManageSubscriptionHeaderCell)?.delegate = self
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let subscription = history[indexPath.row]
        
        let amount: String
        if subscription.currency == "btc" {
            let double = (Double(subscription.amount_btc) ?? 0) * .BTC_TO_SAT
            amount = "\(double.localized()) sats"
        } else {
            amount = "$\(subscription.amount_usd) USD"
        }
    
        (cell as? PremiumManageSubscriptionDataCell)?.set(
            date: .init(timeIntervalSince1970: subscription.purchased_at),
            type: subscription.product_label,
            amount: amount
        )
        cell.updateBackground(isLast: history.count - 1 == indexPath.row)
        return cell
    }
}

extension PremiumManageSubscriptionController: PremiumManageSubscriptionHeaderCellDelegate {
    func actionButtonPressed() {
        guard let state = WalletManager.instance.premiumState else { return }
        if state.recurring {
            // Cancel
            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            return
        }
        // Buy
        show(PremiumBuySubscriptionController(pickedName: state.name, kind: .premium, state: .buySubscription), sender: nil)
    }
}
