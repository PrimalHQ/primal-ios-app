//
//  HashtagCollectionViewCell.swift
//  Primal
//
//  Created by Pavle D Stevanović on 20.6.23..
//

import UIKit

final class HashtagCollectionViewCell: UICollectionViewCell, Themeable {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
        label.centerToSuperview().pinToSuperview(edges: .horizontal, padding: 20)

        label.font = .appFont(withSize: 18, weight: .medium)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        layer.cornerRadius = 16
        
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        label.textColor = .foreground
        backgroundColor = .background3
    }
}
