//
//  LongFormZapsPostCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 21.6.24..
//

import UIKit

class LongFormZapsPostCell: PostCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let largeGallery = LargeZapGalleryView(zapTapCallback: { [weak self] in
            guard let self else { return }
            delegate?.postCellDidTap(self, .longTapZap)
        })
        zapGallery = largeGallery
        largeGallery.delegate = self
        
        contentView.addSubview(largeGallery)
        largeGallery.pinToSuperview(edges: [.top, .horizontal])
        let botC = largeGallery.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        botC.priority = .defaultHigh
        botC.isActive = true
        
        bottomBorder.removeFromSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(_ content: ParsedContent) {
        zapGallery!.zaps = content.zaps
    }
    
    override func updateMenu(_ content: ParsedContent) {
        zapGallery!.zaps = content.zaps
    }
}
