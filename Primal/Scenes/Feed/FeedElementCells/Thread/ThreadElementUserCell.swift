//
//  FeedElementUserCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.12.24..
//

import UIKit

class ThreadElementUserCell: FeedElementBaseCell, RegularFeedElementCell {
    static var cellID: String { "FeedElementUserCell" }

    let threadLayout: ThreadLayout

    let threeDotsButton = UIButton()
    let profileImageView = UserImageView(height: 24)
    let checkbox = VerifiedView().constrainToSize(FontSizeSelection.current.contentFontSize)
    let nameLabel = UILabel()
    let timeLabel = UILabel()
    let nipLabel = UILabel()
    let separatorLabel = UILabel()
    lazy var nameStack = UIStackView([nameLabel, checkbox, nipLabel, separatorLabel, timeLabel])
    let threeDotsSpacer = SpacerView(width: 20)

    convenience override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.init(position: .main, style: style, reuseIdentifier: reuseIdentifier)
    }
    init(position: ThreadPosition, style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.threadLayout = ThreadLayout(position: position)
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        threadLayout.install(in: contentView)

        switch position {
        case .parent:
            threadLayout.parentIndicator.removeFromSuperview()

            nameStack.constrainToSize(height: 24)

            threadLayout.firstRow.addSubview(profileImageView)
            profileImageView.pinToSuperview(edges: .top, padding: 8).pinToSuperview(edges: .trailing)
        case .main:
            profileImageView.height = 42

            nameStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

            let nameCheckStack = UIStackView([nameLabel, checkbox])
            let nameSuperStack = UIStackView(axis: .vertical, [nameCheckStack, nipLabel])

            nameStack.addArrangedSubview(profileImageView)
            nameStack.addArrangedSubview(nameSuperStack)
        case .child:
            nameStack.constrainToSize(height: 24)

            threadLayout.firstRow.addSubview(profileImageView)
            profileImageView.pinToSuperview(edges: .top, padding: 8).pinToSuperview(edges: .trailing)
        }

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func update(_ parsedContent: ParsedContent) {
        let user = parsedContent.user.data

        nameLabel.text = user.firstIdentifier

        if CheckNip05Manager.instance.isVerified(user) {
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

        threeDotsSpacer.isHidden = parsedContent.reposted != nil
        threeDotsButton.transform = parsedContent.reposted == nil ? .identity : .init(translationX: 0, y: -6)

        threeDotsButton.transform = parsedContent.reposted != nil ? .init(translationX: 0, y: -6) : (parsedContent.replyingTo == nil ? .init(translationX: 0, y: 4) : .identity)

        threeDotsButton.menu = .init(children: parsedContent.actionsData().map { (title, image, action, attributes) in
            UIAction(title: title, image: image, attributes: attributes) { [weak self] _ in
                guard let self = self else { return }
                delegate?.postCellDidTap(self, action)
            }
        })

        updateTheme()
    }

    override func updateTheme() {
        super.updateTheme()

        threadLayout.updateAppearance(contentView: contentView)

        threeDotsButton.tintColor = .foreground3

        nameLabel.textColor = .foreground
        nameLabel.font = .appFont(withSize: FontSizeSelection.current.nameSize, weight: .bold)

        [timeLabel, separatorLabel, nipLabel].forEach {
            $0.font = .appFont(withSize: FontSizeSelection.current.nameSize, weight: .regular)
            $0.textColor = .foreground3
        }
    }
}

private extension ThreadElementUserCell {
    private func setup() {
        threadLayout.secondRow.addSubview(nameStack)
        nameStack
            .pinToSuperview(edges: .top, padding: 8)
            .pinToSuperview(edges: .bottom, padding: 2)
            .pinToSuperview(edges: .horizontal)

        contentView.addSubview(threeDotsButton)
        threeDotsButton
            .constrainToSize(44)
            .pinToSuperview(edges: .trailing)
            .centerToSuperview(axis: .vertical)

        nameStack.addArrangedSubview(threeDotsSpacer)

        separatorLabel.text = "·"
        [timeLabel, separatorLabel, nipLabel].forEach {
            $0.font = .appFont(withSize: FontSizeSelection.current.nameSize, weight: .regular)
            $0.textColor = .foreground3
        }

        [nameLabel, nipLabel, separatorLabel].forEach { $0.setContentHuggingPriority(.required, for: .horizontal) }

        nipLabel.lineBreakMode = .byTruncatingTail
        separatorLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        nameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        nipLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        threeDotsButton.setContentHuggingPriority(.required, for: .horizontal)

        checkbox.constrainToSize(FontSizeSelection.current.contentFontSize)

        nameStack.alignment = .center
        nameStack.spacing = 4

        nameLabel.textColor = .foreground
        nameLabel.font = .appFont(withSize: FontSizeSelection.current.nameSize, weight: .bold)

        threeDotsButton.setImage(UIImage(named: "threeDots"), for: .normal)
        threeDotsButton.tintColor = .foreground3
        threeDotsButton.showsMenuAsPrimaryAction = true

        let tapArea = UIView()
        contentView.addSubview(tapArea)
        tapArea
            .pin(to: profileImageView, edges: [.leading, .vertical])
            .pin(to: separatorLabel, edges: .trailing)
        tapArea.addGestureRecognizer(BindableTapGestureRecognizer(action: { [unowned self] in
            delegate?.postCellDidTap(self, .profile)
        }))
    }
}
