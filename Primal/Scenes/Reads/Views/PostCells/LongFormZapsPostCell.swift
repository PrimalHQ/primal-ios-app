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
        
        let largeGallery = LargeZapGalleryView()
        zapGallery = largeGallery
        largeGallery.frame = contentView.bounds
        
        largeGallery.zapPillButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            delegate?.postCellDidTap(self, .longTapZap)
        }), for: .touchUpInside)
        
        contentView.addSubview(zapGallery!)
        zapGallery!.pinToSuperview()
        
        zapGallery!.addGestureRecognizer(BindableTapGestureRecognizer(action: { [unowned self] in
            delegate?.postCellDidTap(self, .zapDetails)
        }))
        
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
