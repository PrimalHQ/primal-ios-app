//
//  WalletPickUserController.swift
//  Primal
//
//  Created by Pavle Stevanović on 11.10.23..
//

import Combine
import UIKit

final class WalletPickUserController: UIViewController, Themeable {
    let searchBackground = UIView()
    let searchIcon = UIImageView(image: UIImage(named: "searchIconSmall")?.withRenderingMode(.alwaysTemplate)).constrainToSize(20)
    let searchInput = UITextField()
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
        
        mainTabBarController?.setTabBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchInput.becomeFirstResponder()
    }
    
    func updateTheme() {
        navigationItem.leftBarButtonItem = customBackButton
        view.backgroundColor = .background
        
        searchBackground.backgroundColor = .background3
        searchIcon.tintColor = .foreground4
        searchInput.textColor = .foreground
        searchInput.attributedPlaceholder = NSAttributedString(string: "Search users", attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .foregroundColor: UIColor.foreground4
        ])
    }
    
    @objc func inputTapped() {
        searchInput.becomeFirstResponder()
    }
}

private extension WalletPickUserController {
    func setup() {
        title = "Choose Recipient"
        updateTheme()
        setBindings()
        
        let searchParent = UIView()
        searchParent.addSubview(searchBackground)
        searchBackground.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .vertical, padding: 16).constrainToSize(height: 40)
        searchBackground.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(inputTapped)))
        
        let inputStack = UIStackView([searchIcon, searchInput])
        searchBackground.addSubview(inputStack)
        inputStack.pinToSuperview(edges: .horizontal, padding: 12).centerToSuperview()
        inputStack.alignment = .center
        inputStack.spacing = 12
        
        let stack = UIStackView(arrangedSubviews: [searchParent, userTable])
        view.addSubview(stack)
        stack.axis = .vertical
        stack.pinToSuperview(edges: [.horizontal, .top], safeArea: true)
        stack.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        
        userTable.register(UserInfoTableCell.self, forCellReuseIdentifier: "userCell")
        userTable.separatorStyle = .none
        userTable.delegate = self
        userTable.dataSource = self
        
        searchBackground.layer.cornerRadius = 8
        
        searchInput.font = .appFont(withSize: 16, weight: .regular)
        searchInput.placeholder = "Search users"
        searchInput.delegate = self
        searchInput.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
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
        userSearchText = searchInput.text ?? ""
    }
}

extension WalletPickUserController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let feed = RegularFeedViewController(feed: FeedManager(search: userSearchText))
        show(feed, sender: nil)
        return true
    }
}

extension WalletPickUserController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        (cell as? UserInfoTableCell)?.update(user: users[indexPath.row])
        cell.contentView.backgroundColor = .background2
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat = WalletSendViewController(user: users[indexPath.row])
        searchInput.resignFirstResponder()
        show(chat, sender: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.navigationController?.viewControllers.remove(object: self)
        }
    }
}
