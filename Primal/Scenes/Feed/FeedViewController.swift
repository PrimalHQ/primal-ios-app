//
//  FeedViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 2.5.23..
//

import AVKit
import Combine
import UIKit
import SwiftUI
import SafariServices
import Lottie
import Kingfisher
import StoreKit

class FeedViewController: UIViewController, UITableViewDataSource, Themeable, WalletSearchController {
    static let bigZapAnimView = LottieAnimationView(animation: AnimationType.zapMedium.animation).constrainToSize(width: 375, height: 50)
    
    var refreshControl = UIRefreshControl()
    let table = UITableView()
    let navigationBorder = UIView().constrainToSize(height: 1)
    lazy var stack = UIStackView(arrangedSubviews: [table])
    
    let hapticGenerator = UIImpactFeedbackGenerator(style: .light)
    let heavy = UIImpactFeedbackGenerator(style: .heavy)
    
    let loadingSpinner = LoadingSpinnerView()
    
    var postCellID = "cell" // Needed for updating the theme
    
    var postSection: Int { 0 }
    func postForIndexPath(_ indexPath: IndexPath) -> ParsedContent? {
        if indexPath.section != postSection { return nil }
        return posts[safe: indexPath.row]
    }
    @Published var posts: [ParsedContent] = [] {
        didSet {
            guard oldValue.count != 0, oldValue.count < posts.count, view.window != nil else {
                table.reloadData()
                return
            }
            
            let isAddingAtEnd = oldValue.first?.post.id == posts.first?.post.id
            
            let indexes: [IndexPath] = {
                if isAddingAtEnd {
                    return (oldValue.count..<posts.count).map { IndexPath(row: $0, section: postSection) }
                }
                return (0..<posts.count-oldValue.count).map { IndexPath(row: $0, section: postSection) }
            }()
            
            table.insertRows(at: indexes, with: .none)
        }
    }
    
