//
//  LongFormCommentsController.swift
//  Primal
//
//  Created by Pavle Stevanović on 30.5.24..
//

import Combine
import UIKit

class LongFormCommentsController: FeedViewController {
    let content: Article
    var parsedContent: ParsedContent?
    
    @Published private var cellHeight: [CGFloat] = []
    
    var viewHeight: AnyPublisher<CGFloat, Never> {
        $cellHeight
            .map { $0.reduce(0, +) + 400 }
            .eraseToAnyPublisher()
    }
    
    lazy var newCommentVC = NewPostViewController(replyToPost: parsedContent?.post) { [weak self] in
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self?.reload()
        }
    }
    
    override var barsMaxTransform: CGFloat { 0 }
    
    init(content: Article) {
        self.content = content
        super.init()
        
        table.register(PostCommentsTitleCell.self, forCellReuseIdentifier: "title")
        table.isScrollEnabled = false
        DispatchQueue.main.async {
            self.table.contentInset = .zero
        }
        
        posts = content.replies
        cellHeight = posts.map { _ in 200 }
        
        navigationBorder.removeFromSuperview()
        
        reload()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func setBarsToTransform(_ transform: CGFloat) { return }
    
    override var postSection: Int { 1 }
    
    override func postForIndexPath(_ indexPath: IndexPath) -> ParsedContent? {
        if indexPath.section == postSection { return super.postForIndexPath(indexPath) }
        return parsedContent
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { 2 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            DispatchQueue.main.async {
                self.cellHeight[indexPath.row] = cell.contentView.frame.height
            }
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "title", for: indexPath)
        (cell as? PostCommentsTitleCell)?.delegate = self
        return cell
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        table.register(LongFormCommentCell.self, forCellReuseIdentifier: postCellID)
    }
    
    func reload() {
        SocketRequest(name: "long_form_content_thread_view", payload: [
            "pubkey": .string(content.event.pubkey),
            "identifier": .string(content.identifier),
            "kind": .number(Double(NostrKind.longForm.rawValue)),
            "limit": 100,
            "user_pubkey": .string(IdentityManager.instance.userHexPubkey)
        ])
        .publisher()
        .receive(on: DispatchQueue.main)
        .sink { [weak self] res in
            let article = res.getArticles().first
            self?.parsedContent = article?.asParsedContent
            
            let posts = article?.replies ?? []
            self?.cellHeight = posts.map { _ in 200 }
            self?.posts = posts
        }
        .store(in: &cancellables)
    }
}

extension LongFormCommentsController: PostCommentsTitleCellDelegate {
    func postCommentPressed() {
        newCommentVC.replyToPost = parsedContent?.post
        present(newCommentVC, animated: true)
    }
}
