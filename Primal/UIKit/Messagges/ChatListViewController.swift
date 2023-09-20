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
    
    private let newChatButton = UIButton()
    
    var chats: [Chat] = [] {
        didSet {
            UIView.transition(with: table, duration: 0.1, options: .transitionCrossDissolve) {
                self.table.reloadData()
            }
        }
    }
    
    var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Messages"
        
        setup()
        
        $selectedType.sink { [weak self] relation in
            self?.manager.getRecentChats(relation) { chats in
                self?.chats = chats
            }
            
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.updateButtonFonts()
                self.selectionIndicator.removeFromSuperview()
                self.view.addSubview(self.selectionIndicator)
                
                self.selectionIndicator.pin(to: relation == .follows ? self.followsButton : self.otherButton, edges: [.horizontal, .bottom]).constrainToSize(height: 4)
                UIView.animate(withDuration: 0.2) {
                    self.view.layoutIfNeeded()
                }
            }
        }
        .store(in: &cancellables)
    }
    
    func updateTheme() {
        updateButtonFonts()
        table.backgroundColor = .background
        
        selectionIndicator.backgroundColor = .accent
        
        followsButton.setTitleColor(.foreground, for: .normal)
        otherButton.setTitleColor(.foreground, for: .normal)
        markAllRead.setTitleColor(.accent, for: .normal)
        
        newChatButton.backgroundColor = .gradientColor(bounds: .init(width: 56, height: 56), startPoint: .zero, endPoint: .init(x: 1, y: 1))
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
        let vStack = UIStackView(axis: .vertical, [hstack.constrainToSize(height: 46), SpacerView(height: 4), table])
        
        view.addSubview(vStack)
        vStack.pinToSuperview(edges: [.horizontal, .bottom]).pinToSuperview(edges: .top, safeArea: true)
        
        view.addSubview(selectionIndicator)
        selectionIndicator.pin(to: followsButton, edges: [.horizontal, .bottom]).constrainToSize(height: 4)
        selectionIndicator.layer.cornerRadius = 2
        
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.register(ChatTableCell.self, forCellReuseIdentifier: "cell")
        
        followsButton.setTitle("FOLLOWS", for: .normal)
        otherButton.setTitle("OTHER", for: .normal)
        markAllRead.setTitle("Mark All Read", for: .normal)
        
        markAllRead.titleLabel?.font = .appFont(withSize: 14, weight: .regular)
        
        view.addSubview(newChatButton)
        newChatButton.pinToSuperview(edges: .trailing, padding: 8).pinToSuperview(edges: .bottom, padding: 64, safeArea: true).constrainToSize(56)
        newChatButton.setImage(UIImage(named: "newChat"), for: .normal)
        newChatButton.layer.cornerRadius = 28
        
        newChatButton.addAction(.init(handler: { [weak self] _ in
            self?.show(ChatSearchController(), sender: nil)
        }), for: .touchUpInside)
        
        otherButton.addAction(.init(handler: { [weak self] _ in
            self?.selectedType = .other
        }), for: .touchUpInside)
        followsButton.addAction(.init(handler: { [weak self] _ in
            self?.selectedType = .follows
        }), for: .touchUpInside)
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
        return cell
    }
}

extension ChatListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        show(ChatViewController(user: chats[indexPath.row].user), sender: nil)
    }
}
