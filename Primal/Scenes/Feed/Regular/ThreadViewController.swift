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
    var mainObject: PrimalFeedPost? {
        didSet {
            inputManager.replyingTo = mainObject
        }
    }
    
    var didPostNewComment = false
        
    var mainPositionInThread: Int {
        posts.firstIndex(where: { $0.post.id == id }) ?? 0
    }
    
    var mainPostIndex: IndexPath {
        (dataSource as? ThreadFeedDatasource)?.mainPostIndexPath ?? .init(row: 0, section: 0)
    }
    
    @Published private var didMoveToMain = false
    @Published private var didLoadView = false
    @Published private var didLoadData = false
    
    private var textHeightConstraint: NSLayoutConstraint?
    let textInputView = SelfSizingTextView()
    let textInputLoadingIndicator = LoadingSpinnerView().constrainToSize(30)
    private let placeholderLabel = UILabel()
    private let inputParent = UIView()
    private let inputParentBackgroundExtender = UIView()
    private let inputBackground = UIView()
    private let keyboardSizer = KeyboardSizingView()
    
    var updateInsetCancellable: AnyCancellable?
    
    var articles: [Article] = [] {
        didSet {
            var offset = table.contentOffset
            
            (dataSource as? ThreadFeedDatasource)?.articles = articles
            
            if oldValue.count == 0 && articles.count == 1 {
                guard let height = self.table.cellForRow(at: IndexPath(row: 0, section: 0))?.contentView.frame.height else { return }
                offset.y += height
                table.contentOffset = offset
            }
        }
    }
    
    private lazy var postButton = SmallPostButton(title: "Reply")
    private let buttonStack = UIStackView()
    private let replyingToLabel = UILabel()
    
    private let imagesCollectionView = PostingImageCollectionView(inset: .init(top: 0, left: 22, bottom: 0, right: 20))
    private let usersTableView = UITableView()
    private var inputContentMaxHeightConstraint: NSLayoutConstraint?
    
    private lazy var inputManager = PostingTextViewManager(textView: textInputView, usersTable: usersTableView, replyId: id, replyingTo: mainObject, defaultPostTitle: "Reply")
    
    var isLoading = true {
        didSet {
            table.reloadData()
        }
    }
    
    convenience init(post: ParsedContent) {
        let post = post.copy()
        post.buildContentString(style: .enlarged)
        
        self.init(threadId: post.post.id, startingPosts: [post])
        mainObject = post.post
        inputManager.replyingTo = mainObject
        
        updateReplyToLabel()
    }
    
    convenience init(posts: [ParsedContent], main: ParsedContent) {
        let post = main.copy()
        
        post.buildContentString(style: .enlarged)
        
        self.init(threadId: post.post.id, startingPosts: posts.map { $0.post.id == post.post.id ? post : $0 })
        mainObject = post.post
        inputManager.replyingTo = mainObject
        
        updateReplyToLabel()
    }
    
    init(threadId: String, startingPosts: [ParsedContent] = []) {
        id = threadId
        super.init(feed: FeedManager(threadId: threadId))
        
        feed.parsedPosts = startingPosts
        feed.requestThread(postId: threadId, includeParent: startingPosts.count < 2)
        
        inputManager.extractReferences = false
        dataSource = ThreadFeedDatasource(threadID: threadId, tableView: table, delegate: self)
        
        posts = startingPosts
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var bottomBarHeight: CGFloat = 150
    var keyboardCancellable: AnyCancellable?
    override var adjustedTopBarHeight: CGFloat { topBarHeight + 7 }
    override var barsMaxTransform: CGFloat { bottomBarHeight }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)

        mainTabBarController?.showTabBarBorder = false
        
        if !didLoadView, posts.count > 1 {
            // If we don't dispatch system adds animation automatically
            DispatchQueue.main.async { [self] in
                table.scrollToRow(at: mainPostIndex, at: .top, animated: false)
                DispatchQueue.main.async { [self] in
                    table.reloadData()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(24)) { [self] in
                    table.reloadData()
                }
            }
        }
        
        didLoadView = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        mainTabBarController?.showTabBarBorder = false
        
        table.reloadData()
        
        bottomBarHeight = 116 + view.safeAreaInsets.bottom
        
        // We should only update while the view is visible, otherwise table cells get fucked up unexplainably
        keyboardCancellable = keyboardSizer.updateHeightCancellable()
        
        (navigationController as? MainNavigationController)?.backGestureDelegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        mainTabBarController?.showTabBarBorder = true
        
        if let nav = navigationController {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) { [self] in
                if nav.viewControllers.contains(where: { $0 == self }) {
                    return // the controller is still in the nav stack so data will not be lost
                }
                inputManager.askToSave(nav)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        keyboardCancellable = nil
    }
    
    var articleSection: Int { 0 }
    
    @discardableResult
    override func open(post: ParsedContent) -> NoteViewController {
        guard post.post.id != id else { return self }
        
        guard let index = posts.firstIndex(where: { $0.post.id == post.post.id }) else {
            return super.open(post: post)
        }
        
        for vc in navigationController?.viewControllers ?? [] {
            guard let thread = vc as? ThreadViewController else { continue }
            if thread.id == post.post.id {
                thread.didMoveToMain = false
                navigationController?.popToViewController(vc, animated: true)
                return thread
            }
        }
        
        let mainIndex = mainPositionInThread
        if index < mainIndex {
            // is parent
            let thread = ThreadViewController(posts: Array(posts.prefix(upTo: index + 2)), main: post)
            showViewController(thread)
            return thread
        }
          
        let parents = posts.prefix(upTo: mainIndex + 1)
        let thread = ThreadViewController(posts: parents + [post], main: post)
        showViewController(thread)
        return thread
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
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
        
        let back = backButtonWithColorNoAction(.foreground)
        navigationItem.leftBarButtonItem = .init(customView: back)
        back.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            inputManager.askToSaveThenDismiss(self)
        }), for: .touchUpInside)
        
        textInputView.tintColor = .accent
        textInputView.textColor = .foreground
        
        inputParent.backgroundColor = .background
        inputParentBackgroundExtender.backgroundColor = .background
        inputBackground.backgroundColor = .background3
        
        updateReplyToLabel()
    }
    
    func updateReplyToLabel() {
        guard let post = posts[safe: mainPositionInThread] else { return }
        
        placeholderLabel.text = "Reply to \(post.user.data.displayName)"
        replyingToLabel.attributedText = replyToString(name: post.user.data.name)
    }
    
    override func setBarsToTransform(_ transform: CGFloat) {
        var transform = transform
        if (!didMoveToMain && mainPositionInThread != 0) || posts.count < 10 || inputManager.isEditing {
            transform = 0
        }
        
        super.setBarsToTransform(transform)
        
        inputParent.transform = .init(translationX: 0, y: -transform)
    }
    
    var wasDragged = false
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        wasDragged = true
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
        
        inputManager.post { [weak self] success, event in
            guard success, let event, let self else {
                self?.feed.requestThread(postId: self?.id ?? "", includeParent: false)
                return
            }
            
            SocketRequest(name: "import_events", payload: .object(["events": .array([event.toJSON()])]))
                .publisher()
                .flatMap { _ in
                    SocketRequest(name: "events", payload: [
                        "event_ids": [.string(event.id)],
                        "user_pubkey": .string(IdentityManager.instance.userHexPubkey),
                        "extended_response": true
                    ])
                    .publisher()
                }
                .map { $0.process(contentStyle: .threadChildren).first }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] post in
                    guard let self else { return }
                    
                    didPostNewComment = true
                    didMoveToMain = false

                    guard let post else {
                        feed.requestThread(postId: self.id, includeParent: false)
                        return
                    }
                    
                    if feed.parsedPosts.count > mainPositionInThread + 1 {
                        feed.parsedPosts.insert(post, at: mainPositionInThread + 1)
                    } else {
                        feed.parsedPosts.append(post)
                    }
                }
                .store(in: &cancellables)

        }
    }
    
    @objc func inputSwippedDown() {
        textInputView.resignFirstResponder()
    }
    
    func buildHierarchy(mainPost: ParsedContent, posts: [ParsedContent]) -> [ParsedContent] {
        let simpleSort = {
            let postsBefore = posts.filter { $0.post.created_at < mainPost.post.created_at }
            let postsAfter = posts.filter { $0.post.created_at > mainPost.post.created_at }
            return postsBefore.sorted(by: { $0.post.created_at < $1.post.created_at }) + [mainPost] + postsAfter.sorted(by: { $0.post.created_at > $1.post.created_at })
        }
        
        guard var currentPost = posts.first(where: { $0.replyingTo == nil }) else { // Find root
            return simpleSort()
        }
        
        var result: [ParsedContent] = []
        while currentPost.post.id != mainPost.post.id && result.count < posts.count { // check result size to avoid an infinite loop
            result.append(currentPost)
            guard let next = posts.first(where: { $0.replyingTo?.post.id == currentPost.post.id }) else { // Find child
                return simpleSort() // unable to find child so defaulting to the old sort
            }
            currentPost = next
        }
        
        result.append(mainPost) // Main post
        let mainChildren = posts.filter({ $0.replyingTo?.post.id == mainPost.post.id }).sorted(by: { $0.post.created_at > $1.post.created_at })
        result.append(contentsOf: mainChildren)
        
        if result.count != posts.count { // In case some post is missing or added twice
            return simpleSort()
        }
        
        return result
    }
    
    func addPublishers() {
        feed.$parsedPosts.receive(on: DispatchQueue.main).sink { [weak self] parsed in
            let parsed = parsed.uniqueByFilter({ $0.post.id })
            guard let self, let mainPost = parsed.first(where: { $0.post.id == self.id }) else { return }
            
            mainPost.buildContentString(style: .enlarged)
            self.mainObject = mainPost.post
            
            refreshControl.endRefreshing()
            
            self.posts = buildHierarchy(mainPost: mainPost, posts: parsed)
            
            let user = posts[self.mainPositionInThread].user.data
            
            placeholderLabel.text = "Reply to \(user.displayName)"
            
            replyingToLabel.attributedText = self.replyToString(name: user.name)
            
            isLoading = false
            didLoadData = true
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
                didLoadData = true
            }
            .store(in: &cancellables)
        
        weak var threadDS = dataSource as? ThreadFeedDatasource
        
//        threadDS?.$cellHeightArray.sink(receiveValue: { height in
//            print("Height: \(height.reduce(0, +))")
//        })
//        .store(in: &cancellables)
        
        updateInsetCancellable = threadDS?.$cellHeightArray
            .map { (height: [CGFloat]) in
                let index = threadDS?.mainPostIndexPath.row ?? 0
                return height
                    .enumerated()
                    .filter({ $0.0 >= index })  // Ignore cells above the main
                    .map { $0.1 }
                    .reduce(0, +)               // Sum of all heights
            }
            .removeDuplicates()
            .sink { [weak self] contentSize in
//                print("Height reduced: \(contentSize)")
                guard let self, posts.count - mainPositionInThread < 6 else {
                    self?.table.contentInset = .init(top: self?.adjustedTopBarHeight ?? 107, left: 0, bottom: 150, right: 0)
                    return
                }
                let botInset = barsMaxTransform + max(0, table.frame.height - barsMaxTransform - adjustedTopBarHeight - contentSize)
                self.table.contentInset = .init(top: adjustedTopBarHeight, left: 0, bottom: botInset, right: 0)
                
                if !wasDragged, posts.count > 1, table.window != nil {
                    table.scrollToRow(at: mainPostIndex, at: .top, animated: false)
                }
            }

        Publishers.CombineLatest($didLoadData, $didLoadView)
            .filter { $0 && $1 }
            .sink(receiveValue: { [weak self] _ in
                guard let self, !didMoveToMain, mainPositionInThread > 0 else { return }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                    self.didMoveToMain = true
                    self.updateInsetCancellable = nil
                }
                
                if self.didPostNewComment {
                    self.didPostNewComment = false
                    DispatchQueue.main.async {
                        self.table.scrollToRow(at: self.mainPostIndex, at: .top, animated: true)
                    }
                } else {
                    self.table.scrollToRow(at: self.mainPostIndex, at: .top, animated: false)
                }
            })
            .store(in: &cancellables)
        
        Publishers.CombineLatest(inputManager.$isEditing, inputManager.didChangeEvent.prepend(textInputView))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEditing, textView in
                self?.placeholderLabel.isHidden = isEditing || !textView.text.isEmpty
            }
            .store(in: &cancellables)
        
        inputManager.$users.receive(on: DispatchQueue.main).sink { [weak self] users in
            guard let self else { return }
            self.usersTableView.isHidden = users.isEmpty
            self.inputManager.usersHeightConstraint.constant = CGFloat(users.count) * 60
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            } completion: { _ in
                self.usersTableView.reloadData()
            }
            self.usersTableView.reloadData()
        }
        .store(in: &cancellables)
        
        inputManager.$media.assign(to: \.imageResources, onWeak: imagesCollectionView).store(in: &cancellables)
        inputManager.$postButtonEnabledState.assign(to: \.isEnabled, on: postButton).store(in: &cancellables)
        inputManager.$postButtonTitle.sink { [postButton] title in
            postButton.setTitle(title, for: .normal)
        }
        .store(in: &cancellables)
        
        inputManager.$isPosting
            .sink { [weak self] isPosting in
                guard let self else { return }
                if isPosting {
                    textInputLoadingIndicator.isHidden = false
                    textInputLoadingIndicator.play()
                } else {
                    textInputLoadingIndicator.pause()
                    textInputLoadingIndicator.isHidden = true
                }
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest3(
            inputManager.$users.map({ $0.isEmpty }).removeDuplicates(),
            inputManager.$media.map({ $0.isEmpty }).removeDuplicates(),
            inputManager.$isEditing.removeDuplicates()
        )
        .prepend([(true, true, false)])
        .withPrevious()
        .receive(on: DispatchQueue.main)
        .sink { [weak self] old, new in
            guard let self else { return }
            let (isUsersEmpty, imagesIsEmpty, isEditing) = new
            let (_, _, oldIsEditing) = old
            
            let isImageHidden = !isEditing || imagesIsEmpty || !isUsersEmpty
            
            inputContentMaxHeightConstraint?.isActive = !imagesIsEmpty
            textHeightConstraint?.isActive = !isEditing
            
            imagesCollectionView.isHidden = isImageHidden
            
            UIView.animate(withDuration: 0.2) {
                self.replyingToLabel.isHidden = !isEditing
                self.replyingToLabel.alpha = isEditing ? 1 : 0
                
                self.buttonStack.isHidden = !isEditing
                self.buttonStack.alpha = isEditing ? 1 : 0
                
                self.imagesCollectionView.alpha = isImageHidden ? 0.01 : 1
            }
            
            if isEditing && !oldIsEditing {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                    if self.mainPositionInThread < self.posts.count {
                        self.table.scrollToRow(at: self.mainPostIndex, at: .top, animated: true)
                    }
                }
            }
        }
        .store(in: &cancellables)
    }
    
    func setup() {
        addPublishers()
        
        title = "Thread"
        
        table.keyboardDismissMode = .onDrag
        table.contentInset = .init(top: 112, left: 0, bottom: 700, right: 0)
        table.contentOffset = .init(x: 0, y: -112)
        
        view.insertSubview(keyboardSizer, at: 0)
        keyboardSizer.pinToSuperview(edges: [.bottom, .horizontal])
        
        view.addSubview(inputParent)
        inputParent.pinToSuperview(edges: .horizontal)
        
        inputParent.addSubview(inputParentBackgroundExtender)
        inputParentBackgroundExtender.pinToSuperview(edges: .horizontal).constrainToSize(height: 200)
        inputParentBackgroundExtender.topAnchor.constraint(equalTo: inputParent.bottomAnchor).isActive = true
        
        inputParent.bottomAnchor.constraint(lessThanOrEqualTo: keyboardSizer.topAnchor).isActive = true
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
        
        contentStack
            .pinToSuperview(edges: [.top, .horizontal])
            .pinToSuperview(edges: .bottom, padding: 5)
        
        placeholderLabel
            .pinToSuperview(edges: .horizontal, padding: 21)
            .pinToSuperview(edges: .top, padding: 12)
        
        textInputView
            .pinToSuperview(edges: .horizontal, padding: 16)
            .pinToSuperview(edges: .top, padding: 2.5)
            .pinToSuperview(edges: .bottom, padding: -5.5)
        
        inputStack
            .pinToSuperview(edges: .horizontal, padding: 20)
            .pinToSuperview(edges: .top, padding: 16)
            .pinToSuperview(edges: .bottom)
        
        inputBorder.pinToSuperview(edges: [.top, .horizontal])
        
        inputStack.spacing = 4
        inputStack.setCustomSpacing(8, after: replyingToLabel)
        
        textInputView.backgroundColor = .clear
        textInputView.returnKeyType = .default
        
        let imageButton = ThemeableButton().constrainToSize(48).setTheme { $0.tintColor = .foreground }
        imageButton.setImage(UIImage(named: "ImageIcon"), for: .normal)
        imageButton.addAction(.init(handler: { [unowned self] _ in
            ImagePickerManager(self, mode: .gallery, allowVideo: true) { [weak self] result in
                self?.inputManager.processSelectedAsset(result)
            }
        }), for: .touchUpInside)
        
        let cameraButton = ThemeableButton().constrainToSize(48).setTheme { $0.tintColor = .foreground }
        cameraButton.setImage(UIImage(named: "CameraIcon"), for: .normal)
        cameraButton.addAction(.init(handler: { [unowned self] _ in
            ImagePickerManager(self, mode: .camera) { [weak self] result in
                self?.inputManager.processSelectedAsset(result)
            }
        }), for: .touchUpInside)
        
        postButton.titleLabel?.font = .appFont(withSize: 14, weight: .medium)
        postButton.constrainToSize(width: 80, height: 28)
        postButton.addTarget(self, action: #selector(postButtonPressed), for: .touchUpInside)
        
        let atButton = ThemeableButton().constrainToSize(48).setTheme { $0.tintColor = .foreground }
        atButton.setImage(UIImage(named: "AtIcon"), for: .normal)
        atButton.addTarget(inputManager, action: #selector(PostingTextViewManager.atButtonPressed), for: .touchUpInside)
        
        [imageButton, cameraButton, atButton, UIView(), postButton].forEach {
            buttonStack.addArrangedSubview($0)
        }
        
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
        textHeightConstraint?.priority = .defaultHigh
        inputContentMaxHeightConstraint = contentStack.heightAnchor.constraint(equalToConstant: 600)
        inputContentMaxHeightConstraint?.priority = .init(500)
        
        view.addSubview(usersTableView)
        usersTableView.pin(to: inputParent, edges: .horizontal)
        usersTableView.isHidden = true
        
        refreshControl.addAction(.init(handler: { [unowned self] _ in
            feed.requestThread(postId: id, includeParent: true)
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
            .foregroundColor: UIColor.accent2
        ]))
        return value
    }
}

// Back gesture
extension ThreadViewController: UIGestureRecognizerDelegate {
    var askToSaveIsNecessary: Bool {
        let draft = inputManager.currentDraft
        
        if let oldDraft = inputManager.oldDraft {
            if oldDraft.text == draft.text && oldDraft.uploadedAssets == draft.uploadedAssets {
                return false
            }
        } else if textInputView.text.isEmpty == true {
            return false
        }
        
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if navigationController?.topViewController != self { return true }
        
        if askToSaveIsNecessary {
            inputManager.askToSave(self) { [weak self] dialog in
                if !dialog {
                    self?.backButtonPressed()
                }
            }
            return false
        }
        
        return true
    }
}
