//
//  NoteFeedPreviewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.9.24..
//

import UIKit

class NoteFeedPreviewController: ShortFormFeedController {
    var contentInset: UIEdgeInsets { .zero }
    var disableInteraction: Bool { true }
    
    let info: ParsedFeedFromMarket
    init(feed: PrimalFeed, feedInfo: ParsedFeedFromMarket) {
        info = feedInfo
        super.init(feed: .init(newFeed: feed))
        table.register(FeedPreviewCell.self, forCellReuseIdentifier: "infoCell")
        table.contentInsetAdjustmentBehavior = .never
        table.contentInset = .zero
        
        table.removeFromSuperview()
        view.addSubview(table)
        table.pinToSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        DispatchQueue.main.async {
            self.table.contentInset = self.contentInset
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? max(1, super.tableView(tableView, numberOfRowsInSection: section)) : super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = table.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath)
            (cell as? FeedPreviewCell)?.setup(info, delegate: self)
            return cell
        }
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.isUserInteractionEnabled = !disableInteraction
        return cell
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
