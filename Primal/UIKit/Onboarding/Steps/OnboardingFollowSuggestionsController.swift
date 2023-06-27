//
//  OnboardingFollowSuggestionsController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 29.4.23..
//

import Combine
import UIKit
import Kingfisher

final class OnboardingFollowSuggestionsController: UIViewController {
    typealias Suggestion = FollowSuggestionsRequest.Response.Suggestion
    typealias Group = FollowSuggestionsRequest.Response.SuggestionGroup
    typealias Metadata = FollowSuggestionsRequest.Response.Metadata
    
    lazy var table = UITableView()
    lazy var continueButton = FancyButton(title: "Finish")
    
    var suggestionGroups: [Group] = [] {
        didSet {
            table.reloadData()
        }
    }
    
    var metadata: [String: Metadata] = [:]
    
    var selectedToFollow: Set<String> = []
    
    var cancellables: Set<AnyCancellable> = []
    
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
        navigationItem.title = "People to follow"
        view.backgroundColor = .black
        
        let button = UIButton()
        button.setImage(UIImage(named: "back"), for: .normal)
        button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        
        let buttonParent = UIView()
        buttonParent.addSubview(continueButton)
        continueButton
            .pinToSuperview(edges: .horizontal, padding: 36)
            .pinToSuperview(edges: .top, padding: 20)
            .pinToSuperview(edges: .bottom, padding: 30, safeArea: true)
        continueButton.addTarget(self, action: #selector(continuePressed), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [table, buttonParent])
        view.addSubview(stack)
        stack.pinToSuperview(safeArea: true)
        
        stack.axis = .vertical
        
        let fade = UIImageView(image: UIImage(named: "bottomFade"))
        view.addSubview(fade)
        fade.pin(to: table, edges: [.horizontal, .bottom])
        
        table.backgroundColor = .black
        table.register(FollowProfileCell.self, forCellReuseIdentifier: "cell")
        table.register(FollowSectionHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        table.dataSource = self
        table.delegate = self
        table.contentInsetAdjustmentBehavior = .never
        table.sectionHeaderHeight = 70
        
        let username = UserDefaults.standard.string(forKey: "username") ?? ""
        
        FollowSuggestionsRequest(username: username).publisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion  in
                print(completion)
            }, receiveValue: { [weak self] response in
                dump(response)
                self?.metadata = response.metadata
                self?.suggestionGroups = response.suggestions
                self?.selectedToFollow = Set(response.suggestions.flatMap { $0.members } .map { $0.pubkey })
                UserDefaults.standard.removeObject(forKey: "username")
            })
            .store(in: &cancellables)
        
        Connection.instance.$isConnected.filter { $0 }.first().sink { connected in
            IdentityManager.instance.requestUserInfos()
            IdentityManager.instance.requestUserProfile()
            IdentityManager.instance.requestUserSettings()
            IdentityManager.instance.requestUserContacts()
        }.store(in: &cancellables)
        Connection.instance.connect()
    }
    
    @objc func continuePressed() {
        FollowManager.instance.sendBatchFollowEvent(Array(selectedToFollow))
        RootViewController.instance.reset()
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
        table.reloadRows(at: table.indexPathsForVisibleRows ?? [], with: .none)
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
                
                cell.profileImage.imageView.kf.setImage(with: URL(string: nostrData.picture ?? ""), options: [
                    .processor(DownsamplingImageProcessor(size: CGSize(width: 48, height: 48))),
                    .scaleFactor(UIScreen.main.scale),
                    .cacheOriginalImage
                ])
                
                cell.nameLabel.text = nostrData.name
                cell.usernameLabel.text = nostrData.nip05
                cell.followButton.isFollowing = selectedToFollow.contains(suggestion.pubkey)
                cell.delegate = self
            }
        }
        
        return cell
    }
}
