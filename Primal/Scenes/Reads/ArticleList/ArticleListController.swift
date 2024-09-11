//
//  ArticleListController.swift
//  Primal
//
//  Created by Pavle Stevanović on 6.8.24..
//

import Combine
import UIKit
import SafariServices
import GenericJSON
import Lottie

class ArticleListController: UIViewController, ArticleCellController, UITableViewDataSource, Themeable {
    let table = UITableView()
    
    var cancellables: Set<AnyCancellable> = []
    
    var articles: [Article] = [] {
        didSet {
            if view.window != nil {
                table.reloadData()
            }
        }
    }
    
    var articleSection: Int { 0 }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        table.reloadData()
    }
    
    func updateTheme() {
        navigationItem.leftBarButtonItem = customBackButton
        
        view.backgroundColor = .background
        
        if view.window != nil {
            table.reloadData()
        }
        
        articles.forEach { $0.mentions.forEach { $0.buildContentString() }}
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { articles.isEmpty ? 5 : articles.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let article = articles[safe: indexPath.row] else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loading", for: indexPath)
            (cell as? ArticleLoadingCell)?.updateTheme()
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        (cell as? ArticleCell)?.setUp(article, delegate: self)
        return cell
    }
    
    func articleCellDidSelect(_ cell: ArticleCell, action: PostCellEvent) {
        guard
            let indexPath = table.indexPath(for: cell),
            indexPath.section == articleSection,
            let article = articles[safe: indexPath.row]
        else { return }
        
        performEvent(action, withPost: article.asParsedContent)
    }
}

private extension ArticleListController {
    func setup() {
        updateTheme()
        
        view.addSubview(table)
        table
            .pinToSuperview(edges: .horizontal)
            .pinToSuperview(edges: .top, padding: 6, safeArea: true)
            .pinToSuperview(edges: .bottom, padding: 48, safeArea: true)
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.register(ArticleCell.self, forCellReuseIdentifier: "cell")
        table.register(ArticleLoadingCell.self, forCellReuseIdentifier: "loading")
        
        NotificationCenter.default.publisher(for: .userMuted)
            .compactMap { $0.object as? String }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pubkey in
                guard let self else { return }
                
                articles = articles.filter { $0.user.data.pubkey != pubkey }
            }
            .store(in: &cancellables)
    }
}

extension ArticleListController: ArticleCellDelegate {
    
    func performEvent(_ event: PostCellEvent, withPost post: ParsedContent) {
        switch event {
        case .share:
            let activityViewController = UIActivityViewController(activityItems: [post.webURL()], applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
        case .copy(let property):
            UIPasteboard.general.string = post.propertyText(property)
            RootViewController.instance.view.showToast("Copied!")
        case .report:
            break // TODO: Something?
        case .mute:
            MuteManager.instance.toggleMute(post.user.data.pubkey)
        case .bookmark:
            BookmarkManager.instance.bookmark(post)
        case .unbookmark:
            BookmarkManager.instance.unbookmark(post)
        default:
            break
        }
    }
    
}

extension ArticleListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == articleSection, let post = articles[safe: indexPath.row] else { return }
        
        let longForm = ArticleViewController(content: post)
        show(longForm, sender: nil)
    }
}

extension Article {
    var url: URL? {
        guard
            let npub = event.pubkey.hexToNpub(),
            let noteid = event.id.hexToNoteId()
        else { return nil }
    
        let urlString = "https://highlighter.com/\(npub)/\(noteid)"
    
        return URL(string: urlString)
    }
    
    var asParsedContent: ParsedContent {
        .init(post: .init(nostrPost: event, nostrPostStats: stats), user: user)
    }
}

class ArticleLoadingCell: UITableViewCell, Themeable {
    let animationView = LottieAnimationView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(animationView)
        animationView
            .pinToSuperview(edges: .horizontal)
            .pinToSuperview(edges: .top, padding: 10)
            .pinToSuperview(edges: .bottom, padding: -10)
            .constrainToAspect(1125 / 480)
        
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        animationView.animation = Theme.current.isDarkTheme ? AnimationType.articleListSkeleton.animation : AnimationType.articleListSkeletonLight.animation
        animationView.play(toProgress: 1, loopMode: .loop)
    }
}
