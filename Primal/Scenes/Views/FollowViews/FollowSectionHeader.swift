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
    let followAll = FollowButton("Follow All", "Unfollow All", colors: SunsetWave.instance.gradient)
    
    weak var delegate: FollowSectionHeaderDelegate?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setup() {
        backgroundColor = .black
        contentView.backgroundColor = UIColor(rgb: 0x181818)
        contentView.layer.cornerRadius = 8
        contentView.layer.borderColor = UIColor(rgb: 0x222222).cgColor
        contentView.layer.borderWidth = 1
        
        let stack = UIStackView(arrangedSubviews: [title, followAll])
        contentView.addSubview(stack)
        stack
            .pinToSuperview(edges: .leading, padding: 24)
            .pinToSuperview(edges: .top, padding: 16)
        
        [
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ].forEach {
            $0.priority = .defaultHigh
            $0.isActive = true
        }
        
        title.font = .appFont(withSize: 14, weight: .medium)
        title.textColor = UIColor(rgb: 0xAAAAAA)
        title.numberOfLines = 2
        
        followAll.constrainToSize(width: 106, height: 36)
        followAll.addTarget(self, action: #selector(followAllTapped), for: .touchUpInside)
        
        stack.spacing = 50
        stack.alignment = .center
    }
    
    @objc func followAllTapped() {
        followAll.isFollowing.toggle()
        delegate?.headerTappedFollowAll(self)
    }
}
