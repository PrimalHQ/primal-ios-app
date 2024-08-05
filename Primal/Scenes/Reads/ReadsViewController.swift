//
//  ReadsViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 28.5.24..
//

import Combine
import UIKit
import SafariServices
import GenericJSON

class DropdownNavigationView: UIView, Themeable {
    var title: String {
        didSet {
            updateTheme()
        }
    }
    
    let button = UIButton()
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        updateTheme()
        
        addSubview(button)
        button.pinToSuperview(edges: .vertical).centerToSuperview()
        let leadingC = button.leadingAnchor.constraint(equalTo: leadingAnchor)
        leadingC.priority = .defaultLow
        leadingC.isActive = true
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        button.configuration = .navChevronButton(title: title)
    }
}

final class ReadsViewController: UIViewController, ArticleCellController, Themeable {
    let table = UITableView()
    
    var cancellables: Set<AnyCancellable> = []
    
    var articles: [Article] = [] {
        didSet {
            table.reloadData()
        }
    }
    
    lazy var navTitleView = DropdownNavigationView(title: "Nostr Reads")
    let border = UIView().constrainToSize(height: 1)
    
    lazy var searchButton = UIButton(configuration: .simpleImage(UIImage(named: "navSearch")), primaryAction: .init(handler: { [weak self] _ in
        self?.navigationController?.fadeTo(SearchViewController())
    }))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func updateTheme() {
        view.backgroundColor = .background
        searchButton.tintColor = .foreground3
        
        navTitleView.updateTheme()
        
        border.backgroundColor = .background3
        
        table.reloadData()
        
        articles.forEach { $0.mentions.forEach { $0.buildContentString() }}
    }
}

private extension ReadsViewController {
    func setup() {
        updateTheme()
        navigationItem.rightBarButtonItem = .init(customView: searchButton)
        navigationItem.titleView = navTitleView
        
        var isAll = false
        navTitleView.button.addAction(.init(handler: { [weak self] _ in
            self?.load(regular: isAll)
            isAll = !isAll
        }), for: .touchUpInside)
        
        view.addSubview(table)
        table
            .pinToSuperview(edges: .horizontal)
            .pinToSuperview(edges: .top, padding: 6, safeArea: true)
            .pinToSuperview(edges: .bottom, padding: 48, safeArea: true)
        table.register(ArticleCell.self, forCellReuseIdentifier: "cell")
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        
        view.addSubview(border)
        border.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, padding: 6, safeArea: true)
        
        load()
        
        NotificationCenter.default.publisher(for: .userMuted)
            .compactMap { $0.object as? String }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pubkey in
                guard let self else { return }
                
                articles = articles.filter { $0.user.data.pubkey != pubkey }
            }
            .store(in: &cancellables)

    }
        
    func load(regular: Bool = true) {
        navTitleView.title = regular ? "Nostr Reads" : "All Reads"
        articles = []
        
        var payload: [String: JSON] = [
            "limit": .number(100)
        ]
        if regular {
            payload["pubkey"] = .string(IdentityManager.instance.userHexPubkey)
        }
        
        SocketRequest(name: "long_form_content_feed", payload: .object(payload))
            .publisher()
            .map { $0.getArticles().filter({ !MuteManager.instance.isMuted($0.event.pubkey)}) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.articles, onWeak: self)
            .store(in: &cancellables)
    }
}

extension ReadsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { articles.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        (cell as? ArticleCell)?.setUp(articles[indexPath.row], delegate: self)
        return cell
    }
}

extension ReadsViewController: ArticleCellDelegate {
    func articleCellDidSelect(_ cell: ArticleCell, action: PostCellEvent) {
        guard let indexPath = table.indexPath(for: cell), let article = articles[safe: indexPath.row] else { return }
        
        performEvent(action, withPost: article.asParsedContent)
    }
    
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

extension ReadsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let post = articles[safe: indexPath.row] else { return }
        
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
