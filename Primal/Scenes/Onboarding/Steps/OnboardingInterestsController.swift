//
//  OnboardingInterestsController.swift
//  Primal
//
//  Created by Pavle Stevanović on 20.3.24..
//

import Combine
import UIKit
import Kingfisher

final class OnboardingInterestsController: OnboardingBaseViewController {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    let countBadge = UILabel("0", color: .white, font: .appFont(withSize: 12, weight: .regular))
    lazy var continueButton = OnboardingMainButton("Next")

    var parsedGroups: [ParsedSuggestionGroup] = [] {
        didSet {
            tableView.reloadData()
            continueButton.isHidden = false
        }
    }

    var expandedSections: Set<Int> = []

    let session: OnboardingSession
    let oldData: AccountCreationData

    var cancellables: Set<AnyCancellable> = []

    init(data: AccountCreationData, session: OnboardingSession, backgroundIndex: Int) {
        oldData = data
        self.session = session
        super.init(backgroundIndex: backgroundIndex)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateCountBadge() {
        countBadge.text = "\(session.usersToFollow.count)"
        countBadge.alpha = session.usersToFollow.isEmpty ? 0.2 : 1
        
        continueButton.isEnabled = !session.usersToFollow.isEmpty
    }
}

// MARK: - Setup

private extension OnboardingInterestsController {
    func setup() {
        addBackground()
        addNavigationBar("Follow People")

        countBadge.backgroundColor = IceWave.instance.foreground
        countBadge.textAlignment = .center
        countBadge.layer.cornerRadius = 11
        countBadge.clipsToBounds = true
        countBadge.alpha = 0.2
        view.addSubview(countBadge)
        countBadge.constrainToSize(width: 40, height: 22)
        countBadge.pinToSuperview(edges: .trailing, padding: 20)
        countBadge.centerToView(titleLabel, axis: .vertical)

        let progressView = OnboardingProgressView(progress: 1, total: 4)
        let bottomStack = UIStackView(axis: .vertical, [continueButton, SpacerView(height: 18), progressView])
        view.addSubview(bottomStack)
        bottomStack.pinToSuperview(edges: .horizontal, padding: 36).pinToSuperview(edges: .bottom, padding: 12, safeArea: true)

        view.addSubview(tableView)
        tableView.pinToSuperview(edges: .horizontal)
        tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomStack.topAnchor, constant: -12).isActive = true

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(SuggestionGroupHeaderCell.self, forCellReuseIdentifier: "header")
        tableView.register(SuggestionGroupUserCell.self, forCellReuseIdentifier: "user")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInsetAdjustmentBehavior = .never

        continueButton.addTarget(self, action: #selector(continuePressed), for: .touchUpInside)
        
        session.$parsedGroups.assign(to: \.parsedGroups, onWeak: self).store(in: &cancellables)
        updateCountBadge()
    }

    @objc func continuePressed() {
        onboardingParent?.pushViewController(OnboardingPreviewController(data: oldData, session: session, backgroundIndex: backgroundIndex + 1), animated: true)
    }
}

// MARK: - UITableViewDataSource

extension OnboardingInterestsController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        parsedGroups.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        expandedSections.contains(section) ? 1 + parsedGroups[section].people.count : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "header", for: indexPath) as! SuggestionGroupHeaderCell
            let group = parsedGroups[indexPath.section]
            let allPubkeys = Set(group.people.map { $0.pubkey })
            let isFollowingAll = session.usersToFollow.isSuperset(of: allPubkeys)
            let isExpanded = expandedSections.contains(indexPath.section)
            cell.configure(group: group, isExpanded: isExpanded, isFollowingAll: isFollowingAll)
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "user", for: indexPath) as! SuggestionGroupUserCell
            let person = parsedGroups[indexPath.section].people[indexPath.row - 1]
            let isFollowing = session.usersToFollow.contains(person.pubkey)
            cell.configure(person: person, isFollowing: isFollowing)
            cell.delegate = self
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension OnboardingInterestsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? { nil }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { section == 0 ? .leastNormalMagnitude : 12 }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? { nil }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { .leastNormalMagnitude }
}

// MARK: - SuggestionGroupHeaderCellDelegate

extension OnboardingInterestsController: SuggestionGroupHeaderCellDelegate {
    func headerCellDidTapUsers(_ cell: SuggestionGroupHeaderCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let section = indexPath.section

        if expandedSections.contains(section) {
            expandedSections.remove(section)
        } else {
            expandedSections.insert(section)
        }

        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
    }

