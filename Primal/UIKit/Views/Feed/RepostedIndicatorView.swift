//
//  RepostedIndicatorView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 31.5.23..
//

import UIKit

final class RepostedIndicatorView: MyButton {
    let nameLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        let repostedLabel = UILabel()
        let repostedImageView = UIImageView(image: UIImage(named: "feedRepost")?.scalePreservingAspectRatio(size: 15).withRenderingMode(.alwaysTemplate))
        let stack = UIStackView(arrangedSubviews: [
            repostedImageView, nameLabel, repostedLabel, UIView()
        ])
        
        stack.alignment = .center
        stack.spacing = 4
        
        nameLabel.font = .appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular)
        nameLabel.textColor = .foreground3
        nameLabel.adjustsFontSizeToFitWidth = true
        
        repostedLabel.font = .appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular)
        repostedLabel.text = "reposted"
        repostedLabel.textColor = .foreground3
        
        repostedImageView.tintColor = .foreground3
        
        addSubview(stack)
        stack.pinToSuperview(edges: [.horizontal, .bottom]).pinToSuperview(edges: .top, padding: -7)
    }
    
    func update(user: PrimalUser) {
        nameLabel.text = user.firstIdentifier
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
