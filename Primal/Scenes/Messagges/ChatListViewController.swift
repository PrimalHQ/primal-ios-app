//
//  ChatListViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 16.5.23..
//

import Combine
import UIKit

final class ChatListViewController: UIViewController, Themeable {
    
    @Published var selectedType: ChatManager.Relation = .follows
    
    private let manager = ChatManager()
    
    private let table = UITableView()
    private let followsButton = UIButton()
    private let otherButton = UIButton()
    private let markAllRead = UIButton()
    private let selectionIndicator = UIView()
    
    private let loadingSpinner = LoadingSpinnerView()
    
    private let newChatButton = UIButton()
    
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
    
    var follows: [Chat] = []
    var others: [Chat] = []

    var isLoading = false
    var shouldLoadNextPage = false
    var startFromZero = true
    var didReachEnd = false
    
    var cancellables: Set<AnyCancellable> = []
    
    init() {
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
        
        $selectedType.dropFirst().sink { [weak self] relation in
            guard let self else { return }
            
            chats = relation == .follows ? follows : others
            
            if chats.isEmpty {
                loadingSpinner.isHidden = false
                loadingSpinner.play()
            }
            
            // We need to do this async because this event fires on willChange, so the value of selectedType is still not updated
            DispatchQueue.main.async {
                self.reload()
                
                self.updateButtonFonts()
                self.selectionIndicator.removeFromSuperview()
                self.view.addSubview(self.selectionIndicator)
                
                self.selectionIndicator.pin(to: relation == .follows ? self.followsButton : self.otherButton, edges: [.horizontal, .bottom]).constrainToSize(height: 4)
                
                if self.view.window != nil {
                    UIView.animate(withDuration: 0.2) {
                        self.view.layoutIfNeeded()
                    }
                }
            }
        }
        .store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        mainTabBarController?.setTabBarHidden(false, animated: animated)
        
        reload()
    }
    
    func updateTheme() {
        view.backgroundColor = .background
        
        updateButtonFonts()
        table.backgroundColor = .background2
        
        selectionIndicator.backgroundColor = .accent
        
        followsButton.setTitleColor(.foreground, for: .normal)
        otherButton.setTitleColor(.foreground, for: .normal)
        markAllRead.setTitleColor(.accent, for: .normal)
        
        newChatButton.backgroundColor = .accent
    }
    
    func updateButtonFonts() {
        followsButton.titleLabel?.font = .appFont(withSize: 14, weight: selectedType == .follows ? .bold : .regular)
        otherButton.titleLabel?.font = .appFont(withSize: 14, weight: selectedType == .other ? .bold : .regular)
    }
}

private extension ChatListViewController {
    func setup() {
        updateTheme()
        
        let hstack = UIStackView([SpacerView(width: 12), followsButton, SpacerView(width: 32), otherButton, UIView(), markAllRead, SpacerView(width: 12)])
        let vStack = UIStackView(axis: .vertical, [
            hstack.constrainToSize(height: 46),
            SpacerView(height: 4),
            ThemeableView().constrainToSize(height: 1).setTheme { $0.backgroundColor = .background3 },
            table
        ])
        
        view.addSubview(vStack)
        vStack.pinToSuperview(edges: [.horizontal, .bottom]).pinToSuperview(edges: .top, safeArea: true)
        
        view.addSubview(selectionIndicator)
        selectionIndicator.pin(to: followsButton, edges: [.horizontal, .bottom]).constrainToSize(height: 4)
        selectionIndicator.layer.cornerRadius = 2
        
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
        
        followsButton.setTitle("FOLLOWS", for: .normal)
        otherButton.setTitle("OTHER", for: .normal)
        markAllRead.setTitle("Mark All Read", for: .normal)
        
        markAllRead.titleLabel?.font = .appFont(withSize: 14, weight: .regular)
        
        view.addSubview(newChatButton)
        newChatButton.pinToSuperview(edges: .trailing, padding: 8).pinToSuperview(edges: .bottom, padding: 64, safeArea: true).constrainToSize(56)
        newChatButton.setImage(UIImage(named: "newChat"), for: .normal)
        newChatButton.layer.cornerRadius = 28
        
        view.addSubview(loadingSpinner)
        loadingSpinner.centerToSuperview().constrainToSize(70)
        loadingSpinner.isHidden = true
        loadingSpinner.play()
        
        newChatButton.addAction(.init(handler: { [weak self] _ in
            self?.show(ChatSearchController(manager: self!.manager), sender: nil)
        }), for: .touchUpInside)
        
        otherButton.addAction(.init(handler: { [weak self] _ in
            self?.selectedType = .other
        }), for: .touchUpInside)
        
        followsButton.addAction(.init(handler: { [weak self] _ in
            self?.selectedType = .follows
        }), for: .touchUpInside)
        
        markAllRead.addAction(.init(handler: { [weak self] _ in
            self?.manager.markAllChatsAsRead()
        }), for: .touchUpInside)
        
        manager.updateChatCount()
        manager.$newMessagesCount.withPrevious().receive(on: DispatchQueue.main).sink { [weak self] oldCount, count in
            guard let main: MainTabBarController = RootViewController.instance.findInChildren() else { return }
            main.hasNewMessages = count > 0
            
            guard oldCount != count, let self, self.view.window != nil, self.navigationController?.topViewController == self.parent else { return }
            
            self.getAllChats()
        }
        .store(in: &cancellables)
    }
    
    func getAllChats() {
        let type = selectedType
        manager.getAllChats(type) { [weak self] chats in
            let chats = chats.filter { !MuteManager.instance.isMuted($0.user.data.pubkey) }
            
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
            
            chats = chats.filter { !MuteManager.instance.isMuted($0.user.data.pubkey) }
            
            if startFromZero {
                self.chats = chats
                
                if type == .follows {
                    follows = chats
                } else {
                    others = chats
                }
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
