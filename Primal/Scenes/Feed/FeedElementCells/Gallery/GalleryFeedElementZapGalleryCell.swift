//
//  GalleryFeedElementZapGalleryCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 1.4.26..
//

import UIKit

class GalleryFeedElementZapGalleryCell: UITableViewCell, RegularFeedElementCell {
    static var cellID: String { galleryCellID }
    static let galleryCellID = "GalleryFeedElementZapGalleryCell"

    weak var delegate: FeedElementCellDelegate?

    var lastContentId: String?
    let gallery = SmallZapGalleryView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .background2

        gallery.singleLine = true
        gallery.delegate = self

        contentView.addSubview(gallery)
        gallery
            .pinToSuperview(edges: .top, padding: 4)
            .pinToSuperview(edges: .bottom, padding: 1)
            .pinToSuperview(edges: .leading, padding: 16).pinToSuperview(edges: .trailing, padding: 16)

        gallery.addGestureRecognizer(BindableTapGestureRecognizer(action: { [unowned self] in
            delegate?.postCellDidTap(self, .zapDetails)
        }))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func update(_ parsedContent: ParsedContent) {
        if parsedContent.post.id != lastContentId {
            gallery.setZaps([])
            lastContentId = parsedContent.post.id
        }

        gallery.setZaps(parsedContent.zaps)
    }
}

extension GalleryFeedElementZapGalleryCell: ZapGalleryViewDelegate {
    func menuConfigurationForZap(_ zap: ParsedZap) -> UIContextMenuConfiguration? {
        delegate?.menuConfigurationForZap(zap)
    }

    func mainActionForZap(_ zap: ParsedZap) {
        delegate?.mainActionForZap(zap)
    }

    func zapTapped(_ zap: ParsedZap) {
        delegate?.postCellDidTap(self, .zapDetails)
    }
}
