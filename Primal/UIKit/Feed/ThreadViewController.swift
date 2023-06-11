//
//  ThreadViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 3.5.23..
//

import Combine
import UIKit

final class ThreadViewController: FeedViewController {
    var request: AnyCancellable?
    let id: String
    
    var didPostNewComment = false
        
    var mainPositionInThread = 0
    
    private var didMoveToMain = false
    @Published private var didLoadView = false
    @Published private var didLoadData = false
    
    private var textHeightConstraint: NSLayoutConstraint?
    private let textInputView = SelfSizingTextView()
    private let placeholderLabel = UILabel()
    private let inputParent = UIView()
    private let inputBackground = UIView()
    
    private let buttonStack = UIStackView()
    private let replyingToLabel = UILabel()
    
    private var inputManager = PostingTextViewManager()
    
    init(threadId: String) {
        id = threadId
        super.init(feed: FeedManager(threadId: threadId))
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        didLoadView = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }    
    
    override func open(post: PrimalFeedPost) {
        guard post.id != id else { return }
        
        guard let index = posts.firstIndex(where: { $0.post == post }) else {
            super.open(post: post)
            return
        }
        
        if index < mainPositionInThread {
            for vc in navigationController?.viewControllers ?? [] {
                guard let thread = vc as? ThreadViewController else { continue }
                if thread.id == post.id {
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
            cell.update(data,
                        position: {
                            if mainPositionInThread < indexPath.row {
                                return .child
                            }
                            if mainPositionInThread > indexPath.row {
                                return .parent
                            }
                            return .main
                        }(),
                        didLike: LikeManager.instance.hasLiked(data.post.id),
                        didRepost: PostManager.instance.hasReposted(data.post.id)
            )
            cell.delegate = self
        }
        return cell
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        table.register(ThreadCell.self, forCellReuseIdentifier: "cell")
        
        inputParent.backgroundColor = inputManager.isEditing ? .background2 : .background
        inputBackground.backgroundColor = inputManager.isEditing ? .background : .background3
        
        guard !posts.isEmpty else { return }
        
        placeholderLabel.text = "Reply to \(posts[mainPositionInThread].user.displayName)"
        replyingToLabel.attributedText = replyToString(name: posts[mainPositionInThread].user.name)
    }
}

private extension ThreadViewController {
    @objc func postButtonPressed() {
        guard let text = textInputView.text, !text.isEmpty else {
            showErrorMessage("Text mustn't be empty")
            return
        }
        
        textInputView.isEditable = false
        
        PostManager.instance.sendReplyEvent(text, post: posts[mainPositionInThread].post) {
            self.textInputView.isEditable = true
            self.textInputView.text = ""
            self.placeholderLabel.isHidden = false
            self.didPostNewComment = true
            self.didMoveToMain = false
            self.feed.requestThread(postId: self.id)
        }
    }
    
    func addPublishers() {
        feed.$parsedPosts.receive(on: DispatchQueue.main).sink { [weak self] parsed in
            guard let self, !parsed.isEmpty else { return }
            
            self.posts = parsed.sorted(by: { $0.post.created_at < $1.post.created_at })
            self.mainPositionInThread = self.posts.firstIndex(where: { $0.post.id == self.id }) ?? 0
            
            self.didLoadData = true
            
            self.placeholderLabel.text = "Reply to \(parsed[self.mainPositionInThread].user.displayName)"
            
            self.replyingToLabel.attributedText = self.replyToString(name: parsed[self.mainPositionInThread].user.name)
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest($didLoadData, $didLoadView).sink(receiveValue: { [weak self] in
            guard let self, $0 && $1 && !didMoveToMain else { return }
            
            self.didMoveToMain = true
            
            if self.didPostNewComment {
                self.didPostNewComment = false
                DispatchQueue.main.async {
                    self.table.scrollToRow(at: IndexPath(row: self.posts.count - 1, section: 0), at: .top, animated: true)
                }
            } else {
                self.table.scrollToRow(at: IndexPath(row: self.mainPositionInThread, section: 0), at: .top, animated: false)
            }
        })
        .store(in: &cancellables)
        
        inputManager.$isEditing.sink { [unowned self] isEditing in
            self.textHeightConstraint?.isActive = !isEditing
            self.placeholderLabel.isHidden = isEditing || !self.textInputView.text.isEmpty
            UIView.animate(withDuration: 0.2) {
                self.inputParent.backgroundColor = isEditing ? .background2 : .background
                self.inputBackground.backgroundColor = isEditing ? .background : .background3
                
                self.replyingToLabel.isHidden = !isEditing
                self.replyingToLabel.alpha = isEditing ? 1 : 0
                
                self.buttonStack.isHidden = !isEditing
                self.buttonStack.alpha = isEditing ? 1 : 0
                
                self.textInputView.layoutIfNeeded()
            }
        }
        .store(in: &cancellables)
    }
    
    func setup() {
        addPublishers()
        
        title = "Thread"
        
        table.keyboardDismissMode = .onDrag
        
        let button = UIButton()
        button.setImage(UIImage(named: "back"), for: .normal)
        button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        button.constrainToSize(44)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        
        inputBackground.layer.cornerRadius = 6
        
        let inputStack = UIStackView(arrangedSubviews: [replyingToLabel, inputBackground, buttonStack])
        inputStack.axis = .vertical
        
        inputParent.addSubview(inputStack)
        inputBackground.addSubview(placeholderLabel)
        inputBackground.addSubview(textInputView)
        
        placeholderLabel
            .pinToSuperview(edges: .leading, padding: 21)
            .pinToSuperview(edges: .top, padding: 13)
        
        textInputView
            .pinToSuperview(edges: .horizontal, padding: 16)
            .pinToSuperview(edges: .vertical, padding: 5)
        
        inputStack
            .pinToSuperview(edges: .horizontal, padding: 20)
            .pinToSuperview(edges: .top, padding: 16)
            .pinToSuperview(edges: .bottom)
        
        inputStack.spacing = 4
        inputStack.setCustomSpacing(8, after: replyingToLabel)
        
        textInputView.backgroundColor = .clear
        textInputView.font = .appFont(withSize: 16, weight: .regular)
        textInputView.textColor = .foreground2
        textInputView.delegate = inputManager
        
        setupMainStack()
        
        let imageButton = UIButton()
        imageButton.setImage(UIImage(named: "ImageIcon"), for: .normal)
        imageButton.constrainToSize(48)
        
        let cameraButton = UIButton()
        cameraButton.setImage(UIImage(named: "CameraIcon"), for: .normal)
        cameraButton.constrainToSize(48)
        
        let postButton = GradientInGradientButton(title: "Reply")
        postButton.titleLabel.font = .appFont(withSize: 14, weight: .medium)
        postButton.constrainToSize(width: 80, height: 28)
        postButton.addTarget(self, action: #selector(postButtonPressed), for: .touchUpInside)
        
        [imageButton, cameraButton, UIView(), postButton].forEach {
            buttonStack.addArrangedSubview($0)
        }
        
        buttonStack.alignment = .center
        
        placeholderLabel.font = .appFont(withSize: 16, weight: .regular)
        placeholderLabel.textColor = .foreground4
        
        buttonStack.isHidden = true
        buttonStack.alpha = 0
        replyingToLabel.isHidden = true
        replyingToLabel.alpha = 0
        
        textInputView.heightAnchor.constraint(greaterThanOrEqualToConstant: 35).isActive = true
        textHeightConstraint = textInputView.heightAnchor.constraint(equalToConstant: 35)
    }
    
    func setupMainStack() {
        [navigationBarLengthner, table].forEach { $0.removeFromSuperview() }
        let stack = UIStackView(arrangedSubviews: [navigationBarLengthner, table, inputParent])
        view.addSubview(stack)
        
        stack.axis = .vertical
        
        stack.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, safeArea: true)
        stack.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
    }
    
    func replyToString(name: String) -> NSAttributedString {
        let value = NSMutableAttributedString()
        value.append(NSAttributedString(string: "Replying to ", attributes: [
            .font: UIFont.appFont(withSize: 14, weight: .medium),
            .foregroundColor: UIColor.foreground4
        ]))
        value.append(NSAttributedString(string: "@\(name)", attributes: [
            .font: UIFont.appFont(withSize: 14, weight: .medium),
            .foregroundColor: UIColor.accent
        ]))
        return value
    }
}
