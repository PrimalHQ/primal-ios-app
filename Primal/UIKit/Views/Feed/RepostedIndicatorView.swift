//
//  RepostedIndicatorView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 31.5.23..
//

import UIKit

final class RepostedIndicatorView: UIView {
    let nameLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        let repostedLabel = UILabel()
        let repostedImageView = UIImageView(image: UIImage(named: "feedRepost"))
        let stack = UIStackView(arrangedSubviews: [
            repostedImageView, nameLabel, repostedLabel, UIView()
        ])
        
        stack.alignment = .center
        stack.spacing = 6
        
        nameLabel.font = .appFont(withSize: 16, weight: .regular)
        nameLabel.textColor = .accent
        nameLabel.adjustsFontSizeToFitWidth = true
        
        repostedLabel.font = .appFont(withSize: 16, weight: .regular)
        repostedLabel.text = "reposted"
        repostedLabel.textColor = .foreground3
        
        repostedImageView.tintColor = .foreground3
        
        addSubview(stack)
        stack.pinToSuperview()
    }
    
    func update(user: PrimalUser) {
        nameLabel.text = user.firstIdentifier
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
