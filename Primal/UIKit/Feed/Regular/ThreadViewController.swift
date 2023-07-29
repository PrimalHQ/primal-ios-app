//
//  ThreadViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 3.5.23..
//

import Combine
import UIKit

final class ThreadViewController: PostFeedViewController {
    let id: String
    
    var didPostNewComment = false
        
    var mainPositionInThread = 0
    
    private var didMoveToMain = false
    @Published private var didLoadView = false
    @Published private var didLoadData = false
    
    private var textHeightConstraint: NSLayoutConstraint?
    let textInputView = SelfSizingTextView()
    private let placeholderLabel = UILabel()
    private let inputParent = UIView()
    private let inputBackground = UIView()
    
    private let postButton = GradientInGradientButton(title: "Reply")
    private let buttonStack = UIStackView()
    private let replyingToLabel = UILabel()
    
    private let imagesCollectionView = PostingImageCollectionView(inset: .init(top: 0, left: 22, bottom: 0, right: 20))
    private let usersTableView = UITableView()
    private var inputContentMaxHeightConstraint: NSLayoutConstraint?
    
    private lazy var inputManager = PostingTextViewManager(textView: textInputView, usersTable: usersTableView)
    
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
    
    @discardableResult
    override func open(post: ParsedContent) -> FeedViewController {
        guard post.post.id != id else { return self }
        
        guard let index = posts.firstIndex(where: { $0.post == post.post }) else {
            return super.open(post: post)
        }
        
        if index < mainPositionInThread {
            for vc in navigationController?.viewControllers ?? [] {
                guard let thread = vc as? ThreadViewController else { continue }
                if thread.id == post.post.id {
                    thread.didMoveToMain = false
                    navigationController?.popToViewController(vc, animated: true)
                    return thread
                }
            }
        }
        
        return super.open(post: post)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: postCellID, for: indexPath)
        if let cell = cell as? ThreadCell {
            let data = posts[indexPath.row]
            let position: ThreadCell.ThreadPosition
            scope: do {
                if mainPositionInThread < indexPath.row {
                    position = .child
                    break scope
                }
                if mainPositionInThread > indexPath.row {
                    position = .parent
                    break scope
                }
                position = .main
            }
            cell.update(data,
                    position: position,
                    didLike: LikeManager.instance.hasLiked(data.post.id),
                    didRepost: PostManager.instance.hasReposted(data.post.id),
                    didZap: ZapManager.instance.hasZapped(data.post.id)
            )
            cell.delegate = self
        }
        return cell
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        table.register(ThreadCell.self, forCellReuseIdentifier: postCellID)
        
        inputParent.backgroundColor = inputManager.isEditing ? .background2 : .background
        inputBackground.backgroundColor = inputManager.isEditing ? .background : .background3
        
        guard !posts.isEmpty else { return }
        
        placeholderLabel.text = "Reply to \(posts[mainPositionInThread].user.data.displayName)"
        replyingToLabel.attributedText = replyToString(name: posts[mainPositionInThread].user.data.name)
    }
}

