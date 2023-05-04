//
//  FollowButton.swift
//  Primal
//
//  Created by Pavle D Stevanović on 29.4.23..
//

import UIKit

class FollowButton: MyButton {
    let titleLabel = UILabel()
    
    private let b1 = UIImageView(image: UIImage(named: "thinButtonBackgroundBack"))
    private let b2 = UIImageView(image: UIImage(named: "followButtonBackgroundFront"))
    
    override var isPressed: Bool {
        didSet {
            titleLabel.textColor = isPressed ? .darkGray : .white
        }
    }
    
    var isFollowing: Bool = false {
        didSet {
            b1.isHidden = isFollowing
            b2.isHidden = isFollowing
            titleLabel.textColor = isFollowing ? UIColor(rgb: 0xCCCCCC) : .white
            titleLabel.text = isFollowing ? "Unfollow" : "Follow"
            layer.borderWidth = isFollowing ? 1 : 0
            backgroundColor = isFollowing ? UIColor(rgb: 0x181818) : .clear
        }
    }
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        addSubview(b1)
        addSubview(b2)
        b1.pinToSuperview(edges: .horizontal, padding: -7).pinToSuperview(edges: .vertical, padding: -16)
        b2.pinToSuperview()
        
        addSubview(titleLabel)
        titleLabel
            .pinToSuperview(edges: .horizontal, padding: 12)
            .centerToSuperview(axis: .vertical)
        
        titleLabel.text = "Follow"
        titleLabel.font = .appFont(withSize: 16, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        
        backgroundColor = UIColor(rgb: 0x181818)
        layer.borderColor = UIColor(rgb: 0x222222).cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 12
        
        constrainToSize(width: 88, height: 36)
    }
}
