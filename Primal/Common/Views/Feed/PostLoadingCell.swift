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
        
        addSubview(animationView)
        animationView.pinToSuperview()
        
        animationView.widthAnchor.constraint(equalTo: animationView.heightAnchor, multiplier: 375 / 137).isActive = true
        
        animationView.animation = Theme.current.isDarkTheme ? AnimationType.postCellSkeleton.animation : AnimationType.postCellSkeletonLight.animation
        animationView.loopMode = .loop
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        animationView.play()
    }
}
