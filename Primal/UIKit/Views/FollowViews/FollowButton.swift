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
    private let b1 = UIImageView(image: UIImage(named: "followButtonBackgroundBack"))
    private let b2 = GradientBorderView(
        gradientColors: UIColor.gradient.withAlphaComponent(0.85),
        backgroundColor: .black,
        cornerRadius: 8
    )
    
    override var isPressed: Bool {
        didSet {
            titleLabel.textColor = isPressed ? .darkGray : .white
        }
    }
    
    var isFollowing: Bool = false {
        didSet {
            b1.isHidden = isFollowing
            titleLabel.textColor = isFollowing ? UIColor(rgb: 0xCCCCCC) : .white
            titleLabel.text = isFollowing ? titles.1 : titles.0
            b2.colors = isFollowing ? [UIColor(rgb: 0x444444), UIColor(rgb: 0x444444)] : UIColor.gradient.withAlphaComponent(0.85)
            b2.backgroundColor = isFollowing ? UIColor(rgb: 0x181818) : .black
        }
    }
    
    init(_ followTitle: String = "Follow", _ unfollowTitle: String = "Unfollow") {
        self.titles = (followTitle, unfollowTitle)
        super.init(frame: .zero)
        setup()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        addSubview(b1)
        addSubview(b2)
        b2.pinToSuperview()
        b1.centerToSuperview()
        b1.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 2.45).isActive = true
        b1.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.5).isActive = true
        
        addSubview(titleLabel)
        titleLabel
            .pinToSuperview(edges: .horizontal, padding: 12)
            .centerToSuperview(axis: .vertical)
        
        titleLabel.text = isFollowing ? titles.1 : titles.0
        titleLabel.font = .appFont(withSize: 16, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
//
//        backgroundColor = UIColor(rgb: 0x181818)
//        layer.borderColor = UIColor(rgb: 0x222222).cgColor
//        layer.borderWidth = 1
//        layer.cornerRadius = 12
    }
}
