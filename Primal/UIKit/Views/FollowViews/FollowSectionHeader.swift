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

class FollowSectionHeader: UITableViewHeaderFooterView {
    let title = UILabel()
    let followAll = ThinFancyButton(title: "Follow All")
    
    weak var delegate: FollowSectionHeaderDelegate?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setup() {
        contentView.backgroundColor = .black
        
        let stack = UIStackView(arrangedSubviews: [title, followAll])
        contentView.addSubview(stack)
        stack
            .pinToSuperview(edges: .horizontal, padding: 30)
            .pinToSuperview(edges: .vertical, padding: 10)
        
        title.font = .appFont(withSize: 16, weight: .regular)
        title.textColor = UIColor(rgb: 0xAAAAAA)
        title.textAlignment = .center
        
        followAll.constrainToSize(height: 36)
        followAll.addTarget(self, action: #selector(followAllTapped), for: .touchUpInside)
        
        stack.axis = .vertical
        stack.spacing = 10
    }
    
    @objc func followAllTapped() {
        delegate?.headerTappedFollowAll(self)
    }
}
