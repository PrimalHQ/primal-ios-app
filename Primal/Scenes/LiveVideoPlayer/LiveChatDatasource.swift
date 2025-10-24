//
//  LiveChatDatasource.swift
//  Primal
//
//  Created by Pavle Stevanović on 16. 10. 2025..
//

import UIKit
import Nantes

enum LiveChatCellType: Hashable {
    case message(ParsedLiveComment)
}

class LiveChatDatasource: UITableViewDiffableDataSource<SingleSection, LiveChatCellType> {
    var comments: [ParsedLiveComment] = [] { didSet { updateCells(animate: false) } }
    
    @Published var cellHeightArray: [CGFloat] = []
    
    init(tableView: UITableView, delegate: NantesLabelDelegate) {        
        super.init(tableView: tableView) { [weak delegate] tableView, indexPath, item in
            switch item {
            case .message(let comment):
                let cell = tableView.dequeueReusableCell(withIdentifier: comment.zapAmount > 0 ? "zapCell" : "cell", for: indexPath)
                if comment.zapAmount > 0 {
                    (cell as? LiveVideoChatZapCell)?.updateForComment(comment, delegate: delegate)
                } else {
                    (cell as? LiveVideoChatMessageCell)?.updateForComment(comment, delegate: delegate)
                }
                return cell
            }
        }
        
        setupTable(tableView)
        
        defaultRowAnimation = .fade
        
        updateCells(animate: false)
    }
    
    func setupTable(_ table: UITableView) {
        table.backgroundColor = .background
        table.register(LiveVideoChatMessageCell.self, forCellReuseIdentifier: "cell")
        table.register(LiveVideoChatZapCell.self, forCellReuseIdentifier: "zapCell")
        table.showsVerticalScrollIndicator = false
        table.separatorStyle = .none
        table.keyboardDismissMode = .onDrag
        table.contentInsetAdjustmentBehavior = .never
    }
    
    func updateCells(animate: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection, LiveChatCellType>()
        
        snapshot.appendSections([.main])
        snapshot.appendItems(
            comments.unique()
                .sorted(by: { $0.createdAt > $1.createdAt })
                .map({ .message($0) })
        )
        
        apply(snapshot, animatingDifferences: animate)
    }
}
