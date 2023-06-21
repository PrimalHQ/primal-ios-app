//
//  HashtagCollectionViewCell.swift
//  Primal
//
//  Created by Pavle D Stevanović on 20.6.23..
//

import UIKit

final class HashtagCollectionViewCell: UICollectionViewCell {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
        label.centerToSuperview().pinToSuperview(edges: .horizontal, padding: 20)

        label.font = .appFont(withSize: 18, weight: .medium)
        label.textColor = .foreground
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        backgroundColor = .background3
        layer.cornerRadius = 16
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
