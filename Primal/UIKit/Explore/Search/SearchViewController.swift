//
//  SearchViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 19.6.23..
//

import Combine
import UIKit

final class SearchViewController: UIViewController, Themeable {
    let navigationExtender = SpacerView(height: 7)
    let navigationBorder = SpacerView(height: 1)
    let searchView = SearchInputHeaderView()
    let userTable = UITableView()
    
    @Published var userSearchText: String = ""
    
    var cancellables: Set<AnyCancellable> = []
    
    var users: [ParsedUser] = [] {
        didSet {
            userTable.reloadData()
        }
    }
    
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
        searchView.updateTheme()
        
        navigationItem.leftBarButtonItem = customBackButton
        view.backgroundColor = .background
        navigationExtender.backgroundColor = .background
        navigationBorder.backgroundColor = .background3
    }
}

private extension SearchViewController {
    func setup() {
        navigationItem.titleView = searchView
        updateTheme()
        setBindings()
        
        let stack = UIStackView(arrangedSubviews: [navigationExtender, navigationBorder, userTable])
        view.addSubview(stack)
        stack.axis = .vertical
        stack.pinToSuperview(safeArea: true)
        
        userTable.register(UserInfoTableCell.self, forCellReuseIdentifier: "userCell")
        userTable.register(SearchTermTableCell.self, forCellReuseIdentifier: "search")
        userTable.separatorStyle = .none
        userTable.delegate = self
        userTable.dataSource = self
        
        searchView.inputField.delegate = self
        searchView.inputField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    func setBindings() {
        $userSearchText
            .flatMap { [weak self] text -> AnyPublisher<PostRequestResult, Never> in
                self?.userTable.reloadData()
                
                switch text {
                case "":
                    return SocketRequest(name: "user_infos", payload: .object([
                        "pubkeys": .array(PostingTextViewManager.recommendedUsersNpubs.map { .string($0) })
                    ])).publisher()
                default:
                   return SocketRequest(name: "user_search", payload: .object([
                       "query": .string(text),
                       "limit": .number(15),
                   ])).publisher()
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                self?.users = result.users.map { result.createParsedUser($0.value) }.sorted(by: { ($0.likes ?? 0) > ($1.likes ?? 0) } )
            })
            .store(in: &cancellables)
    }
    
    @objc func textFieldDidChange() {
        userSearchText = searchView.inputField.text ?? ""
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let feed = RegularFeedViewController(feed: FeedManager(search: userSearchText))
        show(feed, sender: nil)
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
            (cell as? SearchTermTableCell)?.termLabel.text = userSearchText.isEmpty ? "Enter text to search" : userSearchText
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        (cell as? UserInfoTableCell)?.update(user: users[indexPath.row - 1])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if userSearchText.isEmpty { return }
            
            let feed = RegularFeedViewController(feed: FeedManager(search: userSearchText))
            show(feed, sender: nil)
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
        let width = widthAnchor.constraint(equalToConstant: 235)
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