    var cancellables: Set<AnyCancellable> = []
    var textSearch: String?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    deinit {
        if let barForegroundObserver {
            NotificationCenter.default.removeObserver(barForegroundObserver)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        table.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        hapticGenerator.prepare()
        heavy.prepare()
        
        guard
            ContentDisplaySettings.autoPlayVideos,
            let playingRN = VideoPlaybackManager.instance.currentlyPlaying?.url,
            let index = posts.firstIndex(where: { post in  post.mediaResources.contains(where: { $0.url == playingRN }) }),
            table.indexPathsForVisibleRows?.contains(where: { $0.section == postSection && $0.row == index }) == true
        else { return }
        
        DispatchQueue.main.async {
            VideoPlaybackManager.instance.currentlyPlaying?.play()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        VideoPlaybackManager.instance.currentlyPlaying?.delayedPause()
        
        if animated {
            if prevTransform != 0 {
                animateBarsToVisible()
            }
        } else {
            if prevTransform != 0 {
                setBarsToTransform(0)
            }
        }
    }
    
    var topBarHeight: CGFloat = 100
    var barsMaxTransform: CGFloat { topBarHeight }
    var prevPosition: CGFloat = 0
    var prevTransform: CGFloat = 0
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let newPosition = scrollView.contentOffset.y
        let delta = newPosition - prevPosition
        prevPosition = newPosition
        
        if !scrollView.isTracking { return }
        
        let theoreticalNewTransform = (prevTransform - delta).clamped(to: -barsMaxTransform...0)
        let newTransform = newPosition <= -topBarHeight ? 0 : theoreticalNewTransform
        
        setBarsToTransform(newTransform)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.y < -0.1 {
            animateBarsToVisible()
        } else if velocity.y > 0.1 {
            animateBarsToInvisible()
        } else {
            setBarsDependingOnPosition()
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        setBarsDependingOnPosition()
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        animateBarsToVisible()
        return true
    }
    
    func setBarsToTransform(_ transform: CGFloat) {
        prevTransform = transform
        navigationController?.navigationBar.transform = .init(translationX: 0, y: transform)
        navigationBorder.transform = .init(translationX: 0, y: transform)
        mainTabBarController?.vStack.transform = .init(translationX: 0, y: -transform)
    }
    
    func animateBarsToTransform(_ transform: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.setBarsToTransform(transform)
        }
    }
    
    func animateBarsToVisible() {
        animateBarsToTransform(0)
    }
    
    func animateBarsToInvisible() {
        animateBarsToTransform(-barsMaxTransform)
    }
    
    func setBarsDependingOnPosition() {
        if prevTransform < -(barsMaxTransform / 2) && table.contentOffset.y > 0 {
            animateBarsToInvisible()
        } else {
            animateBarsToVisible()
        }
    }
    
    
    @discardableResult
    func open(post: ParsedContent) -> FeedViewController {
        let threadVC = ThreadViewController(post: post)
        show(threadVC, sender: nil)
        return threadVC
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: postCellID, for: indexPath)
        if let cell = cell as? PostCell {
            let data = posts[indexPath.row]
            cell.update(data)
            cell.delegate = self
        }
        
        if let postToPreload = posts[safe: indexPath.row + 10] {
            if let url = postToPreload.mediaResources.first?.url(for: .large), url.isImageURL {
                KingfisherManager.shared.retrieveImage(with: url, completionHandler: nil)
            } else if let url = postToPreload.linkPreview?.imagesData.first?.url(for: .large), url.isImageURL {
                KingfisherManager.shared.retrieveImage(with: url, completionHandler: nil)
            }
            
            if let url = postToPreload.user.profileImage.url(for: .small) {
                KingfisherManager.shared.retrieveImage(with: url, completionHandler: nil)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard ContentDisplaySettings.autoPlayVideos, let postCell = cell as? PostCell else { return }
        
        DispatchQueue.main.async {
            guard let videoCell = postCell.mainImages.currentVideoCell() ?? postCell.postPreview.mainImages.currentVideoCell() else { return }
            videoCell.player?.play()
        }
    }
    
    func updateTheme() {        
        updateCellID()
        table.register(FeedDesign.current.feedCellClass, forCellReuseIdentifier: postCellID)
        table.reloadData()
        
        view.backgroundColor = .background2
        table.backgroundColor = .background2
        
        navigationBorder.backgroundColor = .background3
    }
    
    private var barForegroundObserver: NSObjectProtocol?
    
    func handleURLTap(_ url: URL, from content: ParsedContent? = nil, cachedUsers: [PrimalUser] = []) {
        let urlString = url.absoluteString
        
        guard let infoSub = urlString.split(separator: "//").last else { return }
        let info = String(infoSub)
        
        if urlString.hasPrefix("hashtag"), info.isHashtag {
            let feed = RegularFeedViewController(feed: FeedManager(search: info))
            show(feed, sender: nil)
            return
        }
        
        if urlString.hasPrefix("mention") {
            let user = (content?.mentionedUsers ?? cachedUsers).first(where: { $0.pubkey == info }) ?? .init(pubkey: info)
            
            let profile = ProfileViewController(profile: .init(data: user))
            show(profile, sender: nil)
            return
        }
        
        if urlString.hasPrefix("note") {
            guard let ref = content?.notes.first(where: { $0.text == info })?.reference else { return }
            
            let thread = ThreadViewController(threadId: ref)
            show(thread, sender: nil)
            return
        }
        
        if urlString.hasPrefix("highlight") {
            guard 
                let highlight = content?.highlightEvents.first(where: { $0.post.id == info }),
                let articleId = highlight.post.tags.first(where: { $0.first == "a" })?[safe: 1]
            else { return }
            
            let infoArray = articleId.split(separator: ":")
            
            guard
                let kind = Int(infoArray.first ?? ""),
                let pubkey = infoArray[safe: 1],
                let id = infoArray[safe: 2]
            else { return }
            
            if let article = content?.article, article.event.kind == kind, article.event.pubkey == pubkey, article.identifier == id {
                let articleVC = ArticleViewController(content: article)
                show(articleVC, sender: nil)
            } else {
                show(LoadArticleController(kind: kind, identifier: String(id), pubkey: String(pubkey)), sender: nil)
            }
            return
        }
        
        var url = url
        if urlString.isValidURL {
            if urlString.lowercased().hasPrefix("http://") {
                url = .init(string: "https://" + urlString.dropFirst(7)) ?? url
            } else if !url.absoluteString.lowercased().hasPrefix("https://") {
                url = .init(string: "https://" + url.absoluteString) ?? url
            }
            
            let safari = SFSafariViewController(url: url)
            present(safari, animated: true)
            return
        }
    }
    
    func postCellDidTap(_ cell: PostCell, _ event: PostCellEvent) {
        guard let indexPath = table.indexPath(for: cell), let post = postForIndexPath(indexPath) else { return }
        
        performEvent(event, withPost: post, inCell: cell)
    }
    
    func performEvent(_ event: PostCellEvent, withPost post: ParsedContent, inCell cell: PostCell?) {
        switch event {
        case .url(let URL):
            guard let url = URL ?? post.linkPreview?.url else { return }
            
            handleURLTap(url, from: post)
        case .images(let resource):
            guard let cell else { return }
            postCellDidTapImages(cell, resource: resource)
        case .embeddedImages(let resource):
            guard let cell else { return }
            postCellDidTapEmbeddedImages(cell, resource: resource)
        case .profile:
            show(ProfileViewController(profile: post.user), sender: nil)
        case .post:
            open(post: post)
        case .like:
            PostingManager.instance.sendLikeEvent(post: post.post)
            
            hapticGenerator.impactOccurred()
            
            cell?.likeButton.animateTo(post.post.likes + 1, filled: true)
        case .zap:
            guard let cell else { return }
            zapFromCell(cell, showPopup: false)
        case .longTapZap:
            guard let cell else { return }
            zapFromCell(cell, showPopup: true)
        case .repost:
            guard let cell else { return }
            postCellDidTapRepost(cell)
        case .reply:
            if post.post.kind == NostrKind.longForm.rawValue {
                return
            }
            
            guard let thread = open(post: post) as? ThreadViewController else { return }
        
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                thread.textInputView.becomeFirstResponder()
            }
        case .embeddedPost:
            open(post: post.embededPost ?? post)
        case .repostedProfile:
            guard let profile = post.reposted?.user else { return }
            show(ProfileViewController(profile: profile), sender: nil)
        case .article:
            guard let article = post.article else { return }
            show(ArticleViewController(content: article), sender: nil)
        case .payInvoice:
            guard let invoice = post.invoice else { return }
            search(invoice.string)
            textSearch = nil
        case .zapDetails:
            show(NoteReactionsParentController(.zaps, noteId: post.post.id), sender: nil)
        case .likeDetails:
            show(NoteReactionsParentController(.likes, noteId: post.post.id), sender: nil)
        case .repostDetails:
            show(NoteReactionsParentController(.reposts, noteId: post.post.id), sender: nil)
        case .share:
            let activityViewController = UIActivityViewController(activityItems: [post.webURL()], applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
        case .copy(let property):
            UIPasteboard.general.string = post.propertyText(property)
            RootViewController.instance.view.showToast("Copied!")
        case .broadcast:
            break // TODO: Something?
        case .report:
            break // TODO: Something?
        case .mute:
            MuteManager.instance.toggleMute(post.user.data.pubkey)
        case .bookmark:
            BookmarkManager.instance.bookmark(post)
            cell?.updateMenu(post)
        case .unbookmark:
            BookmarkManager.instance.unbookmark(post)
            cell?.updateMenu(post)
        }
    }
}

private extension FeedViewController {
    func updateCellID() {
        postCellID += "1"
    }
    
    func setup() {
        stack.axis = .vertical
        view.insertSubview(stack, at: 0)
        stack.pinToSuperview()
        
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.contentInsetAdjustmentBehavior = .never
        table.contentInset = .init(top: 100, left: 0, bottom: 90, right: 0)

        DispatchQueue.main.async {
            self.topBarHeight = RootViewController.instance.view.safeAreaInsets.top + 50 // 50 is nav bar height without safe area
            self.table.contentInset = .init(top: self.barsMaxTransform, left: 0, bottom: 90, right: 0)
            self.table.contentOffset = .init(x: 0, y: -self.barsMaxTransform)
        }
        
        view.addSubview(navigationBorder)
        navigationBorder.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, safeArea: true)
        
        table.refreshControl = refreshControl
        
        view.addSubview(loadingSpinner)
        loadingSpinner.centerToSuperview().constrainToSize(70)
        
        updateTheme()
        
        barForegroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] notification in
            // This is the only way it works, otherwise it gets stuck
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                guard let self else { return }
                
                if let menu = self.parent as? MenuContainerController, menu.isOpen { return }
                
                self.animateBarsToVisible()
            }
        }
        
        WalletManager.instance.zapEvent.debounce(for: 0.6, scheduler: RunLoop.main).sink { [weak self] zap in
            guard let self, let index = posts.firstIndex(where: { $0.post.id == zap.postId }) else { return }
            var zaps = posts[index].zaps
            let zapIndex = zaps.firstIndex(where: { $0.amountSats <= zap.amountSats }) ?? zaps.count
            zaps.insert(zap, at: zapIndex)
            posts[index].zaps = zaps
            
            guard
                self.view.window != nil,
                table.indexPathsForVisibleRows?.contains(where: { $0.row == index && $0.section == self.postSection }) == true
            else { return }
            
            if posts[index].zaps.count > 2, let cell = table.cellForRow(at: IndexPath(row: index, section: postSection)) as? PostCell {
                cell.updateMenu(posts[index])
            } else {
                table.reloadData()
            }
        }
        .store(in: &cancellables)
    }
    
    func zapFromCell(_ cell: PostCell, showPopup: Bool) {
        guard 
            let indexPath = table.indexPath(for: cell),
            let post = postForIndexPath(indexPath)
        else { return }
        
        let postUser = post.user.data
        if postUser.address == nil {
            showErrorMessage(title: "Can’t Zap", "User you're trying to zap didn't set up their lightning wallet")
            return
        }
        
        guard let hasWallet = WalletManager.instance.userHasWallet else { return } // Unknown
        guard hasWallet else {
            let popup = PopupMenuViewController(message: "To zap people on Nostr, you need to activate your wallet and get some sats.", actions: [
                .init(title: "Go to wallet", image: .init(named: "selectedTabIcon-wallet"), handler: { [weak self] _ in
                    self?.mainTabBarController?.switchToTab(.wallet)
                })
            ])
            present(popup, animated: true)
            return
        }
        
        if showPopup {
            let popup = PopupZapSelectionViewController(userToZap: postUser) { self.doZapFromCell(cell, amount: $0, message: $1) }
            present(popup, animated: true)
            return
        }
        
        let zapAmount = IdentityManager.instance.userSettings?.zapDefault?.amount ?? 20
        let zapMessage = IdentityManager.instance.userSettings?.zapDefault?.message ?? ""
        doZapFromCell(cell, amount: zapAmount, message: zapMessage)
    }
    
    func doZapFromCell(_ cell: PostCell, amount: Int, message: String) {
        guard 
            let indexPath = table.indexPath(for: cell),
            let parsed = postForIndexPath(indexPath)
        else { return }
        
        
        let newZapAmount = parsed.post.satszapped + amount
        
        if WalletManager.instance.balance < amount {
            let popup = PopupMenuViewController(message: "Insufficient funds to perform this zap", actions: [
                .init(title: "Go to wallet", image: .init(named: "selectedTabIcon-wallet"), handler: { [weak self] _ in
                    self?.mainTabBarController?.switchToTab(.wallet)
                })
            ])
            present(popup, animated: true)
            return
        }

        animateZap(cell, amount: newZapAmount)

        Task { @MainActor [weak self] in
            do {
                try await WalletManager.instance.zap(post: parsed, sats: amount, note: message)
                
                UserDefaults.standard.howManyZaps += 1
                if UserDefaults.standard.howManyZaps >= 3 {
                    guard let scene = self?.view.window?.windowScene else { return }
                    #if !DEBUG
                    SKStoreReviewController.requestReview(in: scene)
                    #endif
                }
            } catch {
                if let e = error as? WalletError {
                    self?.showErrorMessage(e.message)
                } else {
                    self?.showErrorMessage("Insufficient funds for this zap. Check your wallet.")
                }
                if self?.view.window != nil {
                    self?.table.reloadData()
                }
            }
        }
    }
    
    func animateZap(_ cell: PostCell, amount: Int) {
        let animView = Self.bigZapAnimView
        
        let iconToPin = cell.zapButton.iconView.window != nil ? cell.zapButton.iconView : (cell.zapGallery as? LargeZapGalleryView)?.zapPillButton.imageView
        
        if let iconToPin {
            view.addSubview(animView)
            animView
                .centerToView(iconToPin, axis: .vertical, offset: 2)
                .centerToView(iconToPin, axis: .horizontal, offset: 62)
        }
        
        view.layoutIfNeeded()
        
        cell.zapButton.animateTo(amount, filled: true)
        
        heavy.impactOccurred()
        
        animView.alpha = 1
        animView.play()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            UIView.animate(withDuration: 0.2) {
                animView.alpha = 0
            } completion: { _ in
                animView.removeFromSuperview()
            }
        }
    }
}

