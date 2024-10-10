//
//  ThreadViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 3.5.23..
//

import Combine
import UIKit
import SafariServices

final class ThreadViewController: PostFeedViewController, ArticleCellController {
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
    
    var articles: [Article] = [] {
        didSet {
            var offset = table.contentOffset
            table.reloadData()
            if oldValue.count == 0 && articles.count == 1 {
                guard let height = self.table.cellForRow(at: IndexPath(row: 0, section: 0))?.contentView.frame.height else { return }
                offset.y += height
                table.contentOffset = offset
            }
        }
    }
    
    private let postButtonText = "Reply"
    
    private lazy var postButton = SmallPostButton(title: postButtonText)
    private let buttonStack = UIStackView()
    private let replyingToLabel = UILabel()
    
    private let imagesCollectionView = PostingImageCollectionView(inset: .init(top: 0, left: 22, bottom: 0, right: 20))
    private let usersTableView = UITableView()
    private var inputContentMaxHeightConstraint: NSLayoutConstraint?
    
    private lazy var inputManager = PostingTextViewManager(textView: textInputView, usersTable: usersTableView)
    
    var mainPostZaps: [ParsedZap]? { didSet { table.reloadData() } }
    
    @Published var mainPostRepliesHeightArray: [CGFloat] = [0, 150, 0, 0, 0]
    
    var isLoading = true {
        didSet {
            mainPostRepliesHeightArray[1] = isLoading ? 150 : 0
            table.reloadData()
        }
    }
    
    convenience init(post: ParsedContent) {
        self.init(threadId: post.post.id)
        self.mainPostZaps = post.zaps
        let copy = post.copy()
        copy.reposted = nil
        posts = [copy]
        
        updateReplyToLabel()
    }
    
    init(threadId: String) {
        id = threadId
        super.init(feed: FeedManager(threadId: threadId))
        setup()
        
        refreshZaps()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var bottomBarHeight: CGFloat = 150
    override var barsMaxTransform: CGFloat { bottomBarHeight }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)

        mainTabBarController?.showTabBarBorder = false
        
        didLoadView = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        mainTabBarController?.showTabBarBorder = false
        
