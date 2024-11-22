//
//  ArticleFeedPreviewFeedController.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.8.24..
//

import UIKit

class ArticleFeedPreviewFeedController: ArticleFeedViewController {
    let info: ParsedFeedFromMarket
    init(feed: PrimalFeed, feedInfo: ParsedFeedFromMarket) {
        info = feedInfo
        super.init(feed: feed)
        table.register(FeedPreviewCell.self, forCellReuseIdentifier: "infoCell")
        table.contentInsetAdjustmentBehavior = .never
        table.contentInset = .zero
        
        table.removeFromSuperview()
        view.addSubview(table)
        table.pinToSuperview()
    }
    
    override var articleSection: Int { 1 }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        let cell = table.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath)
        (cell as? FeedPreviewCell)?.setup(info, delegate: self)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let presentingViewController, let nav: UINavigationController = presentingViewController.findInChildren() else {
            super.tableView(tableView, didSelectRowAt: indexPath)
            return
        }
        
        guard indexPath.section == articleSection, let post = articles[safe: indexPath.row] else { return }
        let longForm = ArticleViewController(content: post)
        dismiss(animated: true) {
            nav.pushViewController(longForm, animated: true)
        }
    }
}

extension ArticleFeedPreviewFeedController: FeedMarketplaceCellController {
    func feedForCell(_ cell: UITableViewCell) -> ParsedFeedFromMarket? { info }
    
    func reloadViewAfterZap() { table.reloadData() }
}
