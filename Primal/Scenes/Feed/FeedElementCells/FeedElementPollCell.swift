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

        contentContainer.addSubview(pollView)
        pollView
            .pinToSuperview(edges: .top, padding: 8)
            .pinToSuperview(edges: .bottom, padding: 0)
            .pinToSuperview(edges: .leading, padding: leadingPadding).pinToSuperview(edges: .trailing, padding: horizontalPadding)
        
        pollView.totalVotesButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            delegate?.postCellDidTap(self, .pollVotesDetails)
        }), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func update(_ content: ParsedContent) {
        guard content.poll != nil else { return }
        pollView.updateForContent(content)
        pollView.updateTheme()
    }
}
