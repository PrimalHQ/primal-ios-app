//
//  FeedMarketplaceController.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.8.24..
//

import UIKit
import Kingfisher
import Combine

final class FeedMarketplaceController: UIViewController {
    var cancellables: Set<AnyCancellable> = []
    
    let table = UITableView()
    
    var feeds: [ParsedFeedFromMarket] = [] {
        didSet {
            table.reloadData()
        }
    }
    
    let type: PrimalFeedType
    init(type: PrimalFeedType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
        setup()
        
        let kind = type == .article ? "reads" : "notes"
        
        SocketRequest(name: "get_featured_dvm_feeds", payload: ["kind": .string(kind)]).publisher()
            .receive(on: DispatchQueue.main)
            .map { $0.feeds() }
            .assign(to: \.feeds, onWeak: self)
            .store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateTable()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension FeedMarketplaceController {
    func updateTable() {
        table.reloadData()
    }
    
    func setup() {
        view.backgroundColor = .background2
        
        let pullBarParent = UIView()
        let pullBar = UIView()
        pullBarParent.addSubview(pullBar)
        pullBar.pinToSuperview(edges: .vertical).centerToSuperview(axis: .horizontal)
        
        let title = UILabel()
        title.text = "Feed Marketplace"
        title.font = .appFont(withSize: 20, weight: .bold)
        title.textColor = .foreground
        title.setContentCompressionResistancePriority(.required, for: .vertical)
        title.textAlignment = .center
        
        table.showsVerticalScrollIndicator = false
        table.register(FeedMarketplaceCell.self, forCellReuseIdentifier: "cell")
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.backgroundColor = .background2
        
        let stack = UIStackView(axis: .vertical, [
            pullBarParent, SpacerView(height: 20, priority: .required),
            title, SpacerView(height: 14, priority: .required),
            table
        ])
        
        view.addSubview(stack)
        stack.pinToSuperview(edges: .top, padding: 16).pinToSuperview(edges: .bottom).pinToSuperview(edges: .horizontal)
        
        pullBar.constrainToSize(width: 60, height: 5)
        pullBar.backgroundColor = .foreground.withAlphaComponent(0.8)
        pullBar.layer.cornerRadius = 2.5
        
        if let backButton = customBackButton.customView as? UIButton {
            view.addSubview(backButton)
            backButton
                .pinToSuperview(edges: .leading, padding: 20)
                .centerToView(title, axis: .vertical)
        }
    }
}

extension FeedMarketplaceController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { feeds.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        (cell as? FeedMarketplaceCell)?.setup(feeds[indexPath.row].data)
        return cell
    }
}

extension FeedMarketplaceController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let parsed = feeds[safe: indexPath.row] else { return }
        let feed = parsed.data
        
        guard
            let id = feed.id,
            let pubkey = feed.pubkey
        else { return }
        
        let spec = feed.primal_spec ?? "{\"dvm_id\":\"\(id)\",\"dvm_pubkey\":\"\(pubkey)\", \"kind\":\"\(type.kind)\"}"
        
        let readsFeed = PrimalFeed(
            name: feed.name,
            spec: spec,
            description: feed.about ?? "",
            feedkind: "dvm",
            enabled: true
        )
        show(FeedPreviewParentController(feed: readsFeed, type: type, feedInfo: parsed), sender: nil)
    }
}
