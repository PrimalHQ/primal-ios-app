//
//  UserPickerCollectionViewCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 14.10.24..
//

import UIKit
import FLAnimatedImage

class UserPickerCollectionViewCell: UICollectionViewCell {
    let image = UserImageView(height: 36)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(image)
        image.pinToSuperview(edges: [.top, .leading])
        
        let xIcon = UIImageView(image: UIImage(named: "xIcon10"))
        xIcon.tintColor = .foreground2
        let xIconParent = UIView().constrainToSize(20)
        xIconParent.layer.cornerRadius = 10
        xIconParent.backgroundColor = .background4
        xIconParent.addSubview(xIcon)
        xIcon.centerToSuperview()
        
        contentView.addSubview(xIconParent)
        xIconParent.pinToSuperview(edges: [.bottom, .trailing])
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setupWithUser(_ user: ParsedUser) {
        image.setUserImage(user)
    }
}
