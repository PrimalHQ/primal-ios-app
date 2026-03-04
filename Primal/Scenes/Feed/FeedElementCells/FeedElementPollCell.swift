//
//  FeedElementPollCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 4.3.26..
//

import UIKit

class FeedElementPollCell: FeedElementBaseCell, RegularFeedElementCell {
    static var cellID: String { "FeedElementPollCell" }

    let pollView = PollView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(pollView)
        pollView
            .pinToSuperview(edges: .top, padding: 8)
            .pinToSuperview(edges: .bottom, padding: 0)
            .pinToSuperview(edges: .horizontal, padding: 16)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func update(_ content: ParsedContent) {
        guard let poll = content.poll else { return }
        pollView.updateForPoll(poll)
        pollView.updateTheme()
    }
}
