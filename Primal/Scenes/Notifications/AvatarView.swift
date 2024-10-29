//
//  AvatarView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 29.6.23..
//

import UIKit
import Kingfisher

final class AvatarView: UIView {
    lazy var avatarViews = (1...maxAvatarCount).map { _ in UIImageView() }
    let extraView = UIView()
    let extraLabel = UILabel()
    
    let maxAvatarCount: Int
    let size: CGFloat
    let spacing: CGFloat
    
    func setBorderColor(_ borderColor: UIColor? = nil) {
        avatarViews.forEach {
            if let borderColor {
                $0.layer.borderWidth = 1
                $0.layer.borderColor = borderColor.cgColor
            } else {
                $0.layer.borderWidth = 0
            }
        }
    }
    
    init(size: CGFloat = 32, spacing: CGFloat = 4, reversed: Bool = false, borderColor: UIColor? = nil, maxAvatarCount: Int = 6) {
        self.size = size
        self.spacing = spacing
        self.maxAvatarCount = maxAvatarCount
        super.init(frame: .zero)
        transform = reversed ? .init(rotationAngle: .pi) : .identity
        
        setBorderColor(borderColor)
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
                .processor(DownsamplingImageProcessor(size: CGSize(width: size, height: size))),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
            ])
        }
        
        if images.isEmpty, let first = avatarViews.first {
            first.image = UIImage(named: "Profile")
            first.isHidden = false
        }
        
        let imagesCount = images.count.clamp(1, avatarViews.count)
        
        if imagesCount >= userCount {
            extraView.isHidden = true
        } else {
            let extraCount = min(userCount - imagesCount, 99)
            extraView.isHidden = false
            extraLabel.text = "+\(extraCount)"
            avatarViews.last?.isHidden = true
        }
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
            $0.constrainToSize(size)
            $0.layer.cornerRadius = size / 2
            $0.layer.masksToBounds = true
            $0.transform = transform
        }
        
        stack.spacing = spacing
        
        extraView.addSubview(extraLabel)
        extraLabel.centerToSuperview().pinToSuperview(edges: .horizontal, padding: 2)
        
        extraLabel.textAlignment = .center
        extraLabel.adjustsFontSizeToFitWidth = true
        extraLabel.textColor = .foreground3
        extraLabel.font = .appFont(withSize: 12, weight: .semibold)
        
        extraView.backgroundColor = .foreground6
        
        addSubview(stack)
        stack.pinToSuperview()
        
        constrainToSize(height: size)
    }
}