extension FeedViewController: PostCellDelegate {
    func postCellDidTapRepost(_ cell: PostCell) {
        guard let indexPath = table.indexPath(for: cell) else { return }
        let post = posts[indexPath.row].post
        let popup = PopupMenuViewController()
        
        popup.addAction(.init(title: "Repost", image: .init(named: "repostIconLarge"), handler: { _ in
            PostingManager.instance.sendRepostEvent(post: post)
            cell.repostButton.animateTo(post.reposts + 1, filled: true)
        }))
        
        popup.addAction(.init(title: "Quote", image: .init(named: "quoteIconLarge"), handler: { _ in
            guard let noteRef = bech32_note_id(post.universalID) else { return }
            let new = NewPostViewController()
            new.textView.text = "\n\nnostr:\(noteRef)"
            self.present(new, animated: true)
        }))
        
        present(popup, animated: true)
    }
    
    func postCellDidTapImages(_ cell: PostCell, resource: MediaMetadata.Resource) {
        if resource.url.isVideoURL {
            handleVideoUrlTapped(resource.url, in: cell)
            return
        }
        
        guard let index = table.indexPath(for: cell)?.row else { return }
        
        let allImages = posts[index].mediaResources.map { $0.url } .filter { $0.isImageURL }
        
        if let imageCell = cell.mainImages.currentImageCell() {
            ImageGalleryController(current: resource.url, all: allImages).present(from: self, imageView: imageCell.imageView)
            return
        }
        
        present(ImageGalleryController(current: resource.url, all: allImages), animated: true)
    }
    