private extension ThreadViewController {
    @objc func postButtonPressed() {
        guard textInputView.isEditable, !posts.isEmpty else { return }
        
        if inputManager.didUploadFail {
            inputManager.restartFailedUploads()
            return
        }
        
        if inputManager.isUploadingImages {
            return
        }
        
        let text = inputManager.postingText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !text.isEmpty else {
            showErrorMessage(title: "Please Enter Text", "Text cannot be empty")
            return
        }
        
        textInputView.resignFirstResponder()
        textInputView.isEditable = false
        
        PostManager.instance.sendReplyEvent(text, mentionedPubkeys: inputManager.mentionedUsersPubkeys, post: posts[mainPositionInThread].post) { [weak self] success in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                guard let self else { return }
                
                self.textInputView.isEditable = true
                
                if success {
                    self.textInputView.text = ""
                    self.placeholderLabel.isHidden = false
                    self.didPostNewComment = true
                    self.didMoveToMain = false
                    self.feed.requestThread(postId: self.id)
                } else {
                    self.textInputView.becomeFirstResponder()
                }
            }
        }
    }
    
    @objc func inputSwippedDown() {
        textInputView.resignFirstResponder()
    }
    
    func addPublishers() {
        feed.$parsedPosts.receive(on: DispatchQueue.main).sink { [weak self] parsed in
            guard let self, let mainPost = parsed.first(where: { $0.post.id == self.id }) else { return }
            
            let postsBefore = parsed.filter { $0.post.created_at < mainPost.post.created_at }
            let postsAfter = parsed.filter { $0.post.created_at > mainPost.post.created_at }
            
            self.posts = []
            self.posts = postsBefore.sorted(by: { $0.post.created_at < $1.post.created_at }) + [mainPost] + postsAfter.sorted(by: { $0.post.created_at > $1.post.created_at })
            self.mainPositionInThread = postsBefore.count
            
            self.didLoadData = true
            
            let user = self.posts[self.mainPositionInThread].user.data
            
            self.placeholderLabel.text = "Reply to \(user.displayName)"
            
            self.replyingToLabel.attributedText = self.replyToString(name: user.name)
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest($didLoadData, $didLoadView).sink(receiveValue: { [weak self] in
            guard let self, $0 && $1 && !didMoveToMain else { return }
            
            self.didMoveToMain = true
            
            if self.didPostNewComment {
                self.didPostNewComment = false
                DispatchQueue.main.async {
                    let index = min(self.posts.count - 1, self.mainPositionInThread + 1)
                    self.table.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
                }
            } else {
                self.table.scrollToRow(at: IndexPath(row: self.mainPositionInThread, section: 0), at: .top, animated: false)
            }
        })
        .store(in: &cancellables)
        
        inputManager.$isEditing.sink { [weak self] isEditing in
            guard let self = self else { return }
            let images = self.inputManager.images
            let users = self.inputManager.users
            
            self.textHeightConstraint?.isActive = !isEditing
            self.placeholderLabel.isHidden = isEditing || !self.textInputView.text.isEmpty
            
            let isImageHidden = !isEditing ||   images.isEmpty || !users.isEmpty
            
            UIView.animate(withDuration: 0.2) {
                self.inputParent.backgroundColor = isEditing ? .background2 : .background
                self.inputBackground.backgroundColor = isEditing ? .background : .background3
                
                self.replyingToLabel.isHidden = !isEditing
                self.replyingToLabel.alpha = isEditing ? 1 : 0
                
                self.buttonStack.isHidden = !isEditing
                self.buttonStack.alpha = isEditing ? 1 : 0
                    
                self.imagesCollectionView.isHidden = isImageHidden
                self.imagesCollectionView.alpha = isImageHidden ? 0 : 1
                
                self.textInputView.layoutIfNeeded()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                if self.mainPositionInThread < self.posts.count {
                    self.table.scrollToRow(at: .init(row: self.mainPositionInThread, section: 0), at: .top, animated: true)
                }
            }
        }
        .store(in: &cancellables)
        
        inputManager.$users.receive(on: DispatchQueue.main).sink { [weak self] users in
            guard let self else { return }
            self.usersTableView.isHidden = users.isEmpty
            self.inputManager.usersHeightConstraint.constant = CGFloat(users.count) * 60
            UIView.animate(withDuration: 0.3) {
                self.view.layoutSubviews()
            } completion: { _ in
                self.usersTableView.reloadData()
            }
            self.usersTableView.reloadData()
        }
        .store(in: &cancellables)
        
        inputManager.$images.receive(on: DispatchQueue.main).sink { [weak self] images in
            self?.imagesCollectionView.imageResources = images
            self?.inputContentMaxHeightConstraint?.isActive = !images.isEmpty
            self?.postButton.titleLabel.text = self?.inputManager.isUploadingImages == true ? "Uploading..." : "Reply"
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest(inputManager.$users, inputManager.$images)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] users, images in
                guard let self else { return }
                let isHidden = images.isEmpty || !users.isEmpty
                UIView.animate(withDuration: 0.3, animations: {
                    self.imagesCollectionView.isHidden = isHidden
                    self.imagesCollectionView.alpha = isHidden ? 0 : 1
                })
            }
            .store(in: &cancellables)
    }
    
    func setup() {
        addPublishers()
        
        title = "Thread"
        
        table.keyboardDismissMode = .interactive
        
        let button = UIButton()
        button.setImage(UIImage(named: "back"), for: .normal)
        button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        button.constrainToSize(44)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        
        inputBackground.layer.cornerRadius = 6
        
        let inputStack = UIStackView(arrangedSubviews: [replyingToLabel, inputBackground, imagesCollectionView, buttonStack])
        inputStack.axis = .vertical
        
        inputParent.addSubview(inputStack)
        inputBackground.addSubview(placeholderLabel)
        
        let textParent = UIView()
        let contentStack = UIStackView(axis: .vertical, [textParent, imagesCollectionView])
        contentStack.spacing = 12
        
        imagesCollectionView.imageDelegate = inputManager
        imagesCollectionView.isHidden = true
        imagesCollectionView.backgroundColor = .clear
        
        inputBackground.addSubview(contentStack)
        textParent.addSubview(textInputView)
        
        contentStack
            .pinToSuperview(edges: [.top, .horizontal])
            .pinToSuperview(edges: .bottom, padding: 5)
        
        placeholderLabel
            .pinToSuperview(edges: .leading, padding: 21)
            .pinToSuperview(edges: .top, padding: 13)
        
        textInputView
            .pinToSuperview(edges: .horizontal, padding: 16)
            .pinToSuperview(edges: .top, padding: 5)
            .pinToSuperview(edges: .bottom)
        
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
        textInputView.returnKeyType = .send
        
        setupMainStack()
        
        let imageButton = UIButton()
        imageButton.setImage(UIImage(named: "ImageIcon"), for: .normal)
        imageButton.constrainToSize(48)
        imageButton.addAction(.init(handler: { [unowned self] _ in
            ImagePickerManager(self, mode: .gallery) { [weak self] image, isPNG in
                self?.inputManager.processSelectedImage(image, isPNG: isPNG)
            }
        }), for: .touchUpInside)
        
        let cameraButton = UIButton()
        cameraButton.setImage(UIImage(named: "CameraIcon"), for: .normal)
        cameraButton.constrainToSize(48)
        cameraButton.addAction(.init(handler: { [unowned self] _ in
            ImagePickerManager(self, mode: .camera) { [weak self] image, isPNG in
                self?.inputManager.processSelectedImage(image, isPNG: isPNG)
            }
        }), for: .touchUpInside)
        
        postButton.titleLabel.font = .appFont(withSize: 14, weight: .medium)
        postButton.constrainToSize(width: 80, height: 28)
        postButton.addTarget(self, action: #selector(postButtonPressed), for: .touchUpInside)
        
        let atButton = UIButton()
        atButton.setImage(UIImage(named: "AtIcon"), for: .normal)
        atButton.addTarget(inputManager, action: #selector(PostingTextViewManager.atButtonPressed), for: .touchUpInside)
        
        [imageButton, cameraButton, atButton, UIView(), postButton].forEach {
            buttonStack.addArrangedSubview($0)
        }
        atButton.widthAnchor.constraint(equalTo: imageButton.widthAnchor).isActive = true
        
        buttonStack.alignment = .center
        
        placeholderLabel.font = .appFont(withSize: 16, weight: .regular)
        placeholderLabel.textColor = .foreground4
        
        buttonStack.isHidden = true
        buttonStack.alpha = 0
        replyingToLabel.isHidden = true
        replyingToLabel.alpha = 0
        replyingToLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(inputSwippedDown))
        swipe.direction = .down
        inputParent.addGestureRecognizer(swipe)
        
        textInputView.heightAnchor.constraint(greaterThanOrEqualToConstant: 35).isActive = true
        textHeightConstraint = textInputView.heightAnchor.constraint(equalToConstant: 35)
        inputContentMaxHeightConstraint = contentStack.heightAnchor.constraint(equalToConstant: 600)
        
        inputContentMaxHeightConstraint?.priority = .defaultHigh
        
        view.addSubview(usersTableView)
        usersTableView.pin(to: inputParent, edges: .horizontal)
        usersTableView.isHidden = true
        
        NSLayoutConstraint.activate([
            usersTableView.bottomAnchor.constraint(equalTo: inputParent.topAnchor),
            usersTableView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor)
        ])
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
