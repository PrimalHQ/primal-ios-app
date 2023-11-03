//
//  ThreadViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 3.5.23..
//

import Combine
import UIKit

extension FeedDesign {
    var threadCellClass: AnyClass {
        switch self {
        case .standard:
            return DefaultThreadCell.self
        case .fullWidth:
            return FullWidthThreadCell.self
        }
    }
    
    var threadMainCellClass: AnyClass {
        switch self {
        case .standard:
            return DefaultMainThreadCell.self
        case .fullWidth:
            return FullWidthThreadCell.self
        }
    }
}

final class ThreadViewController: PostFeedViewController {
    let id: String
    
    var didPostNewComment = false
        
    var mainPositionInThread = 0
    
    private var didMoveToMain = false
    @Published private var didLoadView = false
    @Published private var didLoadData = false
    
    private var textHeightConstraint: NSLayoutConstraint?
    let textInputView = SelfSizingTextView()
    let textInputLoadingIndicator = LoadingSpinnerView().constrainToSize(30)
    private let placeholderLabel = UILabel()
    private let inputParent = UIView()
    private let inputBackground = UIView()
    private let bottomBarSpacer = UIView()
    
    private let postButtonText = "Reply"
    
    private lazy var postButton = SmallPostButton(title: postButtonText)
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

        mainTabBarController?.showTabBarBorder = false

        didLoadView = true
        