    func postCellDidTapEmbeddedImages(_ cell: PostCell, resource: MediaMetadata.Resource) {
        guard
            let index = table.indexPath(for: cell)?.row,
            let post = posts[index].embededPost
        else { return }
        
        if resource.url.isVideoURL {
            handleVideoUrlTapped(resource.url, in: cell)
            return
        }
        
        let allImages = post.mediaResources.map { $0.url } .filter { $0.isImageURL }
        
        if let imageCell = cell.postPreview.mainImages.currentImageCell() {
            ImageGalleryController(current: resource.url, all: allImages).present(from: self, imageView: imageCell.imageView)
            return
        }
        
        present(ImageGalleryController(current: resource.url, all: allImages), animated: true)
    }
    
    func handleVideoUrlTapped(_ url: String, in cell: PostCell) {
        guard url.isVideoURL else {
            if let url = URL(string: url) {
                let safari = SFSafariViewController(url: url)
                present(safari, animated: true)
            }
            return
        }
        
        if let videoCell = cell.mainImages.currentVideoCell(), videoCell.player?.avPlayer.rate ?? 1 < 0.01 {
            videoCell.player?.play()
            videoCell.player?.isMuted = false
            return
        }
        
        if VideoPlaybackManager.instance.currentlyPlaying?.url != url {
            VideoPlaybackManager.instance.currentlyPlaying = .init(url: url)
        }
        
        guard let player = VideoPlaybackManager.instance.currentlyPlaying else { return }
        
        present(FullScreenVideoPlayerController(player), animated: true) 
    }
}

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == postSection, let post = posts[safe: indexPath.row] else { return }
        open(post: post)
    }
}

