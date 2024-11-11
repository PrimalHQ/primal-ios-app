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
    let loadingView = SkeletonLoaderView(aspect: 343 / 120)
    
    var feeds: [ParsedFeedFromMarket] = [] {
        didSet {
            table.reloadData()
            loadingView.isHidden = !feeds.isEmpty
            if !feeds.isEmpty {
                loadingView.pause()
            }
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setup()
        
        refresh()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateTable()
    }
    
    func updateTheme() {
        table.backgroundColor = .background2
        
        updateTable()
    }
    
    func refresh() {
        SocketRequest(name: "get_featured_dvm_feeds", payload: ["user_pubkey": .string(IdentityManager.instance.userHexPubkey)])
            .publisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                self?.feeds = result.feeds()
                self?.table.refreshControl?.endRefreshing()
            })
            .store(in: &cancellables)
    }
}

private extension ExploreFeedsViewController {
    func updateTable() {
        table.reloadData()
        
        DispatchQueue.main.async { [self] in
            loadingView.isHidden = !feeds.isEmpty
            if feeds.isEmpty {
                loadingView.play()
            } else {
                loadingView.pause()
            }
        }
    }
    
    func setup() {
        table.showsVerticalScrollIndicator = false
        table.register(FeedExploreCell.self, forCellReuseIdentifier: "cell")
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.contentInsetAdjustmentBehavior = .never
        table.contentInset = .init(top: 169, left: 0, bottom: 80, right: 0)
        table.scrollIndicatorInsets = .init(top: 60, left: 0, bottom: 50, right: 0)
        table.refreshControl = UIRefreshControl(frame: .zero, primaryAction: .init(handler: { [weak self] _ in
            self?.refresh()
        }))
        
        view.addSubview(table)
        table.pinToSuperview()
        
        view.addSubview(loadingView)
        loadingView.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, padding: 60, safeArea: true)
    }
}

extension ExploreFeedsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { feeds.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        (cell as? FeedExploreCell)?.setup(feeds[indexPath.row], delegate: self)
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
        
        let spec = feed.primal_spec ?? "{\"dvm_id\":\"\(id)\",\"dvm_pubkey\":\"\(pubkey)\", \"kind\":\"\(kind.kind)\"}"
        
        let readsFeed = PrimalFeed(
            name: feed.name,
            spec: spec,
            description: feed.about ?? "",
            feedkind: "dvm"
        )
        
        show(ExploreFeedPreviewParentController(feed: readsFeed, type: kind, feedInfo: parsed), sender: nil)
    }
}

extension ExploreFeedsViewController: FeedMarketplaceCellController {
    func feedForCell(_ cell: UITableViewCell) -> ParsedFeedFromMarket? {
        guard let indexPath = table.indexPath(for: cell) else { return nil }
        return feeds[safe: indexPath.row]
    }
    
    func reloadViewAfterZap() {
        table.reloadData()
    }
}
