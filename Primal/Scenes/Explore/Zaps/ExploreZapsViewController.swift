//
//  ExploreZapsViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 8.10.24..
//

import Combine
import UIKit

class ExploreZapsViewController: UIViewController, Themeable {
    private var cancellables: Set<AnyCancellable> = []
    private let feedManager = ExploreZapsFeedManager()
    
    private var zaps: [ParsedFeedZap] = [] {
        didSet {
            table.reloadData()
            loadingView.isHidden = !zaps.isEmpty
            if !zaps.isEmpty {
                loadingView.pause()
            }
        }
    }
    
    private let table = UITableView()
    private let loadingView = SkeletonLoaderView(aspect: 343 / 112)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        feedManager.$zaps
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] zaps in
                self?.zaps = zaps
                self?.table.refreshControl?.endRefreshing()
            })
            .store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateTheme()
        
        feedManager.refresh()
    }
    
    func updateTheme() {
        table.reloadData()
        
        DispatchQueue.main.async { [self] in
            loadingView.isHidden = !zaps.isEmpty
            if zaps.isEmpty {
                loadingView.play()
            } else {
                loadingView.pause()
            }
        }
    }
}

private extension ExploreZapsViewController {
    func setup() {
        view.addSubview(table)
        table.pinToSuperview()
        table.contentInsetAdjustmentBehavior = .never
        table.register(ExploreZapsCell.self, forCellReuseIdentifier: "cell")
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.refreshControl = .init(frame: .zero, primaryAction: .init(handler: { [weak self] _ in
            self?.feedManager.refresh()
        }))
        
        table.contentInset = .init(top: 157 + 16, left: 0, bottom: 80, right: 0)
        table.scrollIndicatorInsets = .init(top: 60, left: 0, bottom: 50, right: 0)
        
        view.addSubview(loadingView)
        loadingView.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, padding: 60, safeArea: true)
    }
}

extension ExploreZapsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { zaps.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? ExploreZapsCell {
            cell.updateForZap(zaps[indexPath.row])
        }
        return cell
    }
}

extension ExploreZapsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let zap = zaps[safe: indexPath.row] else { return }
        
        if let article = zap.zappedObject as? Article {
            show(ArticleViewController(content: article), sender: nil)
        } else if let post = zap.zappedObject as? ParsedContent {
            show(ThreadViewController(post: post), sender: nil)
        } else if let user = zap.zappedObject as? ParsedUser {
            show(ProfileViewController(profile: user), sender: nil)
        }
    }
}
