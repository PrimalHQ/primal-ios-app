//
//  ChatSearchController.swift
//  Primal
//
//  Created by Pavle Stevanović on 8.9.23..
//

import Combine
import UIKit

final class ChatSearchController: UIViewController, Themeable {
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
    
    let manager: ChatManager
    init(manager: ChatManager) {
        self.manager = manager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.transform = .identity
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
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

private extension ChatSearchController {
    func setup() {
        title = "New Message"
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
            .flatMap { [weak self] in
                self?.userTable.reloadData()
                
                return SmartContactsManager.instance.userSearchPublisher($0)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                self?.users = result
            })
            .store(in: &cancellables)
    }
    
    @objc func textFieldDidChange() {
        userSearchText = searchInput.text ?? ""
    }
}

extension ChatSearchController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let first = users.first else { return false }
        show(ChatViewController(user: first, chatManager: manager), sender: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.navigationController?.viewControllers.remove(object: self)
        }
        return true
    }
}

extension ChatSearchController: UITableViewDelegate, UITableViewDataSource {
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
        let chat = ChatViewController(user: users[indexPath.row], chatManager: manager)
        searchInput.resignFirstResponder()
        show(chat, sender: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.navigationController?.viewControllers.remove(object: self)
        }
    }
}