    func headerCellDidTapFollowAll(_ cell: SuggestionGroupHeaderCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let group = parsedGroups[indexPath.section]
        let allPubkeys = Set(group.people.map { $0.pubkey })

        if session.usersToFollow.isSuperset(of: allPubkeys) {
            session.usersToFollow.subtract(allPubkeys)
        } else {
            session.usersToFollow.formUnion(allPubkeys)
        }

        updateCountBadge()
        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
    }
}

// MARK: - SuggestionGroupUserCellDelegate

extension OnboardingInterestsController: SuggestionGroupUserCellDelegate {
    func userCellDidTapFollow(_ cell: SuggestionGroupUserCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let person = parsedGroups[indexPath.section].people[indexPath.row - 1]

        if session.usersToFollow.contains(person.pubkey) {
            session.usersToFollow.remove(person.pubkey)
        } else {
            session.usersToFollow.insert(person.pubkey)
        }

        updateCountBadge()
        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
    }
}

// MARK: - SuggestionGroupHeaderCell

protocol SuggestionGroupHeaderCellDelegate: AnyObject {
    func headerCellDidTapUsers(_ cell: SuggestionGroupHeaderCell)
    func headerCellDidTapFollowAll(_ cell: SuggestionGroupHeaderCell)
}

final class SuggestionGroupHeaderCell: UITableViewCell {
    let coverImageView = UIImageView()
    let nameLabel = UILabel("", color: IceWave.instance.foreground, font: .appFont(withSize: 18, weight: .bold))
    let followAllButton = UIButton()
    let usersLabel = UILabel("", color: IceWave.instance.foreground3, font: .appFont(withSize: 12, weight: .regular))
    let chevronImageView = UIImageView(image: .onboardingChevronDown)
    let avatarsContainer = UIView()
    let separatorLine = UIView()

    private var coverHeightConstraint: NSLayoutConstraint!

    weak var delegate: SuggestionGroupHeaderCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(
        group: ParsedSuggestionGroup,
        isExpanded: Bool,
        isFollowingAll: Bool
    ) {
        // Cover image
        if let url = URL(string: group.coverUrl), !group.coverUrl.isEmpty {
            coverImageView.kf.setImage(with: url)
            coverImageView.isHidden = false
            coverHeightConstraint.constant = 106
        } else {
            coverImageView.isHidden = true
            coverHeightConstraint.constant = 0
        }

        // Name
        nameLabel.text = group.name.capitalized

        // Avatars
        avatarsContainer.subviews.forEach { $0.removeFromSuperview() }
        let avatarSize: CGFloat = 24
        let overlap: CGFloat = 6
        let count = min(5, group.people.count)
        for i in 0..<count {
            let imageView = UserImageView(height: avatarSize)
            imageView.setUserImage(group.people[i].user, feed: false)

            let imageViewParent = UIView().constrainToSize(avatarSize + 2)
            imageViewParent.layer.cornerRadius = (avatarSize + 2) / 2
            imageViewParent.backgroundColor = .white
            imageViewParent.addSubview(imageView)
            imageView.centerToSuperview()
            avatarsContainer.addSubview(imageViewParent)
            imageViewParent.pinToSuperview(edges: .trailing, padding: CGFloat(i) * (avatarSize - overlap)).centerToSuperview(axis: .vertical)
        }
        if let lastAvatar = avatarsContainer.subviews.last {
            lastAvatar.pinToSuperview(edges: .leading, padding: -2)
        }

        // Users count + chevron
        usersLabel.text = "\(group.people.count) users"
        chevronImageView.transform = isExpanded ? .init(rotationAngle: .pi) : .identity

        // Follow all
        followAllButton.configuration = isFollowingAll ?
            .pill(text: "Following all", foregroundColor: IceWave.instance.foreground, backgroundColor: IceWave.instance.background3, font: .appFont(withSize: 12, weight: .regular)) :
            .pill(text: "Follow all", foregroundColor: .white, backgroundColor: IceWave.instance.foreground, font: .appFont(withSize: 12, weight: .regular))

        // Separator
        separatorLine.isHidden = !isExpanded
    }

