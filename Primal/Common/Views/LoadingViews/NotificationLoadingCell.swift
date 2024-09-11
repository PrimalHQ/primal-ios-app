//
//  NotificationLoadingCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.9.24..
//

import UIKit
import Lottie

class NotificationLoadingCell: UITableViewCell {
    let animationView = LottieAnimationView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        addSubview(animationView)
        animationView
            .pinToSuperview()
            .constrainToAspect(1125 / 447)
        
        animationView.animation = Theme.current.isDarkTheme ? AnimationType.notificationSkeleton.animation : AnimationType.notificationSkeletonLight.animation
        animationView.loopMode = .loop
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        animationView.play()
    }
}
