//
//  ExplorePeopleCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 7.10.24..
//

import UIKit
import FLAnimatedImage
import Kingfisher

final class ExplorePeopleCell: UITableViewCell, Themeable {
    let avatar = FLAnimatedImageView()
    
    let name = UILabel()
    let subname = UILabel()
    let desc = UILabel()

    let followCount = UILabel()
    let followDesc = UILabel()
    
    let action = ExplorePeopleCellButton()
    
    let background = UIView()
    
    weak var delegate: ProfileFollowCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateForUser(_ user: ParsedUser) {
        name.text = user.data.firstIdentifier
        desc.text = user.data.about
        
        if CheckNip05Manager.instance.isVerified(user.data) {
            subname.text = user.data.parsedNip
            subname.isHidden = user.data.parsedNip.isEmpty
        } else {
            subname.isHidden = true
        }
        
        desc.isHidden = user.data.about.isEmpty
        
        followCount.text = (user.followers ?? 0).localized()
        
        action.isFollowing = FollowManager.instance.isFollowing(user.data.pubkey)
        
        action.alpha = user.isCurrentUser ? 0.01 : 1
        action.isEnabled = !user.isCurrentUser
        
        avatar.setUserImage(user, feed: true, size: CGSize(width: 64, height: 64))
        
        updateTheme()
    }
    
    func updateTheme() {
        name.textColor = .foreground
        subname.textColor = .foreground4
        desc.textColor = .foreground
        
        followCount.textColor = .foreground
        followDesc.textColor = .foreground5
        
        background.backgroundColor = .background5
        
        action.updateTheme()
    }
}

private extension ExplorePeopleCell {
    func setup() {
        selectionStyle = .none
        
        let mainVStack = UIStackView(axis: .vertical, [name, subname, desc])
        mainVStack.setCustomSpacing(4, after: name)
        mainVStack.setCustomSpacing(8, after: subname)
        
        let firstRow = UIStackView([avatar, mainVStack])
        firstRow.alignment = .top
        firstRow.spacing = 12
        
        let secondRow = UIStackView([action, followCount, followDesc, UIView()])
        secondRow.setCustomSpacing(12, after: action)
        secondRow.spacing = 4
        secondRow.alignment = .center
        
        contentView.addSubview(background)
        background.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .bottom, padding: 12).pinToSuperview(edges: .top)
        
        background.addSubview(firstRow)
        firstRow.pinToSuperview(edges: [.horizontal, .top], padding: 12)
        
        background.addSubview(secondRow)
        secondRow.pinToSuperview(edges: [.horizontal, .bottom], padding: 12)
        
        let joinC = firstRow.bottomAnchor.constraint(equalTo: secondRow.topAnchor)
        joinC.priority = .defaultLow
        
        NSLayoutConstraint.activate([
            action.topAnchor.constraint(greaterThanOrEqualTo: avatar.bottomAnchor, constant: 18),
            followCount.topAnchor.constraint(greaterThanOrEqualTo: desc.bottomAnchor, constant: 8)
        ])
        
        background.layer.cornerRadius = 8
        
        avatar.constrainToSize(64)
        avatar.contentMode = .scaleAspectFill
        avatar.layer.cornerRadius = 32
        avatar.layer.masksToBounds = true
        
        name.font = .appFont(withSize: 18, weight: .semibold)
        subname.font = .appFont(withSize: 14, weight: .regular)
        desc.font = .appFont(withSize: 13, weight: .regular)
        desc.numberOfLines = 2
        
        followCount.font = .appFont(withSize: 12, weight: .bold)
        followDesc.font = .appFont(withSize: 12, weight: .regular)
        
        followDesc.text = "Followers"
        
        action.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            self.action.isFollowing.toggle()
            self.delegate?.followButtonPressedInCell(self)
        }), for: .touchUpInside)
        
        updateTheme()
    }
}

final class ExplorePeopleCellButton: UIButton, Themeable {
    var isFollowing = true {
        didSet {
            updateTheme()
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        constrainToSize(width: 64, height: 28)
        
        titleLabel?.font = .appFont(withSize: 12, weight: .semibold)
        layer.cornerRadius = 14
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        setTitle(isFollowing ? "unfollow" : "follow", for: .normal)
        setTitleColor(isFollowing ? .foreground : .background2, for: .normal)
        setTitleColor((isFollowing ? UIColor.foreground : .background2).withAlphaComponent(0.5), for: .highlighted)
        
        backgroundColor = isFollowing ? .background2 : .foreground
    }
}
