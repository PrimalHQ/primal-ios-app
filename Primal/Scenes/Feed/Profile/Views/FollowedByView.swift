//
//  FollowedByView.swift
//  Primal
//
//  Created by Pavle Stevanović on 13.9.24..
//

import UIKit
import Lottie

class FollowedByView: UIView {
    let images = AvatarView(size: 28, spacing: -8, reversed: true, bordered: true)
    let label = UILabel()
    
    let imagesLoadingView = LottieAnimationView(animation: Theme.current.isDarkTheme ? AnimationType.smallPillLoader.animation : AnimationType.smallPillLoaderLight.animation).constrainToSize(width: 65, height: 28)
    let labelLoadingView = LottieAnimationView(animation: Theme.current.isDarkTheme ? AnimationType.smallPillLoader.animation : AnimationType.smallPillLoaderLight.animation).constrainToSize(width: 65, height: 28)
    
    init() {
        super.init(frame: .zero)
        
        let stack = UIStackView([images, label])
        addSubview(stack)
        stack.pinToSuperview(edges: .horizontal).centerToSuperview()
        stack.spacing = 6
        stack.alignment = .center
        
        label.font = .appFont(withSize: 12, weight: .regular)
        label.textColor = .foreground4
        label.numberOfLines = 2
        
        addSubview(imagesLoadingView)
        addSubview(labelLoadingView)
        
        imagesLoadingView.centerToSuperview(axis: .vertical).pinToSuperview(edges: .leading, padding: 31)
        labelLoadingView.centerToSuperview(axis: .vertical).pinToSuperview(edges: .leading, padding: 160)
        
        imagesLoadingView.transform = .init(scaleX: 2, y: 1)
        labelLoadingView.transform = .init(scaleX: 2, y: 1)
        
        imagesLoadingView.isHidden = true
        labelLoadingView.isHidden = true
        imagesLoadingView.loopMode = .loop
        labelLoadingView.loopMode = .loop
        
        constrainToSize(height: 28)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUsers(_ users: [ParsedUser]?) {
        guard let users else {
            images.isHidden = true
            label.text = ""
            
            imagesLoadingView.isHidden = false
            labelLoadingView.isHidden = false
            imagesLoadingView.play()
            labelLoadingView.play()
            return
        }
        images.isHidden = false
        imagesLoadingView.isHidden = true
        labelLoadingView.isHidden = true
        
        images.setImages(users.reversed().compactMap { $0.profileImage.url(for: .small) }, userCount: users.count)
        label.text = "Followed by " + users.dropFirst().reduce(users.first?.data.firstIdentifier ?? "", { $0 + ", \($1.data.firstIdentifier)" })
    }
}
