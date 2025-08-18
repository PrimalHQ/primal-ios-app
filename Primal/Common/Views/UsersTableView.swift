//
//  UsersTableView.swift
//  Primal
//
//  Created by Pavle Stevanović on 15. 8. 2025..
//

import Combine
import UIKit

protocol UsersTableViewDelegate: AnyObject {
    func usersTableDidSelectUser(_ table: UsersTableView, user: ParsedUser)
}

class UsersTableView: UIView {
    
    @Published var userSearchText: String?
    
    private var users: [ParsedUser] = [] {
        didSet {
            table.reloadData()
            isHidden = users.isEmpty
            
            heightConstraint.constant = CGFloat(users.count) * 60
        }
    }
    
    private let table = UITableView(frame: .zero, style: .plain)
    
    weak var delegate: UsersTableViewDelegate?
    
    private var cancellables: Set<AnyCancellable> = []
    private var currentSearchPublisher: AnyCancellable?
    
    private var heightConstraint: NSLayoutConstraint!
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        isHidden = true
        
        addSubview(table)
        table.pinToSuperview()
        
        table.separatorStyle = .none
        table.delegate = self
        table.dataSource = self
        table.register(UserInfoTableCell.self, forCellReuseIdentifier: "cell")
        table.bounces = false
        
        heightConstraint = heightAnchor.constraint(equalToConstant: 60)
        heightConstraint.priority = .init(100)
        heightConstraint.isActive = true
        
        $userSearchText
            .sink(receiveValue: { [weak self] text in
                guard let text else {
                    self?.currentSearchPublisher = nil
                    self?.users = []
                    return
                }
                self?.currentSearchPublisher = SmartContactsManager.instance.userSearchPublisher(text)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: { users in
                        self?.users = users
                    })
            })
            .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}


extension UsersTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let data = users[safe: indexPath.row] else { return }
        delegate?.usersTableDidSelectUser(self, user: data)
    }
}

extension UsersTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let user = users[safe: indexPath.row] {
            (cell as? UserInfoTableCell)?.update(user: user)
        }
        return cell
    }
}
