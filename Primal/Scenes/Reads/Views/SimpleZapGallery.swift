//
//  UserGalleryView.swift
//  Primal
//
//  Created by Pavle Stevanović on 5.6.24..
//

import FLAnimatedImage
import UIKit

class UserGalleryView: UIView {
    let stack = UIStackView()
    
    init() {
        super.init(frame: .zero)
        
        addSubview(stack)
        stack.pinToSuperview()
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    var users: [ParsedUser] = [] {
        didSet {
            update()
        }
    }
        
    func update() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        users.prefix(3).enumerated().forEach { (index, user) in
            let view = UserAvatarView(user: user)
            view.layer.zPosition = CGFloat(999 - index)
            stack.addArrangedSubview(view)
        }
    }
}

class UserAvatarView: UIView {
    let image = UserImageView(height: 22, showLegendGlow: false)
    
    init(user: ParsedUser) {
        super.init(frame: .zero)
        
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 11
        image.layer.masksToBounds = true
        
        image.setUserImage(user, disableAnimated: true)
        
        let imageBackground = UIView().constrainToSize(24)
        imageBackground.layer.cornerRadius = 12
        imageBackground.backgroundColor = UIColor.background
        imageBackground.addSubview(image)
        image.pinToSuperview(padding: 1)
        
        addSubview(imageBackground)
        imageBackground.pinToSuperview(edges: [.vertical, .trailing]).pinToSuperview(edges: .leading, padding: -6)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
