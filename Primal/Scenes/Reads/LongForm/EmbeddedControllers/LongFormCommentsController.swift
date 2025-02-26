//
//  LongFormCommentsController.swift
//  Primal
//
//  Created by Pavle Stevanović on 30.5.24..
//

import Combine
import UIKit

class LongFormCommentsController: NoteViewController {
    let content: Article
    var parsedContent: ParsedContent?
    
    @Published private var cellHeight: [CGFloat] = []
    
    var viewHeight: AnyPublisher<CGFloat, Never> {
        $cellHeight
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .map { $0.reduce(0, +) + 100 }
            .eraseToAnyPublisher()
    }
    
    lazy var newCommentVC = NewPostViewController(replyToPost: parsedContent?.post) { [weak self] in
        for seconds in 1...3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds)) {
                self?.reload()
            }
        }
    }
    
    override var barsMaxTransform: CGFloat { 0 }
    
    init(content: Article) {
        self.content = content
        super.init()
        
        table.register(GenericEmptyTableCell.self, forCellReuseIdentifier: "empty")
        table.register(PostCommentsTitleCell.self, forCellReuseIdentifier: "title")
        table.isScrollEnabled = false
        DispatchQueue.main.async {
            self.table.contentInset = .zero
        }
        
        dataSource = ArticleCommentsDatasource(tableView: table, delegate: self)
        
        posts = content.replies
        cellHeight = posts.map { _ in 200 }
        
        navigationBorder.removeFromSuperview()
        
        reload()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func setBarsToTransform(_ transform: CGFloat) { return }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        
        guard indexPath.section == 1 else { return }
            
        DispatchQueue.main.async {
            while self.cellHeight.count <= indexPath.row { self.cellHeight.append(30) }
            
            self.cellHeight[safe: indexPath.row] = cell.contentView.frame.height
        }
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
            
            posts.forEach { $0.replyingTo = nil }
            
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

class GenericEmptyTableCell: UITableViewCell, Themeable {
    var text = "" {
        didSet {
            label.text = text
            updateTheme()
        }
    }
    
    private let label = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        contentView.addSubview(label)
        label.pinToSuperview(edges: .vertical, padding: 100).pinToSuperview(edges: .horizontal, padding: 60)
        
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .appFont(withSize: 14, weight: .regular)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        label.textColor = .foreground2
    }
}
