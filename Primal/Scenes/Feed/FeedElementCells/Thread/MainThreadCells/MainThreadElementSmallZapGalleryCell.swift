//
//  MainThreadElementSmallZapGalleryCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 11.12.24..
//

import UIKit

class MainThreadElementSmallZapGalleryCell: FeedElementSmallZapGalleryCell {
    let threadLayout = ThreadLayout(position: .main)
    override var contentContainer: UIView { threadLayout.secondRow }
    override var horizontalPadding: CGFloat { 0 }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        threadLayout.install(in: contentView)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func update(_ parsedContent: ParsedContent) {
        super.update(parsedContent)
        threadLayout.updateAppearance(contentView: contentView)
    }

    override func updateTheme() {
        super.updateTheme()
        threadLayout.updateAppearance(contentView: contentView)
    }
}
