//
//  ExploreFeedsViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 24.9.24..
//

import UIKit
import Kingfisher
import Combine

final class ExploreFeedsViewController: UIViewController, Themeable {
    var cancellables: Set<AnyCancellable> = []
    
    let table = UITableView()
    
    var feeds: [ParsedFeedFromMarket] = [] {
        didSet {
            table.reloadData()
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setup()
        
        SocketRequest(name: "get_featured_dvm_feeds", payload: ["user_pubkey": .string(IdentityManager.instance.userHexPubkey)])
            .publisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in                
                self?.feeds = result.feeds()
            })
            .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateTable()
    }
    
    func updateTheme() {
        table.backgroundColor = .background
        table.reloadData()
    }
}

private extension ExploreFeedsViewController {
    func updateTable() {
        table.reloadData()
    }
    
    func setup() {
        view.backgroundColor = .background
        
        table.showsVerticalScrollIndicator = false
        table.register(FeedExploreCell.self, forCellReuseIdentifier: "cell")
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.contentInsetAdjustmentBehavior = .never
        table.contentInset = .init(top: 157, left: 0, bottom: 80, right: 0)
        table.scrollIndicatorInsets = .init(top: 60, left: 0, bottom: 50, right: 0)
        
        view.addSubview(table)
        table.pinToSuperview()
        
        updateTheme()
    }
}

extension ExploreFeedsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { feeds.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        (cell as? FeedExploreCell)?.setup(feeds[indexPath.row])
        return cell
    }
}

extension ExploreFeedsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let parsed = feeds[safe: indexPath.row] else { return }
        let feed = parsed.data
        
        guard
            let id = feed.id,
            let pubkey = feed.pubkey
        else { return }
        
        
        let kind: PrimalFeedType = parsed.metadata?.kind == "notes" ? .note : .article
        
        let readsFeed = PrimalFeed(
            name: feed.name,
            spec: "{\"dvm_id\":\"\(id)\",\"dvm_pubkey\":\"\(pubkey)\", \"kind\":\"\(kind.kind)\"}",
            description: feed.about
        )
        
        show(ExploreFeedPreviewParentController(feed: readsFeed, type: kind, feedInfo: parsed), sender: nil)
    }
}