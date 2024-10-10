//
//  RepostedIndicatorView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 31.5.23..
//

import UIKit

final class RepostedIndicatorView: MyButton {
    let nameLabel = UILabel()
    let repostedLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        let repostedImageView = UIImageView(image: UIImage(named: "feedRepost")?.scalePreservingAspectRatio(size: 14).withRenderingMode(.alwaysTemplate))
        let stack = UIStackView(arrangedSubviews: [
            repostedImageView, nameLabel, repostedLabel, SpacerView(width: 20, priority: .required), UIView()
        ])
        
        stack.alignment = .center
        stack.spacing = 4
        
        nameLabel.font = .appFont(withSize: 14, weight: .regular)
        nameLabel.textColor = .foreground3
        nameLabel.lineBreakMode = .byTruncatingMiddle
        
        repostedLabel.font = .appFont(withSize: 14, weight: .regular)
        repostedLabel.text = "reposted"
        repostedLabel.textColor = .foreground3
        
        repostedImageView.tintColor = .foreground3
        
        addSubview(stack)
        stack.pinToSuperview(edges: [.horizontal, .bottom]).pinToSuperview(edges: .top, padding: -6)
    }
    
    func update(users: [ParsedUser]) {
        nameLabel.text = users.first?.data.firstIdentifier
        
        let set = Set(users.map { $0.data.id })
        
        if set.count < 2 {
            repostedLabel.text = "reposted"
        } else if set.count == 2 {
            repostedLabel.text = "and 1 other reposted"
        } else {
            repostedLabel.text = "and \(set.count - 1) others reposted"
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
