//
//  ChatViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 8.9.23..
//

import UIKit
import FLAnimatedImage

final class ChatViewController: UIViewController, Themeable {
    var table = UITableView()
    
    let chatManager = ChatManager()
    
    var messages: [ProcessedMessage] = [] {
        didSet {
            table.reloadData()
        }
    }
    
    let user: ParsedUser
    
    init(user: ParsedUser) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        setup()
        
        navigationItem.rightBarButtonItem = navigationBarButton(for: user)
        
        chatManager.getChatMessages(pubkey: user.data.pubkey) { result in
            print(result)
            self.messages = result
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        navigationItem.leftBarButtonItem = customBackButton
        navigationItem.titleView = navigationBarTitle(for: user)
        
        view.backgroundColor = .background
    }
}

private extension ChatViewController {
    func setup() {
        updateTheme()
        
        view.addSubview(table)
        table.pinToSuperview(edges: [.horizontal, .top], safeArea: true).pinToSuperview(edges: .bottom, padding: 56, safeArea: true)
        table.transform = .init(rotationAngle: .pi)
        table.dataSource = self
        table.separatorStyle = .none
        table.register(ChatMessageCell.self, forCellReuseIdentifier: "cell")
    }
    
    func navigationBarTitle(for user: ParsedUser) -> UIView {
        let first = UILabel()
        let second = UILabel()
        
        first.text = user.data.firstIdentifier
        second.text = user.data.secondIdentifier
        
        first.font = .appFont(withSize: 18, weight: .bold)
        first.textColor = .foreground
        
        second.font = .appFont(withSize: 14, weight: .regular)
        second.textColor = .foreground4
        second.isHidden = second.text?.isEmpty != false
        
        let stack = UIStackView(axis: .vertical, [first, second])
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }
    
    func navigationBarButton(for user: ParsedUser) -> UIBarButtonItem {
        let button = UIButton()
        button.addAction(.init(handler: { [weak self] _ in
            self?.show(ProfileViewController(profile: user), sender: nil)
        }), for: .touchUpInside)
        let imageView = FLAnimatedImageView(frame: .init(origin: .zero, size: .init(width: 36, height: 36))).constrainToSize(36)
        imageView.layer.cornerRadius = 18
        imageView.layer.masksToBounds = true
        imageView.setUserImage(user)
        let parent = UIView()
        parent.addSubview(imageView)
        imageView.centerToSuperview()
        parent.addSubview(button)
        button.pinToSuperview()
        return .init(customView: parent)
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let row = indexPath.row
        let userId = messages[row].user.data.npub
        cell.transform = tableView.transform
        (cell as? ChatMessageCell)?.setupWith(message: messages[row], isFirstInSeries: row == 0 || messages[row - 1].user.data.npub != userId)
        return cell
    }
}
