//
//  ExplorePeopleCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 7.10.24..
//

import UIKit
import FLAnimatedImage
import Kingfisher

protocol ExplorePeopleHeaderCellDelegate: AnyObject {
    func showFeedPressedInCell(_ cell: ExplorePeopleHeaderCell)
    func followAllPressedInCell(_ cell: ExplorePeopleHeaderCell)
    func creatorPressedInCell(_ cell: ExplorePeopleHeaderCell)
}

final class ExplorePeopleHeaderCell: UITableViewCell, Themeable {
    let avatar = UserImageView(height: 36)
    
    let titleLabel = UILabel()
    let descLabel = UILabel()
    
    let userNameLabel = UILabel()
    let userNipLabel = UILabel()
    
    let largeImageView = UIImageView()
    
    let createdByLabel = UILabel()
    
    let showFeedButton = UIButton()
    let followAllButton = UIButton()

    let border = SpacerView(height: 1)
    
    let checkbox = VerifiedView().constrainToSize(18)
    
    weak var delegate: ExplorePeopleHeaderCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateForUserList(_ userList: UserList) {
        let user = userList.user
        
        userNameLabel.text = user.data.firstIdentifier
        
        if CheckNip05Manager.instance.isVerified(user.data) {
            checkbox.user = user.data
            userNipLabel.isHidden = false
            userNipLabel.text = user.data.parsedNip
        } else {
            checkbox.isHidden = true
            userNipLabel.isHidden = true
        }
        
        avatar.setUserImage(user, feed: true)
        
        largeImageView.kf.setImage(with: userList.imageData.url(for: .medium), options: [
            .cacheOriginalImage,
            .processor(DownsamplingImageProcessor(size: CGSize(width: contentView.frame.width - 56, height: 130))),
            .scaleFactor(UIScreen.main.scale),
        ])
        
        titleLabel.text = userList.name
        descLabel.text = userList.description
        descLabel.isHidden = userList.description.isEmpty
        
        updateTheme()
    }
    
    func updateTheme() {
        userNameLabel.textColor = .foreground3
        titleLabel.textColor = .foreground
        
        [descLabel, userNipLabel, createdByLabel].forEach { $0.textColor = .foreground4 }
        
        showFeedButton.configuration = .accentPill(text: "Show Feed", font: .appFont(withSize: 16, weight: .medium))
        followAllButton.configuration = .accentPill(text: "Follow All", font: .appFont(withSize: 16, weight: .medium))
        
        border.backgroundColor = .background3
    }
}

private extension ExplorePeopleHeaderCell {
    func setup() {
        selectionStyle = .none
        
        let nameRow = UIStackView([userNameLabel, checkbox, userNipLabel, UIView()])
        nameRow.setCustomSpacing(4, after: userNameLabel)
        nameRow.setCustomSpacing(4, after: checkbox)
        nameRow.alignment = .center
        let nameVStack = UIStackView(axis: .vertical, [createdByLabel, nameRow])
        nameVStack.spacing = 4
        
        let userRow = UIStackView([avatar, nameVStack])
        userRow.spacing = 8
        userRow.alignment = .center
        
        let actionStack = UIStackView([showFeedButton, followAllButton]).constrainToSize(height: 36)
        actionStack.distribution = .fillEqually
        actionStack.spacing = 12
        
        let mainStack = UIStackView(axis: .vertical, [
            largeImageView,     SpacerView(height: 12),
            titleLabel,         SpacerView(height: 8),
            descLabel,          SpacerView(height: 14),
            userRow,            SpacerView(height: 14),
            actionStack
        ])
        
        contentView.addSubview(mainStack)
        mainStack.pinToSuperview(edges: [.horizontal, .bottom], padding: 16).pinToSuperview(edges: .top)
        
        contentView.addSubview(border)
        border.pinToSuperview(edges: [.bottom, .horizontal])
        
        largeImageView.constrainToSize(height: 130)
        largeImageView.contentMode = .scaleAspectFill
        largeImageView.clipsToBounds = true
        largeImageView.layer.cornerRadius = 8
        
        userNameLabel.font = .appFont(withSize: 14, weight: .semibold)
        userNipLabel.font = .appFont(withSize: 14, weight: .regular)
        titleLabel.font = .appFont(withSize: 20, weight: .semibold)
        descLabel.font = .appFont(withSize: 14, weight: .regular)
        createdByLabel.font = .appFont(withSize: 12, weight: .regular)
        
        descLabel.numberOfLines = 0
        
        createdByLabel.text = "Created by:"
        
        followAllButton.addAction(.init(handler: { [unowned self] _ in
            delegate?.followAllPressedInCell(self)
        }), for: .touchUpInside)
        
        showFeedButton.addAction(.init(handler: { [unowned self] _ in
            delegate?.showFeedPressedInCell(self)
        }), for: .touchUpInside)
        
        userRow.addGestureRecognizer(BindableTapGestureRecognizer(action: { [unowned self] in
            delegate?.creatorPressedInCell(self)
        }))
    }
}
