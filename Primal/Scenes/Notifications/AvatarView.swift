//
//  AvatarView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 29.6.23..
//

import UIKit
import Kingfisher

final class AvatarView: UIView {
    let avatarViews = (1...6).map { _ in UIImageView() }
    let extraView = UIView()
    let extraLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImages(_ images: [URL], userCount: Int) {
        for view in avatarViews { view.isHidden = true }
        
        zip(avatarViews, images).forEach { view, url in
            view.isHidden = false
            view.kf.setImage(with: url, placeholder: UIImage(named: "Profile"), options: [
                .processor(DownsamplingImageProcessor(size: CGSize(width: 32, height: 32))),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ])
        }
        
        if images.isEmpty, let first = avatarViews.first {
            first.image = UIImage(named: "Profile")
            first.isHidden = false
        }
        
        let imagesCount = images.count.clamp(1, avatarViews.count)
        extraView.isHidden = imagesCount >= userCount
        let extraCount = min(userCount - imagesCount, 99)
        extraLabel.text = "+\(extraCount)"
    }
}

private extension AvatarView {
    func setup() {
        let stack = UIStackView(arrangedSubviews: avatarViews + [extraView])
        
        avatarViews.forEach {
            $0.contentMode = .scaleAspectFill
            $0.backgroundColor = .background
        }
        
        stack.arrangedSubviews.forEach {
            $0.constrainToSize(32)
            $0.layer.cornerRadius = 16
            $0.layer.masksToBounds = true
        }
        
        stack.spacing = 4
        
        extraView.addSubview(extraLabel)
        extraLabel.centerToSuperview().pinToSuperview(edges: .horizontal, padding: 2)
        
        extraLabel.textAlignment = .center
        extraLabel.adjustsFontSizeToFitWidth = true
        extraLabel.textColor = .foreground3
        extraLabel.font = .appFont(withSize: 12, weight: .semibold)
        
        extraView.backgroundColor = .foreground6
        
        addSubview(stack)
        stack.pinToSuperview()
        
        constrainToSize(height: 32)
    }
}