extension FeedViewController: ZapGalleryViewDelegate {
    func menuConfigurationForZap(_ zap: ParsedZap) -> UIContextMenuConfiguration? {
        let profileVC = ProfileViewController(profile: zap.user)
        var items: [UIAction] = [
            UIAction(title: "Open Profile", image: UIImage(systemName: "person.crop.circle.fill"), handler: { [weak self] _ in
                self?.show(profileVC, sender: nil)
            })
        ]
        
        if !zap.message.isEmpty {
            items.append(UIAction(title: NSLocalizedString("Copy text", comment: ""), image: UIImage(named: "MenuCopyText")) { [weak self] _ in
                UIPasteboard.general.string = zap.message
                
                self?.view.showToast("Copied!")
            })
            
            if zap.message.isValidURL, let url = URL(string: zap.message) {
                items.append(.init(title: "Open URL", image: UIImage(named: "MenuCopyLink")) { [weak self] _ in
                    self?.present(SFSafariViewController(url: url), animated: true)
                })
            }
        }
        
        return .init(previewProvider: { profileVC }, actionProvider: { suggested in
            return UIMenu(title: zap.message, children: items + suggested)
        })
    }
    
    func mainActionForZap(_ zap: ParsedZap) {
        show(ProfileViewController(profile: zap.user), sender: nil)
    }
}
