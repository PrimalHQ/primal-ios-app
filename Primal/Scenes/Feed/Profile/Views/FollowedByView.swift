//
//  FollowedByView.swift
//  Primal
//
//  Created by Pavle Stevanović on 13.9.24..
//

import UIKit

class FollowedByView: UIView {
    let images = AvatarView(size: 28, spacing: -8, reversed: true, borderColor: .background)
    let label = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        let stack = UIStackView([images, label])
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
        guard let users else {
            images.isHidden = true
            label.text = ""
            
            return
        }
        images.isHidden = false
        
        images.setImages(users.reversed().compactMap { $0.profileImage.url(for: .small) }, userCount: users.count)
        label.text = "Followed by " + users.dropFirst().reduce(users.first?.data.firstIdentifier ?? "", { $0 + ", \($1.data.firstIdentifier)" })
    }
}
