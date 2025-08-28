//
//  SearchViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 19.6.23..
//

import Combine
import UIKit
import SafariServices

final class SearchViewController: UIViewController, Themeable, WalletSearchController {
    
    let navigationExtender = SpacerView(height: 7)
    let navigationBorder = SpacerView(height: 1)
    let searchView = SearchInputHeaderView()
    let userTable = UITableView()
    
    let configButton = UIButton(configuration: .simpleImage("searchConfig"))
    
    @Published var userSearchText: String = ""
    
    var textSearch: String?
    
    var cancellables: Set<AnyCancellable> = []
    
    var users: [ParsedUser] = [] {
        didSet {
            userTable.reloadData()
        }
    }
    
    let scope: SearchScope
    let searchType: SearchType
    init(scope: SearchScope = .global, type: SearchType = .notes) {
        self.scope = scope
        searchType = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.transform = .identity
        
        searchView.inputField.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func updateTheme() {
        userTable.reloadData()
        searchView.updateTheme()
        
        navigationItem.leftBarButtonItem = customBackButton
        view.backgroundColor = .background
        navigationExtender.backgroundColor = .background
        navigationBorder.backgroundColor = .background3
        
        configButton.tintColor = .foreground
    }
}

private extension SearchViewController {
    var advancedSearchManager: AdvancedSearchManager {
        let advancedSearch = AdvancedSearchManager()
        advancedSearch.searchScope = scope
        advancedSearch.searchType = searchType
        let text = userSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !text.isEmpty {
            advancedSearch.includeWordsText = "\"\(text)\""
        }
        return advancedSearch
    }
    
    func setup() {
        navigationItem.titleView = searchView
        navigationItem.rightBarButtonItem = .init(customView: configButton)
        updateTheme()
        setBindings()
        
        let stack = UIStackView(arrangedSubviews: [navigationExtender, navigationBorder, userTable])
        view.addSubview(stack)
        stack.axis = .vertical
        stack.pinToSuperview(edges: .top, safeArea: true).pinToSuperview(edges: .horizontal).pinToSuperview(edges: .bottom, padding: 56, safeArea: true)
        
        userTable.register(UserInfoTableCell.self, forCellReuseIdentifier: "userCell")
        userTable.register(SearchTermTableCell.self, forCellReuseIdentifier: "search")
        userTable.separatorStyle = .none
        userTable.delegate = self
        userTable.dataSource = self
        
        searchView.inputField.delegate = self
        searchView.inputField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        configButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            present(AdvancedSearchController(manager: advancedSearchManager), animated: true)
        }), for: .touchUpInside)
    }
    
    func setBindings() {
        $userSearchText
            .flatMap { [weak self] in
                self?.userTable.reloadData()
                
                return SmartContactsManager.instance.userSearchPublisher($0)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] users in
                self?.users = users
            })
            .store(in: &cancellables)
    }
    
    func doSearch() {
        if userSearchText.isEmpty { return }
        
        let userSearchText = userSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowerCased = userSearchText.lowercased()
        
        if lowerCased.hasPrefix("npub1") && userSearchText.count == 63 {
            notify(.primalProfileLink, userSearchText)
            navigationController?.viewControllers.removeAll(where: { $0 == self })
            return
        }
        
        if lowerCased.hasPrefix("note1") && userSearchText.count == 63, let text = userSearchText.noteIdToHex() {
            notify(.primalNoteLink, text)
            navigationController?.viewControllers.removeAll(where: { $0 == self })
            return
        }
        
        if (lowerCased.hasPrefix("lnurl") || lowerCased.hasPrefix("lnbc")) && lowerCased.count > 20 {
            search(userSearchText)
            return
        }
        
        if let url = URL(string: userSearchText), url.scheme?.lowercased() == "https" {
            present(SFSafariViewController(url: url), animated: true)
            navigationController?.viewControllers.removeAll(where: { $0 == self })
            return
        }
        
        switch searchType {
        case .reads:
            let articleFeed = SearchArticleFeedController(feed: advancedSearchManager.feed)
            show(articleFeed, sender: nil)
        default:
            let feed = SearchNoteFeedController(feed: FeedManager(newFeed: advancedSearchManager.feed))
            show(feed, sender: nil)
        }
    }
    
    @objc func textFieldDidChange() {
        userSearchText = searchView.inputField.text ?? ""
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        doSearch()
        return true
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "search", for: indexPath)
            if let cell = cell as? SearchTermTableCell {
                cell.termLabel.text = userSearchText.isEmpty ? "Enter text to search" : userSearchText
                switch searchType {
                case .reads:
                    cell.titleLabel.text = "Search reads"
                default:
                    switch scope {
                    case .myNotifications:
                        cell.titleLabel.text = "Search notifications"
                    default:
                        cell.titleLabel.text = "Search notes"
                    }
                }
                cell.updateTheme()
            }
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        (cell as? UserInfoTableCell)?.update(user: users[indexPath.row - 1])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            doSearch()
            return
        }
        
        let profile = ProfileViewController(profile: users[indexPath.row - 1])
        searchView.inputField.resignFirstResponder()
        show(profile, sender: nil)
    }
}

final class SearchInputHeaderView: UIView, Themeable {
    let inputField = UITextField()
    let icon = UIImageView(image: UIImage(named: "searchIconSmall"))
    
    init() {
        super.init(frame: .zero)
        
        constrainToSize(height: 32)
        let width = widthAnchor.constraint(equalToConstant: 255)
        width.priority = .defaultHigh
        width.isActive = true
        
        layer.cornerRadius = 16
        
        let stack = UIStackView(arrangedSubviews: [icon, inputField])
        stack.alignment = .center
        stack.spacing = 8
        
        addSubview(stack)
        stack.centerToSuperview().pinToSuperview(edges: .horizontal, padding: 12)
        
        icon.setContentHuggingPriority(.required, for: .horizontal)
        
        inputField.font = .appFont(withSize: 16, weight: .medium)
        inputField.autocorrectionType = .no
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        backgroundColor = .background3
        inputField.textColor = .foreground
        icon.tintColor = .foreground
    }
}
