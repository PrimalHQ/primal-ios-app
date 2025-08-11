//
//  LiveCommentsHeaderView.swift
//  Primal
//
//  Created by Pavle Stevanović on 22. 7. 2025..
//

import UIKit

class LiveCommentsHeaderView: UIStackView {
    let timeLabel = UILabel("Started", color: .foreground4, font: .appFont(withSize: 14, weight: .regular))
    let countIcon = UIImageView(image: .liveViewersCount)
    let countLabel = UILabel("-", color: .foreground4, font: .appFont(withSize: 14, weight: .regular))
    lazy var secondInfoRow = UIStackView([timeLabel, SpacerView(width: 12), countIcon, SpacerView(width: 6), countLabel])
    
    let configButton = UIButton(configuration: .simpleImage(.searchConfig))
    let closeButton = UIButton(configuration: .simpleImage(.liveCommentsClose))
    
    var small: Bool = false {
        didSet {
            secondInfoRow.isHidden = small
            secondInfoRow.alpha = small ? 0 : 1
            
            configButton.isHidden = small
            configButton.alpha = small ? 0 : 1
            
            layoutMargins = small ? .init(top: 0, left: 16, bottom: 0, right: 4) : .init(top: 12, left: 16, bottom: 12, right: 4)
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        let titleLabel = UILabel("Live chat", color: .foreground, font: .appFont(withSize: 18, weight: .bold))
        countIcon.tintColor = .foreground4
        countIcon.setContentCompressionResistancePriority(.required, for: .horizontal)
        let leftStack = UIStackView(axis: .vertical, [titleLabel, secondInfoRow])
        leftStack.spacing = 3
        leftStack.alignment = .leading
        
        let rightStack = UIStackView([configButton, closeButton])
        
        [leftStack, UIView(), rightStack].forEach { addArrangedSubview($0) }
        alignment = .center
        
        isLayoutMarginsRelativeArrangement = true
        insetsLayoutMarginsFromSafeArea = false
        layoutMargins = .init(top: 12, left: 16, bottom: 12, right: 4)
        
        [configButton, closeButton].forEach { $0.tintColor = .foreground3 }
        
        secondInfoRow.alignment = .center
        countIcon.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        setContentHuggingPriority(.required, for: .vertical)
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
