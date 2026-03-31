//
//  NoteUserHeaderView.swift
//  Primal
//
//  Created by Pavle Stevanović on 31.3.26..
//

import UIKit

class NoteUserHeaderView: UIView {
    static let headerAvatarSize: CGFloat = 42
    static let contentLeadingPadding: CGFloat = 62

    weak var delegate: FeedElementCellDelegate?
    weak var ownerCell: UITableViewCell?

    let threeDotsButton = UIButton()
    let profileImageView = UserImageView(height: NoteUserHeaderView.headerAvatarSize)
    let checkbox = VerifiedView().constrainToAspect(1, priority: .required)
    let nameLabel = UILabel()
    let timeLabel = UILabel()
    let nipLabel = UILabel()
    let repostIndicator = RepostedIndicatorView()
    let separatorLabel = UILabel()
    let replyingToView = ReplyingToView()
    lazy var nameStack = UIStackView([nameLabel, checkbox, nipLabel, separatorLabel, timeLabel])
    lazy var nameReplyStack = UIStackView(axis: .vertical, [nameStack, replyingToView])
    lazy var mainStack = UIStackView(axis: .vertical, [repostIndicator, nameReplyStack])
    let threeDotsSpacer = SpacerView(width: 20, priority: .required)

    let repostedByOverlayButton = UIButton()

    var checkboxHeightC: NSLayoutConstraint?

    init() {
        super.init(frame: .zero)

        addSubview(profileImageView)
        addSubview(mainStack)
        addSubview(threeDotsButton)
        addSubview(repostedByOverlayButton)
        
        profileImageView
            .pinToSuperview(edges: .leading, padding: 12)
            .pin(to: nameReplyStack, edges: .top)

        mainStack
            .pinToSuperview(edges: .top, padding: 12)
            .pinToSuperview(edges: .leading, padding: Self.contentLeadingPadding)
            .pinToSuperview(edges: .trailing, padding: 16)
        
        let botC = mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)
        botC.priority = .defaultLow
        botC.isActive = true

        mainStack.spacing = 4
        nameReplyStack.spacing = 4

        threeDotsButton
            .constrainToSize(44)
            .pinToSuperview(edges: .top, padding: 1)
            .pinToSuperview(edges: .trailing)

        nameStack.addArrangedSubview(threeDotsSpacer)

        repostedByOverlayButton
            .constrainToSize(width: 100)
            .pin(to: repostIndicator, edges: .leading)
            .pin(to: repostIndicator, edges: .top, padding: -11)
            .pin(to: repostIndicator, edges: .bottom, padding: -5)
        
        repostIndicator.transform = .init(translationX: 12 - Self.contentLeadingPadding, y: 0)

        repostedByOverlayButton.addAction(.init(handler: { [weak self] _ in
            guard let self, let ownerCell else { return }
            delegate?.postCellDidTap(ownerCell, .repostedProfile)
        }), for: .touchUpInside)

        separatorLabel.text = "·"

        [nameLabel, nipLabel, separatorLabel].forEach { $0.setContentHuggingPriority(.required, for: .horizontal) }

        nipLabel.lineBreakMode = .byTruncatingTail
        separatorLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        nameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        nipLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        threeDotsButton.setContentHuggingPriority(.required, for: .horizontal)

        checkboxHeightC = checkbox.heightAnchor.constraint(equalToConstant: FontSizeSelection.current.contentFontSize)
        checkboxHeightC?.isActive = true
        nameStack.alignment = .center
        nameStack.spacing = 4

        threeDotsButton.setImage(UIImage(named: "threeDots"), for: .normal)
        threeDotsButton.showsMenuAsPrimaryAction = true

        let tapArea = UIView()
        tapArea.backgroundColor = .white.withAlphaComponent(0.001)
        addSubview(tapArea)
        tapArea
            .pin(to: profileImageView, edges: [.leading, .vertical])
            .pin(to: separatorLabel, edges: .trailing)
        tapArea.addGestureRecognizer(BindableTapGestureRecognizer(action: { [unowned self] in
            guard let ownerCell else { return }
            delegate?.postCellDidTap(ownerCell, .profile)
        }))

        clipsToBounds = false
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func update(_ parsedContent: ParsedContent) {
        let user = parsedContent.user.data

        nameLabel.text = user.firstIdentifier

        if CheckNip05Manager.instance.isVerifiedForFeed(user) {
            nipLabel.text = user.parsedNip
            nipLabel.isHidden = false
            checkbox.user = user
        } else {
            nipLabel.isHidden = true
            checkbox.isHidden = true
        }

        let date = Date(timeIntervalSince1970: TimeInterval(parsedContent.post.created_at))
        timeLabel.text = date.timeAgoDisplay()

        profileImageView.setUserImage(parsedContent.user)

        if let parent = parsedContent.replyingTo {
            replyingToView.userNameLabel.text = parent.user.data.firstIdentifier
            replyingToView.isHidden = false
        } else {
            replyingToView.isHidden = true
        }

        threeDotsSpacer.isHidden = parsedContent.reposted != nil
        threeDotsButton.transform = parsedContent.reposted != nil ? .init(translationX: 0, y: -5) : .identity

        if let reposted = parsedContent.reposted?.users {
            repostIndicator.update(users: reposted)
            repostIndicator.isHidden = false
        } else {
            repostIndicator.isHidden = true
        }
        repostedByOverlayButton.isHidden = parsedContent.reposted == nil

        threeDotsButton.menu = .init(children: parsedContent.actionsData().map { (title, image, action, attributes) in
            UIAction(title: title, image: image, attributes: attributes) { [weak self] _ in
                guard let self, let ownerCell else { return }
                delegate?.postCellDidTap(ownerCell, action)
            }
        })

        updateTheme()
    }

    func updateTheme() {
        threeDotsButton.tintColor = .foreground3

        nameLabel.textColor = .foreground
        nameLabel.font = .appFont(withSize: FontSizeSelection.current.nameSize, weight: .bold)

        checkboxHeightC?.constant = FontSizeSelection.current.contentFontSize

        [timeLabel, separatorLabel, nipLabel].forEach {
            $0.font = .appFont(withSize: FontSizeSelection.current.nameSize, weight: .regular)
            $0.textColor = .foreground3
        }
    }
}
