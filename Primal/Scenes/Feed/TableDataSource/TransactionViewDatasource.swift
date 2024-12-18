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

class TransactionViewDatasource: UITableViewDiffableDataSource<TwoSectionFeed, TransactionFeedItem>, NoteFeedDatasource {
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
                switch element {
                case .userInfo:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementUserCell.cellID, for: indexPath)
                case .text:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementTextCell.cellID, for: indexPath)
                case .zapGallery:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementSmallZapGalleryCell.cellID, for: indexPath)
                case .imageGallery:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementImageGalleryCell.cellID, for: indexPath)
                case .webPreviewSmall:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementWebPreviewCell.cellID, for: indexPath)
                case .webPreviewLarge:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementWebPreviewCell.cellID + "Large", for: indexPath)
                case .postPreview:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementPostPreviewCell.cellID, for: indexPath)
                case .zapPreview:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementZapPreviewCell.cellID, for: indexPath)
                case .article:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementArticleCell.cellID, for: indexPath)
                case .info:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementInfoCell.cellID, for: indexPath)
                case .invoice:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementInvoiceCell.cellID, for: indexPath)
                case .reactions:
                    cell = tableView.dequeueReusableCell(withIdentifier: FeedElementReactionsCell.cellID, for: indexPath)
                }
                
                if let cell = cell as? RegularFeedElementCell {
                    cell.update(content)
                    cell.delegate = delegate
                    cell.contentView.backgroundColor = .black
                }
            }
            
            return cell
        }
        
        defaultRowAnimation = .fade
        registerCells(tableView)
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
    
    func postForIndexPath(_ indexPath: IndexPath) -> ParsedContent? {
        guard indexPath.section == 1, let data = noteSectionCells[safe: indexPath.row], case .noteElement(let content, _) = data else { return nil }
        return content
    }
    
    private func registerCells(_ tableView: UITableView) {
        tableView.register(FeedElementUserCell.self, forCellReuseIdentifier: FeedElementUserCell.cellID)
        tableView.register(FeedElementTextCell.self, forCellReuseIdentifier: FeedElementTextCell.cellID)
        tableView.register(FeedElementSmallZapGalleryCell.self, forCellReuseIdentifier: FeedElementSmallZapGalleryCell.cellID)
        tableView.register(FeedElementImageGalleryCell.self, forCellReuseIdentifier: FeedElementImageGalleryCell.cellID)
        tableView.register(FeedElementInfoCell.self, forCellReuseIdentifier: FeedElementInfoCell.cellID)
        tableView.register(FeedElementPostPreviewCell.self, forCellReuseIdentifier: FeedElementPostPreviewCell.cellID)
        tableView.register(FeedElementZapPreviewCell.self, forCellReuseIdentifier: FeedElementZapPreviewCell.cellID)
        tableView.register(FeedElementInvoiceCell.self, forCellReuseIdentifier: FeedElementInvoiceCell.cellID)
        tableView.register(FeedElementReactionsCell.self, forCellReuseIdentifier: FeedElementReactionsCell.cellID)
        tableView.register(FeedElementArticleCell.self, forCellReuseIdentifier: FeedElementArticleCell.cellID)
        
        tableView.register(FeedElementWebPreviewCell<SmallLinkPreview>.self, forCellReuseIdentifier: FeedElementWebPreviewCell.cellID)
        tableView.register(FeedElementWebPreviewCell<LargeLinkPreview>.self, forCellReuseIdentifier: FeedElementWebPreviewCell.cellID + "Large")
        
        tableView.register(SearchPremiumCell.self, forCellReuseIdentifier: "premium")
        tableView.register(SkeletonLoaderCell.self, forCellReuseIdentifier: "loading")
        
        tableView.register(TransactionAmountCell.self, forCellReuseIdentifier: "amount")
        tableView.register(TransactionTitleCell.self, forCellReuseIdentifier: "title")
        tableView.register(TransactionUserInfoCell.self, forCellReuseIdentifier: "user")
        tableView.register(TransactionInfoCell.self, forCellReuseIdentifier: "info")
        tableView.register(TransactionExpandInfoCell.self, forCellReuseIdentifier: "expand")
        tableView.register(ArticleCell.self, forCellReuseIdentifier: "article")
    }
    
    func setPosts(_ posts: [ParsedContent]) {
        noteSectionCells = posts.flatMap({ content in
            var parts: [TransactionFeedItem] = [.noteElement(content: content, element: .userInfo)]
            
            if !content.text.isEmpty { parts.append(.noteElement(content: content, element: .text)) }
            if let invoice = content.invoice { parts.append(.noteElement(content: content, element: .invoice)) }
            if let article = content.article { parts.append(.noteElement(content: content, element: .article)) }
            
            if content.embededPost != nil { parts.append(.noteElement(content: content, element: .postPreview) )}
            
            if !content.mediaResources.isEmpty { parts.append(.noteElement(content: content, element: .imageGallery)) }
            
            if let data = content.linkPreview {
                if data.url.isYoutubeURL || data.url.isRumbleURL {
                    parts.append(.noteElement(content: content, element: .webPreviewLarge))
                } else {
                    parts.append(.noteElement(content: content, element: .webPreviewSmall))
                }
            }
            
            if let zapPreview = content.embeddedZap { parts.append(.noteElement(content: content, element: .zapPreview)) }
            if let custom = content.customEvent { parts.append(.noteElement(content: content, element: .info))}
            if let error = content.notFound { parts.append(.noteElement(content: content, element: .info)) }
            if !content.zaps.isEmpty { parts.append(.noteElement(content: content, element: .zapGallery(content.zaps))) }
            
            parts.append(.noteElement(content: content, element: .reactions))
            
            return parts
        })
        
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
