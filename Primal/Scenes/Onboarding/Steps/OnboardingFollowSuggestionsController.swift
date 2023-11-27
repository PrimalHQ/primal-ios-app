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
    enum State {
        case initial
        case followRequesting
        case followDone
        case followFailed
    }

    typealias Group = FollowSuggestionsRequest.Response.SuggestionGroup
    typealias Metadata = FollowSuggestionsRequest.Response.Metadata
    
    let titleLabel: UILabel = .init()
    let backButton: UIButton = .init()
    lazy var table = UITableView()
    lazy var continueButton = OnboardingMainButton("Finish")
    
    var suggestionGroups: [Group] = [] {
        didSet {
            table.reloadData()
            continueButton.isHidden = false
        }
    }
    
    var metadata: [String: Metadata] = [:]
    
    var selectedToFollow: Set<String> = []
    
    var cancellables: Set<AnyCancellable> = []

    private var state = State.initial {
        didSet {
            updateView()
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension OnboardingFollowSuggestionsController {
    func setup() {
        addBackground(4, clipToLeft: false)
        addNavigationBar("People to Follow")
        backButton.isHidden = true
        
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
        
        let username = UserDefaults.standard.string(forKey: "username") ?? ""
        
        FollowSuggestionsRequest(username: username).publisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion  in
                print(completion)
            }, receiveValue: { [weak self] response in
                self?.metadata = response.metadata
                self?.selectedToFollow = Set(response.suggestions.flatMap { $0.members } .map { $0.pubkey })
                self?.suggestionGroups = response.suggestions
                UserDefaults.standard.removeObject(forKey: "username")
            })
            .store(in: &cancellables)
        
        Connection.regular.$isConnected.filter { $0 }.first().sink { connected in            
            IdentityManager.instance.requestUserInfos()
            IdentityManager.instance.requestUserProfile()
            IdentityManager.instance.requestUserSettings()
            IdentityManager.instance.requestUserContacts()

            MuteManager.instance.requestMuteList()
        }.store(in: &cancellables)
        Connection.connect()
    }

    func updateView() {
        switch state {
        case .initial:
            continueButton.isEnabled = true
            continueButton.setTitle("Finish", for: .normal)
        case .followRequesting:
            continueButton.isEnabled = false
            continueButton.setTitle("Applying", for: .normal)
        case .followFailed:
            continueButton.isEnabled = true
            continueButton.setTitle("Follow failed, try again", for: .normal)
        case .followDone:
            RootViewController.instance.reset()
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                // Need to refresh to let the server update new follows
                guard let home: HomeFeedViewController = RootViewController.instance.findInChildren() else { return }
                home.feed.refresh()
            }
        }
    }

    func initiateFollow() {
        state = .followRequesting

        FollowManager.instance.sendBatchFollowEvent(selectedToFollow, successHandler: { [weak self] in
            self?.state = .followDone
        }, errorHandler: { [weak self] in
            self?.state = .followFailed
        })
    }

    @objc func continuePressed() {
        switch state {
        case .initial, .followFailed:
            initiateFollow()
            break
        case .followDone, .followRequesting:
            break
        }
    }
}

extension OnboardingFollowSuggestionsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        header?.tag = section
        if let header = header as? FollowSectionHeader {
            header.title.text = suggestionGroups[section].group
            let group = suggestionGroups[section].members.map { $0.pubkey }
            header.followAll.isFollowing = selectedToFollow.isSuperset(of: group)
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
            selectedToFollow.insert(key)
        } else {
            selectedToFollow.remove(key)
        }
        
        if let header = table.headerView(forSection: index.section) as? FollowSectionHeader {
            let group = suggestionGroups[index.section].members.map { $0.pubkey }
            header.followAll.isFollowing = selectedToFollow.isSuperset(of: group)
        }
    }
    
    func headerTappedFollowAll(_ header: FollowSectionHeader) {
        let section = header.tag
        let group = suggestionGroups[section].members.map { $0.pubkey }
        if header.followAll.isFollowing {
            selectedToFollow.formUnion(group)
        } else {
            selectedToFollow.subtract(group)
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
            if let data = metadata[suggestion.pubkey], let nostrData = NostrMetadata.from(data.content) {
                
                cell.profileImage.kf.setImage(with: URL(string: nostrData.picture ?? ""), placeholder: UIImage(named: "Profile"), options: [
                    .processor(DownsamplingImageProcessor(size: CGSize(width: 48, height: 48))),
                    .scaleFactor(UIScreen.main.scale),
                    .cacheOriginalImage
                ])
                
                cell.nameLabel.text = nostrData.name
                cell.secondaryLabel.text = nostrData.about
                cell.followButton.isFollowing = selectedToFollow.contains(suggestion.pubkey)
                cell.delegate = self
            }
        }
        
        return cell
    }
}
