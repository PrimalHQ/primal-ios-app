//
//  FollowSectionHeader.swift
//  Primal
//
//  Created by Pavle D Stevanović on 29.4.23..
//

import UIKit

protocol FollowSectionHeaderDelegate: AnyObject {
    func headerTappedFollowAll(_ header: FollowSectionHeader)
}

final class FollowSectionHeader: UITableViewHeaderFooterView {
    let title = UILabel()
    let followAll = FollowButton("follow all", "unfollow all")
    
    weak var delegate: FollowSectionHeaderDelegate?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setup() {
        contentView.backgroundColor = .init(rgb: 0xDDC5DF)//.withAlphaComponent(0.9)
        backgroundConfiguration = .clear()
        
        let stack = UIStackView(arrangedSubviews: [title, followAll])
        contentView.addSubview(stack)
        stack
            .pinToSuperview(edges: .leading, padding: 16)
            .pinToSuperview(edges: .top, padding: 14)
        
        [
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ].forEach {
            $0.priority = .defaultHigh
            $0.isActive = true
        }
        
        title.font = .appFont(withSize: 14, weight: .semibold)
        title.textColor = UIColor(rgb: 0x111111)
        title.numberOfLines = 2
        
        followAll.constrainToSize(width: 108, height: 32)
        followAll.addTarget(self, action: #selector(followAllTapped), for: .touchUpInside)
        
        stack.spacing = 8
        stack.alignment = .center
    }
    
    @objc func followAllTapped() {
        followAll.isFollowing.toggle()
        delegate?.headerTappedFollowAll(self)
    }
}