        view.bringSubviewToFront(loadingSpinner)
        loadingSpinner.play()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        mainTabBarController?.showTabBarBorder = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        mainTabBarController?.showTabBarBorder = true
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: postCellID + (position == .main ? "main" : ""), for: indexPath)
        if let cell = cell as? ThreadCell {
            cell.update(data,
                    position: position,
                    didLike: LikeManager.instance.hasLiked(data.post.id),
                    didRepost: PostManager.instance.hasReposted(data.post.id),
                    didZap: ZapManager.instance.hasZapped(data.post.id),
                    isMuted: MuteManager.instance.isMuted(data.user.data.pubkey)
            )
            cell.delegate = self
        }
        return cell
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        navigationItem.leftBarButtonItem = customBackButton
        
        table.register(FeedDesign.current.threadCellClass, forCellReuseIdentifier: postCellID)
        table.register(FeedDesign.current.threadMainCellClass, forCellReuseIdentifier: postCellID + "main")
        
        inputParent.backgroundColor = .background
        inputBackground.backgroundColor = .background3
        
        guard !posts.isEmpty else { return }
        
        placeholderLabel.text = "Reply to \(posts[mainPositionInThread].user.data.displayName)"
        replyingToLabel.attributedText = replyToString(name: posts[mainPositionInThread].user.data.name)
    }
    
    override func updateBars() {
        guard posts.count > 10 else { return }
        
        let shouldShowBars = true // shouldShowBars
        
        super.updateBars()
        
        inputParent.isHidden = !shouldShowBars
        bottomBarSpacer.isHidden = !shouldShowBars
        inputParent.transform = shouldShowBars ? .identity : .init(translationX: 0, y: 300)
        inputParent.alpha = shouldShowBars ? 1 : 0
    }
    
    override func animateBars() {
        guard posts.count > 10 else { return }
        let shouldShowBars = true // shouldShowBars
        
        super.animateBars()
        
        if !shouldShowBars {
            inputParent.isHidden = true
            bottomBarSpacer.isHidden = true
        }
        
        UIView.animate(withDuration: 0.3) {
            self.inputParent.transform = shouldShowBars ? .identity : .init(translationX: 0, y: 300)
            self.inputParent.alpha = shouldShowBars ? 1 : 0
        } completion: { _ in
            if shouldShowBars {
                self.inputParent.isHidden = false
                self.bottomBarSpacer.isHidden = false
            }
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        if inputManager.isEditing {
            shouldShowBars = true
        }
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
        textInputLoadingIndicator.isHidden = false
        textInputLoadingIndicator.play()
        
        PostManager.instance.sendReplyEvent(text, mentionedPubkeys: inputManager.mentionedUsersPubkeys, post: posts[mainPositionInThread].post) { [weak self] success in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                guard let self else { return }
                
                self.textInputView.isEditable = true
                self.textInputLoadingIndicator.isHidden = true
                self.textInputLoadingIndicator.stop()
                
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
            
            self.refreshControl.endRefreshing()
            if !parsed.isEmpty {
                self.loadingSpinner.stop()
                self.loadingSpinner.isHidden = true
            }
            
            self.didLoadData = true
            
            let user = self.posts[self.mainPositionInThread].user.data
            
            self.placeholderLabel.text = "Reply to \(user.displayName)"
            
            self.replyingToLabel.attributedText = self.replyToString(name: user.name)
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest($didLoadData, $didLoadView).receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] in
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
        
        inputManager.$isEditing.receive(on: DispatchQueue.main).sink { [weak self] isEditing in
            guard let self = self else { return }
            let images = self.inputManager.images
            let users = self.inputManager.users
            
            self.textHeightConstraint?.isActive = !isEditing
            self.placeholderLabel.isHidden = isEditing || !self.textInputView.text.isEmpty
            
            let isImageHidden = !isEditing ||   images.isEmpty || !users.isEmpty
            
            UIView.animate(withDuration: 0.2) {
                self.replyingToLabel.isHidden = !isEditing
                self.replyingToLabel.alpha = isEditing ? 1 : 0
                
                self.buttonStack.isHidden = !isEditing
                self.buttonStack.alpha = isEditing ? 1 : 0
                    
                self.imagesCollectionView.isHidden = isImageHidden
                self.imagesCollectionView.alpha = isImageHidden ? 0 : 1
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
            self?.postButton.titleLabel.text = self?.inputManager.isUploadingImages == true ? "Uploading..." : self?.postButtonText
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest(inputManager.$images, inputManager.$isEmpty).receive(on: DispatchQueue.main).sink { [weak self] _, isEmpty in
            guard let self else { return }
            self.postButton.isEnabled = !isEmpty && !self.inputManager.isUploadingImages
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest(inputManager.$users, inputManager.$images)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] users, images in
                guard let self else { return }
                let isHidden = images.isEmpty || !users.isEmpty
                self.imagesCollectionView.isHidden = isHidden
                self.imagesCollectionView.alpha = isHidden ? 0 : 1
            }
            .store(in: &cancellables)
    }
    
    func setup() {
        addPublishers()
        
        title = "Thread"
        
        table.keyboardDismissMode = .interactive
        table.contentInset = .init(top: 12, left: 0, bottom: 50, right: 0)
        
        stack.addArrangedSubview(inputParent)
        stack.addArrangedSubview(bottomBarSpacer)
        
        inputBackground.layer.cornerRadius = 22
        inputBackground.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        
        let inputStack = UIStackView(arrangedSubviews: [replyingToLabel, inputBackground, buttonStack])
        inputStack.axis = .vertical
        
        let inputBorder = ThemeableView().constrainToSize(height: 1).setTheme { $0.backgroundColor = .background3 }
        
        inputParent.addSubview(inputStack)
        inputParent.addSubview(inputBorder)
        inputBackground.addSubview(placeholderLabel)
        
        let textParent = UIView()
        let contentStack = UIStackView(axis: .vertical, [textParent, imagesCollectionView])
        contentStack.spacing = 12
        
        imagesCollectionView.imageDelegate = inputManager
        imagesCollectionView.isHidden = true
        imagesCollectionView.backgroundColor = .clear
        
        inputBackground.addSubview(contentStack)
        textParent.addSubview(textInputView)
        
        textParent.addSubview(textInputLoadingIndicator)
        textInputLoadingIndicator.centerToView(textInputView)
        textInputLoadingIndicator.isHidden = true
        
        contentStack
            .pinToSuperview(edges: [.top, .horizontal])
            .pinToSuperview(edges: .bottom, padding: 5)
        
        placeholderLabel
            .pinToSuperview(edges: .leading, padding: 21)
            .centerToSuperview(axis: .vertical)
        
        textInputView
            .pinToSuperview(edges: .horizontal, padding: 16)
            .pinToSuperview(edges: .top, padding: 2.5)
            .pinToSuperview(edges: .bottom, padding: -2.5)
        
        inputStack
            .pinToSuperview(edges: .horizontal, padding: 20)
            .pinToSuperview(edges: .top, padding: 16)
            .pinToSuperview(edges: .bottom)
        
        inputBorder.pinToSuperview(edges: [.top, .horizontal])
        
        let bottomC = bottomBarSpacer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -56)
        bottomC.priority = .defaultLow
        bottomC.isActive = true
        
        bottomBarSpacer.topAnchor.constraint(lessThanOrEqualTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        
        inputStack.spacing = 4
        inputStack.setCustomSpacing(8, after: replyingToLabel)
        
        textInputView.backgroundColor = .clear
        textInputView.font = .appFont(withSize: 16, weight: .regular)
        textInputView.textColor = .foreground2
        textInputView.delegate = inputManager
        textInputView.returnKeyType = .default
        
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
        
        textInputView.heightAnchor.constraint(greaterThanOrEqualToConstant: 39).isActive = true
        textHeightConstraint = textInputView.heightAnchor.constraint(equalToConstant: 39)
        inputContentMaxHeightConstraint = contentStack.heightAnchor.constraint(equalToConstant: 600)
        inputContentMaxHeightConstraint?.priority = .init(500)
        
        view.addSubview(usersTableView)
        usersTableView.pin(to: inputParent, edges: .horizontal)
        usersTableView.isHidden = true
        
        refreshControl.addAction(.init(handler: { [unowned self] _ in
            self.feed.requestThread(postId: self.id)
        }), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            usersTableView.bottomAnchor.constraint(equalTo: inputParent.topAnchor),
            usersTableView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor)
        ])
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
