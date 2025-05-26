//
//  TransactionViewDatasource.swift
//  Primal
//
//  Created by Pavle Stevanović on 16.12.24..
//

import UIKit
import Combine

protocol TransactionPartialCell: UITableViewCell {
    func setupWithCellInfo(_ info: TransactionCellType)
}

struct ZapInfo: Codable {
    let tags: [[String]]
}

extension ArticleCell: TransactionPartialCell {
    func setupWithCellInfo(_ info: TransactionCellType) {
        guard case .article(let article) = info else { return }
        setUp(article)
        border.isHidden = true
        threeDotsButton.isHidden = true
        contentView.backgroundColor = .background4
        contentView.layer.cornerRadius = 8
    }
}

enum TransactionCellType: Hashable {
    case amount(Int, incoming: Bool)
    case title(String)
    case user(ParsedUser?, message: String?)
    case onchain(message: String?)
    case info(String, String)
    case copyInfo(String, String)
    case actionInfo(String, String)
    case expand(Bool)
    case article(Article)
    
    var cellID: String {
        switch self {
        case .amount:           return "amount"
        case .title:            return "title"
        case .user, .onchain:   return "user"
        case .info, .copyInfo, .actionInfo:
                                return "info"
        case .expand:           return "expand"
        case .article:          return "article"
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

enum TransactionFeedItem: Hashable {
    case infoCell(TransactionCellType, WalletTransaction, isLast: Bool)
    case noteElement(content: ParsedContent, element: NoteFeedElement)
}

class TransactionViewDatasource: UITableViewDiffableDataSource<TwoSectionFeed, TransactionFeedItem>, NoteFeedDatasource, RegularFeedDatasourceProtocol {
    var noteSectionCells: [TransactionFeedItem] = []
    var infoCells: [TransactionCellType] = []
    
    var cellCount: Int { noteSectionCells.count + infoCells.count }
    
    var article: Article? { didSet { setInfoCells() } }
    var isExpanded: Bool = true { didSet { setInfoCells() } }
    
    private var cancellables: Set<AnyCancellable> = []
    
    
    let transaction: WalletTransaction
    let user: ParsedUser?
    init(transaction: WalletTransaction, user: ParsedUser?, tableView: UITableView, delegate: FeedElementCellDelegate) {
        self.transaction = transaction
        self.user = user
        
        super.init(tableView: tableView) { [weak delegate] tableView, indexPath, item in
            let cell: UITableViewCell
            
            switch item {
            case .infoCell(let type, let transaction, let isLast):
                let cell = tableView.dequeueReusableCell(withIdentifier: type.cellID, for: indexPath)
                (cell as? TransactionPartialCell)?.setupWithCellInfo(type)
        
                (cell as? TransactionInfoCell)?.setIsLastInSection(isLast)
                (cell as? TransactionAmountCell)?.setIsPending(transaction.state != "SUCCEEDED")
                return cell
            case .noteElement(let content, let element):
                cell = tableView.dequeueReusableCell(withIdentifier: element.cellID, for: indexPath)
                switch element {
                case .webPreview(_, let metadata):
                    (cell as? WebPreviewCell)?.updateWebPreview(metadata)
                case .postPreview(let embedded):
                    if let cell = cell as? RegularFeedElementCell {
                        cell.update(embedded)
                        cell.delegate = delegate
                    }
                    return cell
                default:
                    break
                }
                
                if let cell = cell as? RegularFeedElementCell {
                    cell.update(content)
                    cell.delegate = delegate
                }
            }
            
            return cell
        }
        
        defaultRowAnimation = .fade
        registerCells(tableView)
        registerTransactionCells(tableView)
        setInfoCells()
                
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
            .receive(on: DispatchQueue.main)
            .map { [weak self] in
                if let self, let article = $0.getArticles().first {
                    self.article = article
                }
                return $0.process(contentStyle: .regular)
            }
            .sink { [weak self] posts in
                guard let self, let post = posts.first(where: { $0.post.id == postID }) else { return }
                self.setPosts([post])
            }
            .store(in: &cancellables)
        }
    }
    
    func elementForIndexPath(_ indexPath: IndexPath) -> NoteFeedElement? {
        guard indexPath.section == 1, let data = noteSectionCells[safe: indexPath.row], case .noteElement(_, let element) = data else { return nil }
        return element
    }
    
    func postForIndexPath(_ indexPath: IndexPath) -> ParsedContent? {
        guard indexPath.section == 1, let data = noteSectionCells[safe: indexPath.row], case .noteElement(let content, _) = data else { return nil }
        return content
    }
    
    private func registerTransactionCells(_ tableView: UITableView) {
        tableView.register(TransactionAmountCell.self, forCellReuseIdentifier: "amount")
        tableView.register(TransactionTitleCell.self, forCellReuseIdentifier: "title")
        tableView.register(TransactionUserInfoCell.self, forCellReuseIdentifier: "user")
        tableView.register(TransactionInfoCell.self, forCellReuseIdentifier: "info")
        tableView.register(TransactionExpandInfoCell.self, forCellReuseIdentifier: "expand")
        tableView.register(ArticleCell.self, forCellReuseIdentifier: "article")
    }
    
    func setPosts(_ posts: [ParsedContent]) {
        noteSectionCells = convertPostsToCells(posts).flatMap { post, elements in
            elements.map { .noteElement(content: post, element: $0) }
        }
        
        setInfoCells()
    }
    
    func setInfoCells() {
        let btcAmount = abs(Double(transaction.amount_btc) ?? 0)
        let isDeposit = transaction.type == "DEPOSIT"
        let isOnchain = transaction.onchainAddress != nil
        let date = Date(timeIntervalSince1970: TimeInterval(transaction.created_at))
        
        var cells: [TransactionCellType] = [
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
            
            cells.append(.info("Current USD value", "$" + (btcAmount * .BTC_TO_USD).nDecimalPoints(n: 2)))
            if let exchangeRateString = transaction.exchange_rate, let exchangeRate = Double(exchangeRateString) {
                cells.append(.info("Original USD value", "$" + (btcAmount / exchangeRate).nDecimalPoints(n: 2)))
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
        
        if (!isOnchain && !noteSectionCells.isEmpty) || !isExpanded {
            cells.append(.expand(isExpanded))
        }
        
        if let article {
            cells += [
                .title("ZAPPED ARTICLE"),
                .article(article)
            ]
        }
        
        
        if !noteSectionCells.isEmpty {
            cells += [.title("ZAPPED NOTE")]
        }

        infoCells = cells
        
        updateCells()
    }
    
    func updateCells() {
        var snapshot = NSDiffableDataSourceSnapshot<TwoSectionFeed, TransactionFeedItem>()
        snapshot.appendSections([.info])
        snapshot.appendItems(infoCells.dropLast().map { .infoCell($0, transaction, isLast: false) })
        if let last = infoCells.last {
            snapshot.appendItems([.infoCell(last, transaction, isLast: true)])
        }
        
        if !noteSectionCells.isEmpty {
            snapshot.appendSections([.feed])
            snapshot.appendItems(noteSectionCells)
        }
        
        apply(snapshot, animatingDifferences: true)
    }
}
