//
//  PublicBookmarksViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 10.4.24..
//

import Combine
import UIKit

final class PublicBookmarksViewController: PostFeedViewController, ArticleCellController {
    lazy var navTitleView = DropdownNavigationView(title: "Bookmarks")
    let emptyView = EmptyTableView(title: "Your bookmarks will appear here")
    
    @Published var articles: [Article] = [] {
        didSet {
            if showArticles {
                table.reloadData()
            }
        }
    }
    
    @Published var showArticles = false {
        didSet {
            table.reloadData()
        }
    }
    
    init() {
        let feed = FeedManager(feed: .init(name: "", hex: "bookmarks;\(IdentityManager.instance.userHexPubkey)"))
        super.init(feed: feed)
        
        feed.$parsedPosts.receive(on: DispatchQueue.main).assign(to: \.posts, onWeak: self).store(in: &cancellables)
        feed.$parsedLongForm.receive(on: DispatchQueue.main).assign(to: \.articles, onWeak: self).store(in: &cancellables)
        
        Publishers.CombineLatest(feed.$parsedPosts.dropFirst(), feed.$parsedLongForm.dropFirst())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posts, articles in
                self?.loadingSpinner.isHidden = true
                self?.loadingSpinner.stop()
                self?.refreshControl.endRefreshing()
                    
                self?.emptyView.isHidden = !posts.isEmpty || !articles.isEmpty
                if posts.isEmpty {
                    self?.showArticles = true
                }
                if articles.isEmpty {
                    self?.showArticles = false
                }
            }
            .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        table.register(ArticleCell.self, forCellReuseIdentifier: "article")
        
        navigationItem.titleView = navTitleView
        navTitleView.button.addAction(.init(handler: { [weak self] _ in
            self?.present(PopupMenuViewController(message: nil, actions: [
                .init(title: "Notes", handler: { _ in
                    self?.showArticles = false
                }),
                .init(title: "Articles", handler: { _ in
                    self?.showArticles = true
                })
            ]), animated: true)
        }), for: .touchUpInside)
        
        refreshControl.addAction(.init(handler: { [weak self] _ in
            self?.feed.refresh()
        }), for: .valueChanged)
        
        view.addSubview(emptyView)
        emptyView.centerToSuperview()
        emptyView.isHidden = true
        
        updateTheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        loadingSpinner.play()
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        navigationItem.leftBarButtonItem = customBackButton
    }
    
    override var postSection: Int { 1 }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return showArticles ? articles.count : 0
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showArticles, indexPath.row > articles.count - 10  {
            feed.requestNewPage()
        }
        
        if indexPath.section == 0 {
            if let article = articles[safe: indexPath.row] {
                let articleCell = tableView.dequeueReusableCell(withIdentifier: "article", for: indexPath)
                (articleCell as? ArticleCell)?.setUp(article)
                return articleCell
            }
        }
        
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0, let article = articles[safe: indexPath.row] else {
            super.tableView(tableView, didSelectRowAt: indexPath)
            return
        }
        
        show(ArticleViewController(content: article), sender: nil)
    }
}

class EmptyTableView: UIView, Themeable {
    let label = UILabel()
    let refresh = UIButton()
    
    init(title: String) {
        super.init(frame: .zero)
        
        let stack = UIStackView(axis: .vertical, [label, refresh])
        addSubview(stack)
        stack.pinToSuperview()
        
        stack.alignment = .center
        stack.spacing = 18
    
        label.font = .appFont(withSize: 15, weight: .regular)
        label.text = title
        
        refresh.titleLabel?.font = .appFont(withSize: 15, weight: .bold)
        refresh.setTitle("REFRESH", for: .normal)
        
        updateTheme()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        label.textColor = .foreground
        refresh.setTitleColor(.accent, for: .normal)
        refresh.setTitleColor(.accent.withAlphaComponent(0.5), for: .highlighted)
    }
}
