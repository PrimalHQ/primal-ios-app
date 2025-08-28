//
//  LiveCommentsHeaderView.swift
//  Primal
//
//  Created by Pavle Stevanović on 22. 7. 2025..
//

import UIKit

class LiveCommentsHeaderView: UIStackView, Themeable {
    let titleLabel = UILabel("", color: .foreground, font: .appFont(withSize: 18, weight: .bold))
    let timeLabel = UILabel("Started", color: .foreground4, font: .appFont(withSize: 14, weight: .regular))
    let countIcon = UIImageView(image: .liveViewersCount)
    let countLabel = UILabel("-", color: .foreground4, font: .appFont(withSize: 14, weight: .regular))
    let liveIcon = UIView().constrainToSize(6)
    let liveLabel = UILabel("Live", color: .foreground4, font: .appFont(withSize: 14, weight: .regular))
    lazy var secondInfoRow = UIStackView([liveIcon, SpacerView(width: 4), liveLabel, SpacerView(width: 10), timeLabel, SpacerView(width: 10), countIcon, SpacerView(width: 6), countLabel])
    
    let configButton = UIButton(configuration: .simpleImage(.searchConfig.withRenderingMode(.alwaysTemplate)))
    let infoButton = UIButton(configuration: .simpleImage(.liveInfo.withRenderingMode(.alwaysTemplate)))
    let closeButton = UIButton(configuration: .simpleImage(.liveCommentsClose.scalePreservingAspectRatio(size: 16).withRenderingMode(.alwaysTemplate)))
    
    var small: Bool = false {
        didSet {
            secondInfoRow.isHidden = small
            secondInfoRow.alpha = small ? 0 : 1
            
            configButton.isHidden = small
            configButton.alpha = small ? 0 : 1
            
            infoButton.isHidden = small
            infoButton.alpha = small ? 0 : 1
            
            closeButton.isHidden = !small
            closeButton.alpha = small ? 1 : 0
            
            layoutMargins = small ? .init(top: 0, left: 16, bottom: 0, right: 4) : .init(top: 8, left: 16, bottom: 12, right: 4)
            
            alignment = small ? .center : .top
        }
    }
    
    init() {
        super.init(frame: .zero)
        countIcon.setContentCompressionResistancePriority(.required, for: .horizontal)
        let leftStack = UIStackView(axis: .vertical, [titleLabel, secondInfoRow])
        leftStack.spacing = 2
        leftStack.alignment = .leading
        
        liveIcon.backgroundColor = .live
        liveIcon.layer.cornerRadius = 3
        
        let rightStack = UIStackView([configButton, infoButton, closeButton])
        
        [leftStack, UIView(), rightStack].forEach { addArrangedSubview($0) }
        alignment = .top
        
        isLayoutMarginsRelativeArrangement = true
        insetsLayoutMarginsFromSafeArea = false
        layoutMargins = .init(top: 8, left: 16, bottom: 12, right: 4)
        
        secondInfoRow.alignment = .center
        countIcon.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        setContentHuggingPriority(.required, for: .vertical)
        
        updateTheme()
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        [configButton, infoButton, closeButton].forEach { $0.tintColor = .foreground3 }
        
        titleLabel.textColor = .foreground
        [timeLabel, countLabel, liveLabel].forEach { $0.textColor = .foreground4 }
        
        countIcon.tintColor = .foreground4
    }
}