        bottomBarHeight = 116 + view.safeAreaInsets.bottom
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        mainTabBarController?.showTabBarBorder = true
    }
    
    var articleSection: Int { 0 }
    override var postSection: Int { 1 }
    
    @discardableResult
    override func open(post: ParsedContent) -> NoteViewController {
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
    
    func numberOfSections(in tableView: UITableView) -> Int { 2 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == postSection {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
        return min(1, articles.count)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 { // Parent Article
            let cell = tableView.dequeueReusableCell(withIdentifier: "article", for: indexPath)
            if let articleCell = cell as? ArticleCell {
                articleCell.setUp(articles[indexPath.row])
                articleCell.bottomSpacer.isHidden = false
                articleCell.contentView.backgroundColor = .background2
            }
            return cell
        }
        
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
        if position == .main, let cell = cell as? DefaultMainThreadCell {
            cell.update(data, zaps: mainPostZaps)
            cell.delegate = self
        } else if let cell = cell as? ThreadCell {
            cell.update(data, position: position)
            cell.delegate = self
        }
        DispatchQueue.main.async { [self] in // Now the cell has been laid out
            let heightIndex = indexPath.row - mainPositionInThread
            if heightIndex >= 0 && heightIndex < mainPostRepliesHeightArray.count {
                mainPostRepliesHeightArray[heightIndex] = cell.contentView.frame.height
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == postSection {
            super.tableView(tableView, didSelectRowAt: indexPath)
            return
        }
        if indexPath.section == 0, let article = articles[safe: indexPath.row] {
            if let oldVC = navigationController?.viewControllers.first(where: { ($0 as? ArticleViewController)?.content.event.id == article.event.id }) {
                navigationController?.popToViewController(oldVC, animated: true)
                return
            }
            show(ArticleViewController(content: article), sender: nil)
        }
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        navigationItem.leftBarButtonItem = customBackButton
        
        table.register(PostThreadCell.self, forCellReuseIdentifier: postCellID)
        table.register(DefaultMainThreadCell.self, forCellReuseIdentifier: postCellID + "main")
        table.register(PostLoadingCell.self, forCellReuseIdentifier: "loading")
        
        textInputView.tintColor = .accent
        textInputView.textColor = .foreground
        
        inputParent.backgroundColor = .background
        inputBackground.backgroundColor = .background3
        
        updateReplyToLabel()
    }
    
    func updateReplyToLabel() {
        guard let post = posts[safe: mainPositionInThread] else { return }
        
        placeholderLabel.text = "Reply to \(post.user.data.displayName)"
        replyingToLabel.attributedText = replyToString(name: post.user.data.name)
    }
    
    override func setBarsToTransform(_ transform: CGFloat) {
        if !didMoveToMain || posts.count < 10 { return }
        
        super.setBarsToTransform(transform)
        
        inputParent.transform = .init(translationX: 0, y: -transform)
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
        
        PostingManager.instance.sendReplyEvent(text, mentionedPubkeys: inputManager.mentionedUsersPubkeys, post: posts[mainPositionInThread].post) { [weak self] success in
            
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
    
    func refreshZaps() {
        NoteZapsRequest(noteId: id).publisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] zaps in
                self?.mainPostZaps = zaps
            })
            .store(in: &cancellables)
    }
    
    func addPublishers() {
        feed.$parsedPosts.receive(on: DispatchQueue.main).sink { [weak self] parsed in
            guard let self, let mainPost = parsed.first(where: { $0.post.id == self.id }) else { return }
            
            let postsBefore = parsed.filter { $0.post.created_at < mainPost.post.created_at }
            let postsAfter = parsed.filter { $0.post.created_at > mainPost.post.created_at }
            
            if !parsed.isEmpty {
                isLoading = false
            }
            
            self.posts = []
            self.posts = postsBefore.sorted(by: { $0.post.created_at < $1.post.created_at }) + [mainPost] + postsAfter.sorted(by: { $0.post.created_at > $1.post.created_at })
            self.mainPositionInThread = postsBefore.count
            
            refreshControl.endRefreshing()
            
            didLoadData = true
            
            let user = posts[self.mainPositionInThread].user.data
            
            placeholderLabel.text = "Reply to \(user.displayName)"
            
            replyingToLabel.attributedText = self.replyToString(name: user.name)
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest($posts, feed.$parsedLongForm)
            .debounce(for: 0.05, scheduler: RunLoop.main)
            .sink { [weak self] posts, articles in
                guard
                    let self,
                    let originalReply = posts.first?.replyingTo, originalReply.post.kind == 30023,
                    let article = articles.first(where: { $0.event.id == originalReply.post.id })
                else { return }
                
                self.articles = [article]
            }
            .store(in: &cancellables)
        
        WalletManager.instance.zapEvent.debounce(for: 0.3, scheduler: RunLoop.main).sink { [weak self] zap in
            guard let self, zap.postId == id else { return }
            var zaps = mainPostZaps ?? []
            let index = zaps.firstIndex(where: { $0.amountSats <= zap.amountSats }) ?? zaps.count
            zaps.insert(zap, at: index)
            mainPostZaps = zaps
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest(
            Publishers.keyboardState,
            $mainPostRepliesHeightArray.map({ $0.reduce(0, +) }).filter({ $0 > 0 }) // Sum of all heights
        )
        .sink { [weak self] (keyboardState, contentSize) in
            let topBarHeight: CGFloat = (self?.topBarHeight ?? 100) + 12
            
            guard let self, posts.count - mainPositionInThread < 6 else {
                switch keyboardState {
                case .hidden:
                    self?.table.contentInset = .init(top: topBarHeight, left: 0, bottom: 150, right: 0)
                case .shown(let height):
                    self?.table.contentInset = .init(top: topBarHeight, left: 0, bottom: height, right: 0)
                }
                return
            }
            switch keyboardState {
            case .hidden:
                let botInset = barsMaxTransform + max(0, table.frame.height - barsMaxTransform - topBarHeight - contentSize)
                self.table.contentInset = .init(top: topBarHeight, left: 0, bottom: botInset, right: 0)
            case .shown(let height):
                self.table.contentInset = .init(top: topBarHeight, left: 0, bottom: height + 300, right: 0)
            }
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest($didLoadData, $didLoadView).sink(receiveValue: { [weak self] in
            guard let self, $0 && $1 && !didMoveToMain else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                self.didMoveToMain = true
            }
            
            if self.didPostNewComment {
                self.didPostNewComment = false
                DispatchQueue.main.async {
                    let index = min(self.posts.count - 1, self.mainPositionInThread + 1)
                    self.table.scrollToRow(at: IndexPath(row: index, section: self.postSection), at: .top, animated: true)
                }
            } else {
                self.table.scrollToRow(at: IndexPath(row: self.mainPositionInThread, section: postSection), at: .top, animated: false)
                DispatchQueue.main.async {
                    self.table.scrollToRow(at: IndexPath(row: self.mainPositionInThread, section: self.postSection), at: .top, animated: false)
                    DispatchQueue.main.async {
                        self.table.scrollToRow(at: IndexPath(row: self.mainPositionInThread, section: self.postSection), at: .top, animated: false)
                    }
                }
            }
        })
        .store(in: &cancellables)
        
        inputManager.$isEditing.receive(on: DispatchQueue.main).sink { [weak self] isEditing in
            guard let self = self else { return }
            let images = self.inputManager.media
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
                    self.table.scrollToRow(at: .init(row: self.mainPositionInThread, section: self.postSection), at: .top, animated: true)
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
        
        inputManager.$media.receive(on: DispatchQueue.main).sink { [weak self] images in
            self?.imagesCollectionView.imageResources = images
            self?.inputContentMaxHeightConstraint?.isActive = !images.isEmpty
            self?.postButton.setTitle(self?.inputManager.isUploadingImages == true ? "Uploading..." : self?.postButtonText, for: .normal)
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest(inputManager.$media, inputManager.$isEmpty).receive(on: DispatchQueue.main).sink { [weak self] images, isEmpty in
            guard let self else { return }
            let isUploading: Bool = {
                for image in images {
                    if case .uploading = image.state {
                        return true
                    }
                }
                return false
            }()
            let hasImages = !images.isEmpty
            self.postButton.isEnabled = !isUploading && (!isEmpty || hasImages)
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest(inputManager.$users, inputManager.$media)
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
        table.contentInset = .init(top: 112, left: 0, bottom: 700, right: 0)
        table.contentOffset = .init(x: 0, y: -112)
        table.register(ArticleCell.self, forCellReuseIdentifier: "article")
        
        view.addSubview(inputParent)
        inputParent.pinToSuperview(edges: .horizontal)
        inputParent.bottomAnchor.constraint(lessThanOrEqualTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        let botC = inputParent.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -48)
        botC.priority = .defaultHigh
        botC.isActive = true
        inputParent.frame = .init(origin: .init(x: 0, y: 900), size: .init(width: 350, height: 100))
        
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
            .pinToSuperview(edges: .horizontal, padding: 21)
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
        
        inputStack.spacing = 4
        inputStack.setCustomSpacing(8, after: replyingToLabel)
        
        textInputView.backgroundColor = .clear
        textInputView.returnKeyType = .default
        
        let imageButton = UIButton()
        imageButton.setImage(UIImage(named: "ImageIcon"), for: .normal)
        imageButton.constrainToSize(48)
        imageButton.addAction(.init(handler: { [unowned self] _ in
            ImagePickerManager(self, mode: .gallery, allowVideo: true) { [weak self] result in
                self?.inputManager.processSelectedAsset(result)
            }
        }), for: .touchUpInside)
        
        let cameraButton = UIButton()
        cameraButton.setImage(UIImage(named: "CameraIcon"), for: .normal)
        cameraButton.constrainToSize(48)
        cameraButton.addAction(.init(handler: { [unowned self] _ in
            ImagePickerManager(self, mode: .camera) { [weak self] result in
                self?.inputManager.processSelectedAsset(result)
            }
        }), for: .touchUpInside)
        
        postButton.titleLabel?.font = .appFont(withSize: 14, weight: .medium)
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
            feed.requestThread(postId: id)
            refreshZaps()
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

extension ThreadViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        textInputView.isFirstResponder
    }
}
