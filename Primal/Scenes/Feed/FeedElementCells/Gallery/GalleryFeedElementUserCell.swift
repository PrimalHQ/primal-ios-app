//
//  GalleryFeedElementUserCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 1.4.26..
//

import UIKit

class GalleryFeedElementUserCell: UITableViewCell, RegularFeedElementCell {
    static var cellID: String { galleryCellID }
    static let galleryCellID = "GalleryFeedElementUserCell"

    weak var delegate: FeedElementCellDelegate?

    let threeDotsButton = UIButton()
    let profileImageView = UserImageView(height: 32)
    let checkbox = VerifiedView().constrainToAspect(1, priority: .required)
    let nameLabel = UILabel()
    let nipLabel = UILabel()
    lazy var nameRow = UIStackView([nameLabel, checkbox, UIView()])
    lazy var labelStack = UIStackView(axis: .vertical, [nameRow, nipLabel])
    lazy var mainStack = UIStackView([profileImageView, labelStack, threeDotsButton])

    var checkboxHeightC: NSLayoutConstraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = .clear

        contentView.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .top, padding: 12).pinToSuperview(edges: .leading, padding: 12).pinToSuperview(edges: .trailing, padding: 12)
        let botC = mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        botC.priority = .defaultLow
        botC.isActive = true

        mainStack.alignment = .center
        mainStack.spacing = 10

        labelStack.spacing = 2

        nameRow.alignment = .center
        nameRow.spacing = 4

        checkboxHeightC = checkbox.heightAnchor.constraint(equalToConstant: FontSizeSelection.current.contentFontSize)
        checkboxHeightC?.isActive = true

        threeDotsButton.constrainToSize(44)
        threeDotsButton.setImage(UIImage(named: "threeDots"), for: .normal)
        threeDotsButton.showsMenuAsPrimaryAction = true

        nipLabel.lineBreakMode = .byTruncatingTail

        let tapArea = UIView()
        contentView.addSubview(tapArea)
        tapArea
            .pin(to: profileImageView, edges: [.leading, .vertical])
            .pin(to: labelStack, edges: .trailing)
        tapArea.addGestureRecognizer(BindableTapGestureRecognizer(action: { [unowned self] in
            delegate?.postCellDidTap(self, .profile)
        }))
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

        profileImageView.setUserImage(parsedContent.user)

        threeDotsButton.menu = .init(children: parsedContent.actionsData().map { (title, image, action, attributes) in
            UIAction(title: title, image: image, attributes: attributes) { [weak self] _ in
                guard let self else { return }
                delegate?.postCellDidTap(self, action)
            }
        })

        updateTheme()
    }

    func updateTheme() {
        contentView.backgroundColor = .background2

        threeDotsButton.tintColor = .foreground3

        nameLabel.textColor = .foreground
        nameLabel.font = .appFont(withSize: FontSizeSelection.current.nameSize, weight: .bold)

        checkboxHeightC?.constant = FontSizeSelection.current.contentFontSize

        nipLabel.font = .appFont(withSize: FontSizeSelection.current.nameSize, weight: .regular)
        nipLabel.textColor = .foreground3
    }
}
