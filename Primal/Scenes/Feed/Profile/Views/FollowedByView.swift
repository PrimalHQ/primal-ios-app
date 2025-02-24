//
//  FollowedByView.swift
//  Primal
//
//  Created by Pavle Stevanović on 13.9.24..
//

import UIKit

class FollowedByView: UIView {
    let images = (0...4).map { _ in UserImageView(height: 28) }
    lazy var imagesStack = UIStackView(images)
    let label = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        imagesStack.spacing = -8
        imagesStack.transform = .init(rotationAngle: .pi)
        
        images.forEach { $0.transform = .init(rotationAngle: .pi) }
        
        let stack = UIStackView([imagesStack, label])
        addSubview(stack)
        stack.pinToSuperview(edges: .horizontal).centerToSuperview()
        stack.spacing = 6
        stack.alignment = .center
        
        label.font = .appFont(withSize: 12, weight: .regular)
        label.textColor = .foreground4
        label.numberOfLines = 2
        
        constrainToSize(height: 28)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUsers(_ users: [ParsedUser]?) {
        guard var users else {
            imagesStack.isHidden = true
            label.text = ""
            
            return
        }
        
        users = users.filter { PremiumCustomizationManager.instance.getCustomization(pubkey: $0.data.pubkey) != nil } + users.filter {
            PremiumCustomizationManager.instance.getCustomization(pubkey: $0.data.pubkey) == nil
        }
        
        imagesStack.isHidden = false
        
        images.forEach { $0.isHidden = true }
        
        zip(users.reversed(), images).forEach { user, image in
            image.setUserImage(user)
            image.isHidden = false
        }
        
        label.text = "Followed by " + users.dropFirst().reduce(users.first?.data.firstIdentifier ?? "", { $0 + ", \($1.data.firstIdentifier)" })
    }
}
