//
//  FollowButton.swift
//  Primal
//
//  Created by Pavle D Stevanović on 29.4.23..
//

import UIKit

final class FollowButton: MyButton {
    var titles: (String, String) {
        didSet {
            titleLabel.text = isFollowing ? titles.1 : titles.0
        }
    }
    
    let titleLabel = UILabel()
    
    override var isPressed: Bool {
        didSet {
            alpha = isPressed ? 0.5 : 1
        }
    }
    
    var isFollowing: Bool = false {
        didSet {
            titleLabel.textColor = isFollowing ? UIColor(rgb: 0x111111) : .white
            titleLabel.text = isFollowing ? titles.1 : titles.0
            
            backgroundColor = isFollowing ? isFollowingBackgroundColor : .black
        }
    }
    
    let isFollowingBackgroundColor: UIColor
    
    init(_ followTitle: String = "follow", _ unfollowTitle: String = "unfollow", backgroundColor: UIColor = .white) {
        self.titles = (followTitle, unfollowTitle)
        isFollowingBackgroundColor = backgroundColor
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        addSubview(titleLabel)
        titleLabel.centerToSuperview()
        
        titleLabel.font = .appFont(withSize: 14, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        
        titleLabel.text = isFollowing ? titles.1 : titles.0
        titleLabel.textColor = isFollowing ? UIColor(rgb: 0x111111) : .white
        backgroundColor = isFollowing ? isFollowingBackgroundColor : .black
        
        layer.cornerRadius = 16
    }
}