    private func setupViews() {
        selectionStyle = .none
        contentView.backgroundColor = .white

        // Cover image
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverHeightConstraint = coverImageView.heightAnchor.constraint(equalToConstant: 160)
        coverHeightConstraint.isActive = true
        
        avatarsContainer.setContentHuggingPriority(.required, for: .horizontal)

        let usersRow = UIStackView([usersLabel, chevronImageView])
        usersRow.spacing = 4
        usersRow.alignment = .center
        usersRow.isUserInteractionEnabled = false

        let tapArea = UIView()
        tapArea.addSubview(usersRow)
        usersRow.pinToSuperview(edges: .vertical).pinToSuperview(edges: .leading)
        tapArea.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(usersTapped)))

        // Follow all button
        followAllButton.constrainToSize(width: 92, height: 24)
        followAllButton.addTarget(self, action: #selector(followAllTapped), for: .touchUpInside)

        // Bottom row
        let bottomRow = UIStackView(spacing: 8, [avatarsContainer, tapArea, UIView(), followAllButton])
        bottomRow.alignment = .center

        // Info content
        let infoStack = UIStackView(axis: .vertical, spacing: 10, [nameLabel, bottomRow])

        let infoContainer = UIView()
        infoContainer.addSubview(infoStack)
        infoStack.pinToSuperview(edges: .leading, padding: 10).pinToSuperview(edges: .trailing, padding: 10).pinToSuperview(edges: .vertical, padding: 8)

        // Separator line
        separatorLine.backgroundColor = UIColor(rgb: 0xE5E5E5)
        separatorLine.constrainToSize(height: 1)
        separatorLine.isHidden = true

        let separatorContainer = UIView()
        separatorContainer.addSubview(separatorLine)
        separatorLine.pinToSuperview(edges: .vertical).pinToSuperview(edges: .horizontal, padding: 16)

        // Main stack
        let mainStack = UIStackView(axis: .vertical, [coverImageView, infoContainer, separatorContainer])
        contentView.addSubview(mainStack)
        mainStack.pinToSuperview()
    }

    @objc private func usersTapped() {
        delegate?.headerCellDidTapUsers(self)
    }

    @objc private func followAllTapped() {
        delegate?.headerCellDidTapFollowAll(self)
    }
}

// MARK: - SuggestionGroupUserCell

protocol SuggestionGroupUserCellDelegate: AnyObject {
    func userCellDidTapFollow(_ cell: SuggestionGroupUserCell)
}

final class SuggestionGroupUserCell: UITableViewCell {
    let profileImageView = UserImageView(height: 40)
    let nameLabel = UILabel("", color: IceWave.instance.foreground, font: .appFont(withSize: 14, weight: .bold))
    let descLabel = UILabel("", color: IceWave.instance.foreground.withAlphaComponent(0.55), font: .appFont(withSize: 12, weight: .regular))
    let followButton = UIButton()

    weak var delegate: SuggestionGroupUserCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(
        person: ParsedSuggestionPerson,
        isFollowing: Bool
    ) {
        let data = person.user.data
        profileImageView.setUserImage(person.user, feed: false)
        nameLabel.text = data.firstIdentifier

        let about = data.about
        descLabel.text = about
        descLabel.isHidden = about.isEmpty
        
        var config: UIButton.Configuration = isFollowing ?
            .pill(text: "Following", foregroundColor: IceWave.instance.foreground, backgroundColor: IceWave.instance.background3, font: .appFont(withSize: 12, weight: .regular)) :
            .pill(text: "Follow", foregroundColor: .white, backgroundColor: IceWave.instance.foreground, font: .appFont(withSize: 12, weight: .regular))
        
        config.contentInsets = .zero
        followButton.configuration = config
    }

    private func setupViews() {
        selectionStyle = .none
        contentView.backgroundColor = .white

        nameLabel.lineBreakMode = .byTruncatingTail
        descLabel.lineBreakMode = .byTruncatingTail

        followButton.constrainToSize(width: 72, height: 24)
        followButton.addTarget(self, action: #selector(followTapped), for: .touchUpInside)
        
        let nameDescStack = UIStackView(axis: .vertical, spacing: 4, [nameLabel, descLabel])
        let stack = UIStackView(spacing: 8, [profileImageView, nameDescStack, followButton])
        stack.alignment = .center

        contentView.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 12).pinToSuperview(edges: .vertical, padding: 8)
    }

    @objc private func followTapped() {
        delegate?.userCellDidTapFollow(self)
    }
}
