//
//  NoteFeedPreviewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.9.24..
//

import UIKit

class NoteFeedPreviewController: ShortFormFeedController {
    let info: FeedFromMarket
    init(feed: PrimalFeed, feedInfo: FeedFromMarket) {
        info = feedInfo
        super.init(feed: .init(newFeed: feed))
        table.register(FeedMarketplaceCell.self, forCellReuseIdentifier: "infoCell")
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
            self.table.contentInset = .zero
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            cell.isUserInteractionEnabled = false
            return cell
        }
        
        let cell = table.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath)
        (cell as? FeedMarketplaceCell)?.setupSelected(info)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return
//        guard let presentingViewController, let nav: UINavigationController = presentingViewController.findInChildren() else {
//            super.tableView(tableView, didSelectRowAt: indexPath)
//            return
//        }
//        
//        guard indexPath.section == postSection, let post = posts[safe: indexPath.row] else { return }
//        let thread = ThreadViewController(post: post)
//        dismiss(animated: true) {
//            nav.pushViewController(thread, animated: true)
//        }
    }
}

