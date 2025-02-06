//
//  TransactionViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 20.12.23..
//

import Combine
import UIKit
import SafariServices

final class TransactionViewController: NoteViewController {
    var cells: [TransactionCellType] { (dataSource as? TransactionViewDatasource)?.infoCells ?? [] }
    
    let transaction: WalletTransaction
    let user: ParsedUser?
    
    var didFinishAppear = false
    
    var foregroundUpdate: AnyCancellable?
    
    init(transaction: WalletTransaction, user: ParsedUser?) {
        self.transaction = transaction
        self.user = user
        super.init()
        
        setup()
        
        dataSource = TransactionViewDatasource(transaction: transaction, user: user, tableView: table, delegate: self)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override var barsMaxTransform: CGFloat { 0 }
    override var adjustedTopBarHeight: CGFloat { 0 }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        mainTabBarController?.setTabBarHidden(false, animated: animated)
        
        table.contentInset = .zero
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        foregroundUpdate = NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink(receiveValue: { [weak self] _ in
                self?.table.reloadData()
            })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        table.reloadData()
        
        foregroundUpdate = nil
    }
    
    var firstTimeAnimating = true
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        
        guard indexPath.section == 1 else { return }
        
        guard firstTimeAnimating else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.firstTimeAnimating = false
        }
        
        cell.backgroundColor = .clear
        cell.clipsToBounds = false
        cell.contentView.transform = .init(translationX: 0, y: -50)
        cell.contentView.alpha = 0
        
        UIView.animate(withDuration: 0.4, delay: 0.4) {
            cell.contentView.transform = .identity
            cell.contentView.alpha = 1
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0, let cell = cells[safe: indexPath.row] else {
            super.tableView(tableView, didSelectRowAt: indexPath)
            return
        }
        
        switch cell {
        case .copyInfo(_, let text):
            UIPasteboard.general.string = text
            view.showToast("Copied!")
        case .actionInfo(_, "view on blockchain"):
            guard let onchainAddress = transaction.onchain_transaction_id, let url = URL(string: "https://mempool.space/tx/\(onchainAddress)") else { return }
            present(SFSafariViewController(url: url), animated: true)
        case .expand:
            (dataSource as? TransactionViewDatasource)?.isExpanded.toggle()
            table.contentInset = .init(top: 0, left: 0, bottom: 100, right: 0)
        case .article(let article):
            show(ArticleViewController(content: article), sender: nil)
        default:
            return
        }
    }
    
    override func setBarsToTransform(_ transform: CGFloat) {
        return
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        navigationItem.leftBarButtonItem = customBackButton
    }
}

private extension TransactionViewController {
    func setup() {
        let isDeposit = transaction.type == "DEPOSIT"
        
        if transaction.state == "SUCCEEDED" {
            if isDeposit {
                title = transaction.is_zap ? "Zap Received" : "Payment Received"
            } else {
                title = transaction.is_zap ? "Zap Sent" : "Payment Sent"
            }
        } else {
            title = "Pending Transaction"
        }
        
        table.showsVerticalScrollIndicator = false
        
        navigationBorder.removeFromSuperview()
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        stack.isLayoutMarginsRelativeArrangement = true

        refreshControl.removeFromSuperview()
    }
}
