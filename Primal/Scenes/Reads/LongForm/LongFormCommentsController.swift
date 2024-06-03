//
//  LongFormCommentsController.swift
//  Primal
//
//  Created by Pavle Stevanović on 30.5.24..
//

import Combine
import UIKit

class LongFormCommentsController: FeedViewController {
    let content: ParsedLongFormPost
    
    @Published private var cellHeight: [CGFloat] = []
    
    var viewHeight: AnyPublisher<CGFloat, Never> {
        $cellHeight
            .map { $0.reduce(0, +) + 60 + 90 }
            .eraseToAnyPublisher()
    }
    
    override var barsMaxTransform: CGFloat { 0 }
    
    var tabSelectionView = TabSelectionView(tabs: ["COMMENTS", "HIGHLIGHTS", "CURATIONS"])
    
    init(content: ParsedLongFormPost) {
        self.content = content
        super.init()
        
        posts = content.replies
        cellHeight = posts.map { _ in 200 }
        
        navigationBorder.removeFromSuperview()
        
        stack.insertArrangedSubview(tabSelectionView, at: 0)
        
        let border = ThemeableView().setTheme({ $0.backgroundColor = .background3 }).constrainToSize(height: 1)
        stack.insertArrangedSubview(border, at: 1)
        
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
            let posts = res.getLongFormPosts().first?.replies ?? []
            self?.cellHeight = posts.map { _ in 200 }
            self?.posts = posts
        }
        .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func setBarsToTransform(_ transform: CGFloat) { return }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        DispatchQueue.main.async {
            self.cellHeight[indexPath.row] = cell.contentView.frame.height
        }
        return cell
    }
}
