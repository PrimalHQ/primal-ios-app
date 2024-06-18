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

final class ReadsViewController: UIViewController, Themeable {
    let table = UITableView()
    
    var cancellables: Set<AnyCancellable> = []
    
    var posts: [ParsedLongFormPost] = [] {
        didSet {
            table.reloadData()
        }
    }
    
    lazy var navTitleView = DropdownNavigationView(title: "Nostr Reads")
    let border = UIView().constrainToSize(height: 1)
    
    lazy var searchButton = UIButton(configuration: .simpleImage(UIImage(named: "tabIcon-explore")), primaryAction: .init(handler: { [weak self] _ in
        self?.navigationController?.fadeTo(SearchViewController())
    }))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func updateTheme() {
        view.backgroundColor = .background
        searchButton.tintColor = .foreground3
        
        navTitleView.updateTheme()
        
        border.backgroundColor = .background3
        
        table.reloadData()
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
        table.register(LongFormContentCell.self, forCellReuseIdentifier: "cell")
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        
        view.addSubview(border)
        border.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, padding: 6, safeArea: true)
        
        load()
    }
        
    func load(regular: Bool = true) {
        navTitleView.title = regular ? "Nostr Reads" : "All Reads"
        posts = []
        
        var payload: [String: JSON] = [
            "limit": .number(100)
        ]
        if regular {
            payload["pubkey"] = .string(IdentityManager.instance.userHexPubkey)
        }
        
        SocketRequest(name: "long_form_content_feed", payload: .object(payload))
            .publisher()
            .map { $0.getLongFormPosts() }
            .receive(on: DispatchQueue.main)
            .assign(to: \.posts, onWeak: self)
            .store(in: &cancellables)
    }
}

extension ReadsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { posts.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        (cell as? LongFormContentCell)?.setUp(posts[indexPath.row])
        return cell
    }
}

extension ReadsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let post = posts[safe: indexPath.row] else { return }
        
        let longForm = LongFormContentController(content: post)
        show(longForm, sender: nil)
    }
}

extension ParsedLongFormPost {
    var url: URL? {
        guard
            let npub = event.pubkey.hexToNpub(),
            let noteid = event.id.hexToNoteId()
        else { return nil }
    
        let urlString = "https://highlighter.com/\(npub)/\(noteid)"
    
        return URL(string: urlString)
    }
}
