//
//  LongFormZapsPostCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 21.6.24..
//

import UIKit

class LiveVideoZapsPostCell: LongFormZapsPostCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        largeGallery.zappingType = "stream"
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class LongFormZapsPostCell: FeedElementBaseCell, RegularFeedElementCell {    
    static var cellID: String { "LongFormZapsPostCell" }
    
    lazy var largeGallery = LargeZapGalleryView(zapTapCallback: { [weak self] in
        guard let self else { return }
        delegate?.postCellDidTap(self, .longTapZap)
    })
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        largeGallery.delegate = self
        
        largeGallery.addGestureRecognizer(BindableTapGestureRecognizer(action: { [unowned self] in
            delegate?.postCellDidTap(self, .zapDetails)
        }))
        
        contentView.addSubview(largeGallery)
        largeGallery.pinToSuperview(edges: [.top, .horizontal])
        let botC = largeGallery.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        botC.priority = .defaultHigh
        botC.isActive = true
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func update(_ content: ParsedContent) {
        largeGallery.setZaps(content.zaps)
    }
}

extension LongFormZapsPostCell: ZapGalleryViewDelegate {
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
