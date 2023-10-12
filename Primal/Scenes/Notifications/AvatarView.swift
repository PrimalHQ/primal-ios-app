//
//  AvatarView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 29.6.23..
//

import UIKit
import Kingfisher

final class AvatarView: UIView {
    let avatarViews = (1...10).map { _ in UIImageView() }
    let extraView = UIView()
    let extraLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImages(_ images: [URL]) {
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
        
        extraView.isHidden = images.count <= 10
        let extraCount = min(images.count - 10, 99)
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
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.white.cgColor
        }
        
        stack.spacing = -8
        stack.alignment = .top
        
        extraView.addSubview(extraLabel)
        extraLabel.centerToSuperview().pinToSuperview(edges: .horizontal, padding: 2)
        
        extraLabel.textAlignment = .center
        extraLabel.adjustsFontSizeToFitWidth = true
        extraLabel.textColor = .foreground2
        extraLabel.font = .appFont(withSize: 14, weight: .medium)
        
        extraView.backgroundColor = .init(rgb: 0xC8C8C8)
        
        addSubview(stack)
        stack.pinToSuperview(edges: [.leading, .vertical])
        
        constrainToSize(height: 32)
    }
}
