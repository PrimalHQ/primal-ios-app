//
//  MainThreadElementImageGalleryCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 31.12.24..
//

import UIKit

class MainThreadElementImageGalleryCell: FeedElementImageGalleryCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        mainImages.noDownsampling = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func update(_ content: ParsedContent) {
        if mainImages.resources.isEmpty {
            super.update(content)
        }
        threadLayout?.updateAppearance(contentView: contentView)
    }
}
