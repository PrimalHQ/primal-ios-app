//
//  NoteLikesViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 19.4.24..
//

import Combine
import UIKit

class NoteLikesViewController: UIViewController, Themeable {
    private let table = UITableView()
    private let emptyView = EmptyTableView(title: "There are no likes for this note yet")
    
    var users: [ParsedUser] = [] {
        didSet {
            table.reloadData()
            
            emptyView.isHidden = !users.isEmpty
        }
    }
    var cancellables: Set<AnyCancellable> = []
    
    let noteId: String
    init(noteId: String) {
        self.noteId = noteId
        super.init(nibName: nil, bundle: nil)
        
        view.addSubview(table)
        table.pinToSuperview(safeArea: true)
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.register(LikeUserTableViewCell.self, forCellReuseIdentifier: "cell")
        
        view.addSubview(emptyView)
        emptyView.isHidden = true
        emptyView.refresh.addAction(.init(handler: { [unowned self] _ in
            refresh()
        }), for: .touchUpInside)
        
        refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        table.reloadData()
    }
    
    func refresh() {
        NoteLikesRequest(noteId: noteId).publisher()
            .receive(on: DispatchQueue.main)
            .assign(to: \.users, onWeak: self)
            .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        table.backgroundColor = .background
    }
}

extension NoteLikesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { users.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        (cell as? LikeUserTableViewCell)?.updateForUser(users[indexPath.row])
        return cell
    }
}

extension NoteLikesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        show(ProfileViewController(profile: users[indexPath.row]), sender: nil)
    }
}
