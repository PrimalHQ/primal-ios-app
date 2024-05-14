//
//  TransactionViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 20.12.23..
//

import Combine
import UIKit
import SafariServices

protocol TransactionPartialCell: UITableViewCell {
    func setupWithCellInfo(_ info: TransactionViewController.CellType)
}

struct ZapInfo: Codable {
    let tags: [[String]]
}

final class TransactionViewController: FeedViewController {
    enum CellType {
        case amount(Int, incoming: Bool)
        case title(String)
        case user(ParsedUser?, message: String?)
        case onchain(message: String?)
        case info(String, String)
        case copyInfo(String, String)
        case actionInfo(String, String)
        case expand(Bool)
        
        var cellID: String {
            switch self {
            case .amount:           return "amount"
            case .title:            return "title"
            case .user, .onchain:   return "user"
            case .info, .copyInfo, .actionInfo:  
                                    return "info"
            case .expand:           return "expand"
            }
        }
        
        var isMainInfoCell: Bool {
            switch self {
            case .user, .onchain:   return true
            default:                return false
            }
        }
        
        var isAmountCell: Bool {
            switch self {
            case .amount:           return true
            default:                return false
            }
        }
    }
    
    var cells: [CellType] = []
    
    let transaction: WalletTransaction
    let user: ParsedUser?
    
    var didFinishAppear = false
    
    var isExpanded: Bool = true {
        didSet {
            setCells()
            table.reloadData()
        }
    }
    
    var foregroundUpdate: AnyCancellable?
    
    init(transaction: WalletTransaction, user: ParsedUser?) {
        self.transaction = transaction
        self.user = user
        super.init()
        
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override var barsMaxTransform: CGFloat { 0 }
    
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
    
    override var postSection: Int { 1 }
    
    func numberOfSections(in tableView: UITableView) -> Int { 2 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? cells.count : super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section == 0 else {
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            if let postCell = cell as? PostCell {
                postCell.bottomBorder.isHidden = true
                postCell.contentView.backgroundColor = .background4
                postCell.contentView.layer.cornerRadius = 8
            }
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cells[indexPath.row].cellID, for: indexPath)
        (cell as? TransactionPartialCell)?.setupWithCellInfo(cells[indexPath.row])
        
        let hasPostSection = super.tableView(tableView, numberOfRowsInSection: 1) > 0
        (cell as? TransactionInfoCell)?.setIsLastInSection(indexPath.row + 1 + (hasPostSection ? 1 : 0) == cells.count)
        (cell as? TransactionAmountCell)?.setIsPending(transaction.state != "SUCCEEDED")
        return cell
    }
    
    var firstTimeAnimating = true
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.section == postSection else { return }
        
        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        
        guard firstTimeAnimating else { return }
        firstTimeAnimating = false
        
        cell.contentView.transform = .init(translationX: 0, y: -100)
        cell.contentView.alpha = 0
        
        UIView.animate(withDuration: 0.4, delay: 0.4) {
            cell.contentView.transform = .identity
            cell.contentView.alpha = 1
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else {
            super.tableView(tableView, didSelectRowAt: indexPath)
            return
        }
        switch cells[indexPath.row] {
        case .copyInfo(_, let text):
            UIPasteboard.general.string = text
            view.showToast("Copied!")
        case .actionInfo(_, "view on blockchain"):
            guard let onchainAddress = transaction.onchain_transaction_id, let url = URL(string: "https://mempool.space/tx/\(onchainAddress)") else { return }
            present(SFSafariViewController(url: url), animated: true)
        case .expand:
            isExpanded.toggle()
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
        
        table.register(TransactionAmountCell.self, forCellReuseIdentifier: "amount")
        table.register(TransactionTitleCell.self, forCellReuseIdentifier: "title")
        table.register(TransactionUserInfoCell.self, forCellReuseIdentifier: "user")
        table.register(TransactionInfoCell.self, forCellReuseIdentifier: "info")
        table.register(TransactionExpandInfoCell.self, forCellReuseIdentifier: "expand")
        
        setCells()
        
        if let zapInfo: ZapInfo = transaction.zap_request?.decode(), let postID = zapInfo.tags.first(where: { $0.first == "e" })?.last {
            print(postID)
            
            isExpanded = false
            
            SocketRequest(
                name: "thread_view",
                payload: .object([
                    "event_id": .string(postID),
                    "limit": 20,
                    "user_pubkey": .string(IdentityManager.instance.userHexPubkey)
                ])
            )
            .publisher()
            .map { $0.process() }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posts in
                guard let self, let post = posts.first(where: { $0.post.id == postID }) else { return }
                self.posts = [post]
                setCells()
                table.reloadData()
            }
            .store(in: &cancellables)
        }
        
        table.reloadData()
        table.showsVerticalScrollIndicator = false
        
        navigationBorder.removeFromSuperview()
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        stack.isLayoutMarginsRelativeArrangement = true

        loadingSpinner.isHidden = true
        refreshControl.removeFromSuperview()
    }
    
    func setCells() {
        let btcAmount = abs(Double(transaction.amount_btc) ?? 0)
        let isDeposit = transaction.type == "DEPOSIT"
        let isOnchain = transaction.onchainAddress != nil
        let date = Date(timeIntervalSince1970: TimeInterval(transaction.created_at))
        
        cells = [
            .amount(Int((btcAmount * .BTC_TO_SAT).rounded()), incoming: isDeposit),
            .title(isDeposit ? "RECEIVED FROM" : "SENT TO"),
        ]
        
        if let pubkey = user?.data.pubkey, pubkey != IdentityManager.instance.userHexPubkey {
            cells.append(.user(user, message: transaction.note))
        } else if isOnchain {
            cells.append(.onchain(message: transaction.note))
        } else {
            cells.append(.user(nil, message: transaction.note))
        }
        
        cells.append(.info("Date", date.formatted()))
        
        if isExpanded {
            cells += [
                .info("Status", transaction.state.localizedCapitalized),
                .info("Transaction Type", isOnchain ? "On-chain Payment" : "Lightning Payment")
            ]
            
            cells.append(.info("Current USD value", "$" + (btcAmount * .BTC_TO_USD).twoDecimalPoints()))
            if let exchangeRateString = transaction.exchange_rate, let exchangeRate = Double(exchangeRateString) {
                cells.append(.info("Original USD value", "$" + (btcAmount / exchangeRate).twoDecimalPoints()))
            }
            if let feeString = transaction.total_fee_btc, let feeBtc = Double(feeString) {
                let fee = Int((feeBtc * .BTC_TO_SAT).rounded())
                cells.append(.info(isOnchain ? "Mining fee" : "Transaction fee", "\(fee) sats"))
            }
            if let invoice = transaction.invoice {
                cells.append(.copyInfo("Invoice", invoice))
            }
            if transaction.onchain_transaction_id != nil {
                cells.append(.actionInfo("Details", "view on blockchain"))
            }
        }
        
        if (!isOnchain && !posts.isEmpty) || !isExpanded {
            cells.append(.expand(isExpanded))
        }
        
        if !posts.isEmpty {
            cells += [.title("ZAPPED NOTE")]
        }
    }
}
