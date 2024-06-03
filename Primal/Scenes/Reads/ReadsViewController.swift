//
//  ReadsViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 28.5.24..
//

import Combine
import UIKit
import SafariServices

final class ReadsViewController: UIViewController, Themeable {
    let table = UITableView()
    
    var cancellables: Set<AnyCancellable> = []
    
    var posts: [ParsedLongFormPost] = [] {
        didSet {
            table.reloadData()
        }
    }
    
    lazy var searchButton = UIButton(configuration: .simpleImage(UIImage(named: "tabIcon-explore")), primaryAction: .init(handler: { [weak self] _ in
        self?.show(SearchViewController(), sender: nil)
    }))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func updateTheme() {
        view.backgroundColor = .background
        searchButton.tintColor = .foreground3
        
        table.reloadData()
    }
}

private extension ReadsViewController {
    func setup() {
        updateTheme()
        navigationItem.rightBarButtonItem = .init(customView: searchButton)
        title = "Nostr Reads"
        
        view.addSubview(table)
        table
            .pinToSuperview(edges: .horizontal)
            .pinToSuperview(edges: .top, safeArea: true)
            .pinToSuperview(edges: .bottom, padding: 56, safeArea: true)
        table.register(LongFormContentCell.self, forCellReuseIdentifier: "cell")
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        
        SocketRequest(name: "long_form_content_feed", payload: [
            "pubkey": .string(IdentityManager.instance.userHexPubkey),
            "limit": .number(100)
        ])
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
