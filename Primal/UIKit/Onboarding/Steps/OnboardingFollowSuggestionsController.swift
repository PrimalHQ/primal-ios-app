//
//  OnboardingFollowSuggestionsController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 29.4.23..
//

import Combine
import UIKit
import Kingfisher

class OnboardingFollowSuggestionsController: UIViewController {
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
        
        let stack = UIStackView(arrangedSubviews: [table, buttonParent])
        view.addSubview(stack)
        stack.pinToSuperview(safeArea: true)
        
        stack.axis = .vertical
        
        let fade = UIImageView(image: UIImage(named: "bottomFade"))
        view.addSubview(fade)
        fade.pin(to: table, edges: [.horizontal, .bottom])
        
        table.register(FollowProfileCell.self, forCellReuseIdentifier: "cell")
        table.register(FollowSectionHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        table.dataSource = self
        table.delegate = self
        table.contentInsetAdjustmentBehavior = .never
        
        FollowSuggestionsRequest().publisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion  in
                print(completion)
            }, receiveValue: { [weak self] response in
                self?.metadata = response.metadata
                self?.suggestionGroups = response.suggestions
            })
            .store(in: &cancellables)
    }
    
    @objc func continuePressed() {
        
    }
}

extension OnboardingFollowSuggestionsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        if let header = header as? FollowSectionHeader {
            header.title.text = suggestionGroups[section].group
//            header.delegate = self
        }
        return header
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
                
                cell.profileImage.imageView.kf.setImage(with: URL(string: nostrData.picture ?? ""))
                cell.nameLabel.text = nostrData.name
                cell.usernameLabel.text = "@\(nostrData.display_name ?? "")"
                cell.followButton.isFollowing = false
            }
        }
        return cell
    }
}