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
    let avatar = UserImageView(height: 24)
    
    let avatarStack = SimpleAvatarView(size: 32, spacing: -3, maxAvatarCount: 5)
    
    let titleLabel = UILabel()
    
    let userNameLabel = UILabel()
    
    let largeImageView = UIImageView()
    
    let updatedAtLabel = UILabel()
    let userCountLabel = UILabel()

    let checkbox = VerifiedView().constrainToSize(18)
    
    let background = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateForUserList(_ userList: UserList) {
        avatarStack.setUsers(userList.list)
        
        let user = userList.user
        
        userNameLabel.text = user.data.firstIdentifier
        
        if CheckNip05Manager.instance.isVerified(user.data) {
            checkbox.user = user.data
        } else {
            checkbox.isHidden = true
        }
        
        avatar.setUserImage(user, feed: true)
        
        userCountLabel.text = "\(userList.list.count) users"
        updatedAtLabel.text = "updated \(userList.updatedAt.timeAgoDisplay(addAgo: true))"
        
        largeImageView.kf.setImage(with: userList.imageData.url(for: .medium), options: [
            .cacheOriginalImage,
            .processor(DownsamplingImageProcessor(size: CGSize(width: contentView.frame.width - 56, height: 120))),
            .scaleFactor(UIScreen.main.scale),
        ])
        
        titleLabel.text = userList.name
        
        updateTheme()
    }
    
    func updateTheme() {
        userNameLabel.textColor = .foreground3
        titleLabel.textColor = .foreground
        
        [updatedAtLabel, userCountLabel].forEach { $0.textColor = .foreground4 }
        
        background.backgroundColor = .background5
    }
}

private extension ExplorePeopleCell {
    func setup() {
        selectionStyle = .none
        
        let nameRow = UIStackView([avatar, userNameLabel, checkbox, UIView()])
        nameRow.setCustomSpacing(4, after: userNameLabel)
        nameRow.setCustomSpacing(8, after: avatar)
        nameRow.alignment = .center
        
        let smallVStack = UIStackView(axis: .vertical, [userCountLabel, updatedAtLabel])
        let secondRow = UIStackView([avatarStack, smallVStack])
        secondRow.spacing = 4
        secondRow.alignment = .center
        
        let inlineVStack = UIStackView(axis: .vertical, [
            titleLabel, SpacerView(height: 10),
            nameRow,    SpacerView(height: 20),
            secondRow
        ])
        inlineVStack.isLayoutMarginsRelativeArrangement = true
        inlineVStack.insetsLayoutMarginsFromSafeArea = false
        inlineVStack.layoutMargins = .init(top: 12, left: 12, bottom: 12, right: 12)
        
        let mainStack = UIStackView(axis: .vertical, [largeImageView, inlineVStack])
        
        contentView.addSubview(background)
        background.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .bottom, padding: 16).pinToSuperview(edges: .top)
        
        background.addSubview(mainStack)
        mainStack.pinToSuperview()
        
        largeImageView.constrainToSize(height: 120)
        largeImageView.contentMode = .scaleAspectFill
        largeImageView.clipsToBounds = true
        
        background.layer.cornerRadius = 8
        background.layer.masksToBounds = true
        
        userNameLabel.font = .appFont(withSize: 14, weight: .semibold)
        
        titleLabel.font = .appFont(withSize: 20, weight: .semibold)
        
        [updatedAtLabel, userCountLabel].forEach {
            $0.font = .appFont(withSize: 12, weight: .regular)
            $0.textAlignment = .right
        }
        
        updateTheme()
    }
}

final class SimpleAvatarView: UIView {
    lazy var avatarViews = (1...maxAvatarCount).map { _ in UserImageView(height: size) }
    
    let maxAvatarCount: Int
    let size: CGFloat
    let spacing: CGFloat
    
    init(size: CGFloat = 32, spacing: CGFloat = 4, maxAvatarCount: Int = 6) {
        self.size = size
        self.spacing = spacing
        self.maxAvatarCount = maxAvatarCount
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUsers(_ users: [ParsedUser]) {
        for view in avatarViews { view.isHidden = true }
        
        zip(avatarViews, users).forEach { view, user in
            view.isHidden = false
            view.setUserImage(user)
        }
    }
}

private extension SimpleAvatarView {
    func setup() {
        let stack = UIStackView(arrangedSubviews: avatarViews)
                
        stack.spacing = spacing
        
        addSubview(stack)
        stack.pinToSuperview()
        
        constrainToSize(height: size)
    }
}
