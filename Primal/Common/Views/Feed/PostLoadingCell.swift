//
//  PostLoadingCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 21.4.24..
//

import UIKit
import Lottie

class PostLoadingCell: UITableViewCell {
    let animationView = LottieAnimationView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        contentView.addSubview(animationView)
        animationView
            .pinToSuperview(edges: .horizontal)
            .pinToSuperview(edges: .vertical, padding: 10)
            .constrainToAspect(1125 / 445)
        
        animationView.animation = Theme.current.isDarkTheme ? AnimationType.postCellSkeleton.animation : AnimationType.postCellSkeletonLight.animation
        animationView.loopMode = .loop
        
        contentView.backgroundColor = .background2
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        animationView.play()
    }
}
