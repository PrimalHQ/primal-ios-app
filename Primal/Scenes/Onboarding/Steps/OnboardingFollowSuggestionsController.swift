//
//  OnboardingFollowSuggestionsController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 29.4.23..
//

import Combine
import UIKit
import Kingfisher

final class OnboardingFollowSuggestionsController: UIViewController, OnboardingViewController {
    let oldData: AccountCreationData
    var session: OnboardingSession
    
    typealias Group = FollowSuggestionsRequest.Response.SuggestionGroup
    
    let titleLabel: UILabel = .init()
    let backButton: UIButton = .init()
    lazy var table = UITableView()
    lazy var continueButton = OnboardingMainButton("Next")
    
    var suggestionGroups: [Group] = [] {
        didSet {
            table.reloadData()
            continueButton.isHidden = false
        }
    }
    
    var cancellables: Set<AnyCancellable> = []

    init(data: AccountCreationData, session: OnboardingSession) {
        self.oldData = data
        self.session = session
        super.init(nibName: nil, bundle: nil)
        
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension OnboardingFollowSuggestionsController {
    func setup() {
        addBackground(4)
        addNavigationBar("Your Follows")
        
        view.addSubview(continueButton)
        continueButton
            .pinToSuperview(edges: .horizontal, padding: 36)
            .pinToSuperview(edges: .bottom, padding: 12, safeArea: true)
        continueButton.addTarget(self, action: #selector(continuePressed), for: .touchUpInside)
        continueButton.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.continueButton.isHidden = false
        }
        
        view.addSubview(table)
        table.pinToSuperview(edges: .horizontal, padding: 36)
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            table.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -20)
        ])
        
        table.backgroundColor = .clear
        table.register(FollowProfileCell.self, forCellReuseIdentifier: "cell")
        table.register(FollowSectionHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        table.dataSource = self
        table.delegate = self
        table.contentInsetAdjustmentBehavior = .never
        table.contentInset = .zero
        table.sectionHeaderHeight = 70
        table.separatorStyle = .none
        table.clipsToBounds = true
        table.layer.cornerRadius = 12
        table.bounces = false
        
        session.$suggestionGroups.assign(to: \.suggestionGroups, onWeak: self).store(in: &cancellables)
    }


    @objc func continuePressed() {
        onboardingParent?.pushViewController(OnboardingPreviewController(data: oldData, session: session), animated: true)        
    }
}

extension OnboardingFollowSuggestionsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        header?.tag = section
        if let header = header as? FollowSectionHeader {
            header.title.text = suggestionGroups[section].group
            let group = suggestionGroups[section].members.map { $0.pubkey }
            header.followAll.isFollowing = session.usersToFollow.isSuperset(of: group)
            header.delegate = self
        }
        return header
    }
}

extension OnboardingFollowSuggestionsController: FollowSectionHeaderDelegate, FollowProfileCellDelegate {
    func followButtonPressed(_ cell: FollowProfileCell) {
        guard let index = table.indexPath(for: cell) else { return }
        let key = suggestionGroups[index.section].members[index.row].pubkey
        if cell.followButton.isFollowing {
            session.usersToFollow.insert(key)
        } else {
            session.usersToFollow.remove(key)
        }
        
        if let header = table.headerView(forSection: index.section) as? FollowSectionHeader {
            let group = suggestionGroups[index.section].members.map { $0.pubkey }
            header.followAll.isFollowing = session.usersToFollow.isSuperset(of: group)
        }
    }
    
    func headerTappedFollowAll(_ header: FollowSectionHeader) {
        let section = header.tag
        let group = suggestionGroups[section].members.map { $0.pubkey }
        if header.followAll.isFollowing {
            session.usersToFollow.formUnion(group)
        } else {
            session.usersToFollow.subtract(group)
        }
        table.reloadData()
    }
}

extension OnboardingFollowSuggestionsController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        suggestionGroups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        suggestionGroups[section].members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? FollowProfileCell {
            let suggestion = suggestionGroups[indexPath.section].members[indexPath.row]
            if let data = session.userMetadata[suggestion.pubkey], let nostrData = NostrMetadata.from(data.content) {
                cell.profileImage.setUserImage(.init(imageURL: nostrData.picture ?? ""), feed: false)
                cell.nameLabel.text = nostrData.name
                cell.secondaryLabel.text = nostrData.about
                cell.followButton.isFollowing = session.usersToFollow.contains(suggestion.pubkey)
                cell.delegate = self
            }
        }
        
        return cell
    }
}
