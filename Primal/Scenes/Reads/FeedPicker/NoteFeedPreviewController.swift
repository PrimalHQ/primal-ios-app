//
//  NoteFeedPreviewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.9.24..
//

import UIKit

class NoteFeedPreviewController: NoteFeedViewController {
    var contentInset: UIEdgeInsets { .zero }
    var disableInteraction: Bool { true }
    
    let info: ParsedFeedFromMarket
    init(feed: PrimalFeed, feedInfo: ParsedFeedFromMarket) {
        info = feedInfo
        super.init(feed: .init(newFeed: feed))
        table.contentInsetAdjustmentBehavior = .never
        table.contentInset = .zero
        
        table.removeFromSuperview()
        view.addSubview(table)
        table.pinToSuperview()
        
        dataSource = PreviewFeedDatasource(feed: feedInfo, tableView: table, delegate: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        table.backgroundColor = .background
        
        DispatchQueue.main.async {
            self.table.contentInset = self.contentInset
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if disableInteraction { return }
        
        super.tableView(tableView, didSelectRowAt: indexPath)
    }
}

extension NoteFeedPreviewController: FeedMarketplaceCellController {
    func feedForCell(_ cell: UITableViewCell) -> ParsedFeedFromMarket? { info }
    
    func reloadViewAfterZap() { table.reloadData() }
}
