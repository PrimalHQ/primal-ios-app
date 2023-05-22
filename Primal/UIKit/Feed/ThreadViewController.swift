//
//  ThreadViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 3.5.23..
//

import Combine
import UIKit

class ThreadViewController: FeedViewController {
    var request: AnyCancellable?
    let id: String
    
    var mainPositionInThread = 0
    
    private var didMoveToMain = false
    @Published private var didLoadView = false
    @Published private var didLoadData = false
    
    private var textHeightConstraint: NSLayoutConstraint?
    let textInputView = UITextField()
    
    init(feed: SocketManager, threadId: String) {
        id = threadId
        super.init(feed: feed)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        didLoadView = true
    }
    
    override func open(post: PrimalPost) {
        guard post.post.id != id else { return }
        
        guard let index = posts.firstIndex(where: { $0.0 == post }) else {
            super.open(post: post)
            return
        }
        
        if index < mainPositionInThread {
            for vc in navigationController?.viewControllers ?? [] {
                guard let thread = vc as? ThreadViewController else { continue }
                if thread.id == post.post.id {
                    thread.didMoveToMain = false
                    navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }
        }
        
        super.open(post: post)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? ThreadCell {
            let data = posts[indexPath.row]
            cell.update(data.0,
                        parsedContent: data.1,
                        position: {
                            if mainPositionInThread < indexPath.row {
                                return .child
                            }
                            if mainPositionInThread > indexPath.row {
                                return .parent
                            }
                            return .main
                        }(),
                        didLike: likingManager.hasLiked(data.0.post.id),
                        didRepost: repostingManager.hasReposted(data.0.post.id)
            )
            cell.delegate = self
        }
        return cell
    }
}

private extension ThreadViewController {
    func setup() {
        title = "Thread"
        
        feed.requestThread(postId: id, subId: id)
        feed.postsEmitter.sink { [weak self] (id, posts) in
            guard let self, id == self.id else { return }
            
            let parsed = posts.sorted(by: { $0.post.created_at < $1.post.created_at }).map { $0.process() }
            
            DispatchQueue.main.async {
                self.mainPositionInThread = parsed.firstIndex(where: { $0.0.post.id == self.id }) ?? 0
                self.posts = parsed
                
                self.didLoadData = true
                
                self.textInputView.attributedPlaceholder = NSAttributedString(
                    string: "Reply to \(parsed[self.mainPositionInThread].0.user.displayName)",
                    attributes: [
                        .font: UIFont.appFont(withSize: 16, weight: .regular),
                        .foregroundColor: UIColor(rgb: 0x757575)
                    ]
                )
                self.textInputView.placeholder = "Reply to \(parsed[self.mainPositionInThread].0.user.displayName)"
            }
            
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest($didLoadData, $didLoadView).sink(receiveValue: { [weak self] in
            guard let self, $0 && $1 && !didMoveToMain else { return }
            
            self.didMoveToMain = true
            self.table.scrollToRow(at: IndexPath(row: self.mainPositionInThread, section: 0), at: .top, animated: false)
        })
        .store(in: &cancellables)
        
        table.register(ThreadCell.self, forCellReuseIdentifier: "cell")
        table.keyboardDismissMode = .interactive
        
        let button = UIButton()
        button.setImage(UIImage(named: "back"), for: .normal)
        button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        button.constrainToSize(44)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        
        let inputParent = UIView()
        let inputBackground = UIView()
        
        inputParent.backgroundColor = .black
        inputBackground.backgroundColor = UIColor(rgb: 0x222222)
        inputBackground.layer.cornerRadius = 6
        
        inputParent.addSubview(inputBackground)
        inputBackground.addSubview(textInputView)
        textInputView.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .vertical, padding: 6).constrainToSize(height: 32)
        inputBackground.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .top, padding: 16).pinToSuperview(edges: .bottom)
        
        let keyboardMasker = UIView()
        let spacer = UIView()
        [navigationBarLengthner, table].forEach { $0.removeFromSuperview() }
        let stack = UIStackView(arrangedSubviews: [navigationBarLengthner, table, inputParent, spacer, keyboardMasker])
        view.addSubview(stack)
        
        stack.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, safeArea: true)
        let bottom = stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        bottom.priority = .defaultLow
        bottom.isActive = true
        
        stack.axis = .vertical
        
        textInputView.font = .appFont(withSize: 16, weight: .regular)
        
        inputParent.heightAnchor.constraint(equalToConstant: 60).isActive = true
        keyboardMasker.topAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        spacer.heightAnchor.constraint(equalTo: keyboardMasker.heightAnchor, multiplier: 0.03).isActive = true
    }
}
