//
//  ThreadElementPollCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 4.3.26..
//

import UIKit

class ThreadElementPollCell: ThreadElementBaseCell, RegularFeedElementCell {
    static var cellID: String { "FeedElementPollCell" }

    let pollView = PollView()

    override init(position: ThreadPosition, style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: position, style: style, reuseIdentifier: reuseIdentifier)

        secondRow.addSubview(pollView)
        pollView
            .pinToSuperview(edges: .top, padding: 8)
            .pinToSuperview(edges: .bottom, padding: 0)
            .pinToSuperview(edges: .horizontal, padding: 0)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func update(_ content: ParsedContent) {
        super.update(content)

        guard content.poll != nil else { return }
        pollView.updateForContent(content)
        pollView.updateTheme()
    }
}
