//
//  ChatListViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 16.5.23..
//

import Combine
import UIKit

final class ChatListViewController: UIViewController, Themeable {
    
    private let selectedType: ChatManager.Relation
    private let manager: ChatManager
    
    private let table = UITableView()
    
    private let loadingSpinner = LoadingSpinnerView()
    
    var chats: [Chat] = [] {
        didSet {
            if oldValue.first?.latest.id == chats.first?.latest.id, oldValue.count < chats.count {
                UIView.performWithoutAnimation {
                    let newRows: [IndexPath] = (oldValue.count..<chats.count).map { IndexPath(row: $0, section: 0) }
                    table.insertRows(at: newRows, with: .none)
                }
                return
            }
            
            UIView.transition(with: table, duration: 0.1, options: .transitionCrossDissolve) {
                self.table.reloadData()
            }
        }
    }

    var isLoading = false
    var shouldLoadNextPage = false
    var startFromZero = true
    var didReachEnd = false
    
    var cancellables: Set<AnyCancellable> = []
    
    init(selectedType: ChatManager.Relation, manager: ChatManager) {
        self.selectedType = selectedType
        self.manager = manager
        super.init(nibName: nil, bundle: nil)
        
        reload()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Messages"
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        mainTabBarController?.setTabBarHidden(false, animated: animated)
        
        reload()
    }
    
    func updateTheme() {
        view.backgroundColor = .background
        
        table.backgroundColor = .background2
        table.reloadData()
    }
}

private extension ChatListViewController {
    func setup() {
        updateTheme()
        
        view.addSubview(table)
        table.pinToSuperview()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addAction(.init(handler: { [weak self] _ in
            self?.reload()
        }), for: .valueChanged)
        
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.refreshControl = refreshControl
        table.register(ChatTableCell.self, forCellReuseIdentifier: "cell")
        table.contentInset = .init(top: 0, left: 0, bottom: 60, right: 0)
        
        view.addSubview(loadingSpinner)
        loadingSpinner.centerToSuperview().constrainToSize(70)
        loadingSpinner.isHidden = true
        loadingSpinner.play()
        
        manager.$newMessagesCount.withPrevious().receive(on: DispatchQueue.main).sink { [weak self] oldCount, count in
            guard oldCount != count, let self, self.view.window != nil, self.navigationController?.topViewController == self.parent else { return }
            
            self.getAllChats()
        }
        .store(in: &cancellables)
    }
    
    func getAllChats() {
        let type = selectedType
        manager.getAllChats(type) { [weak self] chats in
            let chats = chats.filter { !MuteManager.instance.isMutedUser($0.user.data.pubkey) }
            
            if self?.selectedType != type { return }
            
            self?.chats = chats
            self?.loadingSpinner.isHidden = true
            self?.loadingSpinner.stop()
            self?.table.refreshControl?.endRefreshing()
        }
    }
    
    func reload() {
        isLoading = false
        didReachEnd = false
        shouldLoadNextPage = false
        startFromZero = true
        loadChatsIfNecessary()
    }
    
    func loadChatsIfNecessary() {
        guard !didReachEnd, !isLoading else {
            shouldLoadNextPage = true
            return
        }
        let type = selectedType
        let startFromZero = startFromZero
        
        isLoading = true
        manager.getRecentChats(type, until: startFromZero ? nil : Int((chats.last?.latest.date ?? .now).timeIntervalSince1970)) { [weak self] chats in
            guard let self, selectedType == type else { return }
            
            var chats = startFromZero ? chats : chats.filter { newChat in !self.chats.contains(where: { $0.user.data.npub == newChat.user.data.npub })}
            
            didReachEnd = chats.isEmpty
            isLoading = false
            
            chats = chats.filter { !MuteManager.instance.isMutedUser($0.user.data.pubkey) }
            
            if startFromZero {
                self.chats = chats
            } else {
                self.chats += chats
            }
            
            self.startFromZero = false
            loadingSpinner.isHidden = true
            loadingSpinner.stop()
            table.refreshControl?.endRefreshing()
            
            if shouldLoadNextPage {
                shouldLoadNextPage = false
                loadChatsIfNecessary()
            }
        }
    }
}

extension ChatListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? ChatTableCell {
            cell.updateTheme()
            cell.setup(chat: chats[indexPath.row])
        }
        
        if indexPath.row > chats.count - 20 {
            loadChatsIfNecessary()
        }
        
        return cell
    }
}

extension ChatListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        show(ChatViewController(user: chats[indexPath.row].user, chatManager: manager), sender: nil)
    }
}
