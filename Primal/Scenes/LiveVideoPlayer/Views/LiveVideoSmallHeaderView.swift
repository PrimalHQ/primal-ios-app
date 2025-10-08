//
//  LiveVideoSmallHeaderView 2.swift
//  Primal
//
//  Created by Pavle Stevanović on 2. 10. 2025..
//

import UIKit

class LiveVideoSmallHeaderView: UIStackView, Themeable {
    let titleLabel = UILabel("", color: .foreground, font: .appFont(withSize: 16, weight: .bold))
    let countIcon = UIImageView(image: .liveViewersCount)
    let countLabel = UILabel("-", color: .foreground4, font: .appFont(withSize: 14, weight: .regular))
    let liveIcon = UIView().constrainToSize(6)
    let liveLabel = UILabel("Live", color: .foreground4, font: .appFont(withSize: 14, weight: .regular))
    lazy var secondInfoRow = UIStackView([liveIcon, SpacerView(width: 4), liveLabel, SpacerView(width: 10), countIcon, SpacerView(width: 6), countLabel])
    
    init() {
        super.init(frame: .zero)
        countIcon.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        liveIcon.backgroundColor = .live
        liveIcon.layer.cornerRadius = 3
        
        titleLabel.numberOfLines = 2
        [titleLabel, secondInfoRow].forEach { addArrangedSubview($0) }
        
        axis = .vertical
        spacing = 2
        alignment = .leading
        isLayoutMarginsRelativeArrangement = true
        insetsLayoutMarginsFromSafeArea = false
        layoutMargins = .init(top: 20, left: 177, bottom: 20, right: 12)
        
        secondInfoRow.alignment = .center
        countIcon.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        setContentHuggingPriority(.required, for: .vertical)
        
        updateTheme()
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        titleLabel.textColor = .foreground
        [countLabel, liveLabel].forEach { $0.textColor = .foreground4 }
        
        countIcon.tintColor = .foreground4
    }
}
