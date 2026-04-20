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
    var mainObject: PrimalFeedPost?

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

    private let replyVC = ThreadReplyViewController()

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

        updateReplyToLabel()
    }

    convenience init(posts: [ParsedContent], main: ParsedContent) {
        let post = main.copy()

        post.buildContentString(style: .enlarged)

        self.init(threadId: post.post.id, startingPosts: posts.map { $0.post.id == post.post.id ? post : $0 })
        mainObject = post.post

        updateReplyToLabel()
    }

    init(threadId: String, startingPosts: [ParsedContent] = []) {
        id = threadId
        super.init(feed: FeedManager(threadId: threadId))

        feed.parsedPosts = startingPosts
        feed.requestThread(postId: threadId)

        dataSource = ThreadFeedDatasource(threadID: threadId, tableView: table, delegate: self)

        posts = startingPosts
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var bottomBarHeight: CGFloat = 150
    override var adjustedTopBarHeight: CGFloat { topBarHeight + 7 }
    override var barsMaxTransform: CGFloat { bottomBarHeight }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        mainTabBarController?.setTabBarHidden(true, animated: animated)

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

        bottomBarHeight = 72 + view.safeAreaInsets.bottom
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

        navigationItem.leftBarButtonItem = customBackButton

        updateReplyToLabel()
    }

    func updateReplyToLabel() {
        guard let post = posts[safe: mainPositionInThread] else { return }

        replyVC.replyingToName = post.user.data.displayName
    }

    override func setBarsHidden(_ hidden: Bool, animated: Bool) {
        let navTransform: CGAffineTransform = hidden ? .init(translationX: 0, y: -barsMaxTransform) : .identity
        let borderTransform: CGAffineTransform = hidden ? .init(translationX: 0, y: -barsMaxTransform) : .identity
        
        let apply = { [self] in
            navigationController?.navigationBar.transform = navTransform
            self.navigationBorder.transform = borderTransform
        }
        
        if animated {
            UIView.animate(withDuration: 0.3) { apply() }
        } else {
            apply()
        }
    }

    var wasDragged = false
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        wasDragged = true
    }

    override func showToast(_ message: String) {
        view.showToastTop(message)
    }

    func openReplyComposer() {
        guard !posts.isEmpty else { return }

        let replyController = AdvancedEmbedPostViewController(replyId: id, replyingTo: mainObject, onPost: { [weak self] in
            guard let self else { return }
            didPostNewComment = true
            feed.requestThread(postId: id)
        })

        present(replyController, animated: true)
    }
}

private extension ThreadViewController {
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
        let mainAuthor = mainPost.user.data.pubkey
        let mainChildren = posts.filter({ $0.replyingTo?.post.id == mainPost.post.id }).sorted(by: {
            let lhsIsAuthor = $0.user.data.pubkey == mainAuthor
            let rhsIsAuthor = $1.user.data.pubkey == mainAuthor
            if lhsIsAuthor != rhsIsAuthor { return lhsIsAuthor }
            if lhsIsAuthor { return $0.post.created_at < $1.post.created_at }
            return $0.post.created_at > $1.post.created_at
        })
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

            replyVC.replyingToName = user.displayName

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
    }

    func setup() {
        addPublishers()

        title = "Thread"

        table.contentInset = .init(top: 112, left: 0, bottom: 700, right: 0)
        table.contentOffset = .init(x: 0, y: -112)

        addChild(replyVC)
        view.addSubview(replyVC.view)
        replyVC.view.pinToSuperview(edges: [.horizontal, .bottom])
        replyVC.didMove(toParent: self)

        replyVC.onTap = { [weak self] in
            self?.openReplyComposer()
        }

        refreshControl.addAction(.init(handler: { [unowned self] _ in
            feed.requestThread(postId: id)
        }), for: .valueChanged)
    }
}
