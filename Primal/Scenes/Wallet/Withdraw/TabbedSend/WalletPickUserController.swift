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
        userTable.keyboardDismissMode = .onDrag
        
        searchBackground.layer.cornerRadius = 8
        
        searchInput.font = .appFont(withSize: 16, weight: .regular)
        searchInput.placeholder = "Search users"
        searchInput.delegate = self
        searchInput.returnKeyType = .done
        searchInput.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
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
    
    @objc func textFieldDidChange() {
        userSearchText = searchInput.text ?? ""
    }
}

extension WalletPickUserController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

extension WalletPickUserController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        if let cell = cell as? UserInfoTableCell, let user = users[safe: indexPath.row] {
            cell.update(user: user)
            cell.secondaryLabel.text = user.data.lud16.isEmpty ? user.data.lud06 : user.data.lud16
            cell.secondaryLabel.textColor = .foreground3
            cell.secondaryLabel.isHidden = cell.secondaryLabel.text?.isEmpty == true
            cell.nameLabel.font = .appFont(withSize: 16, weight: .semibold)
        }
        cell.contentView.backgroundColor = .background2
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let user = users[safe: indexPath.row] else { return }
        searchInput.resignFirstResponder()
        
        SmartContactsManager.instance.addContact(user)
        show(WalletSendAmountController(.user(user)), sender: nil)
    }
}
