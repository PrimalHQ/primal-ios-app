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

class FeedViewController: UIViewController, UITableViewDataSource, Themeable {
    var refreshControl = UIRefreshControl()
    let table = UITableView()
    let safeAreaSpacer = UIView()
    let navigationBorder = UIView().constrainToSize(height: 1)
    lazy var stack = UIStackView(arrangedSubviews: [safeAreaSpacer, navigationBorder, table])
    
    let hapticGenerator = UIImpactFeedbackGenerator(style: .light)
    let heavy = UIImpactFeedbackGenerator(style: .heavy)
    
    let loadingSpinner = LoadingSpinnerView()
    
    var postCellID = "cell" // Needed for updating the theme
    
    var postSection: Int { 0 }
    var posts: [ParsedContent] = [] {
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
        
        shouldShowBars = true
        if animated {
            animateBars()
        } else {
            updateBars()
        }
        
        VideoPlaybackManager.instance.currentlyPlaying?.delayedPause()
    }
    
    @discardableResult
    func open(post: ParsedContent) -> FeedViewController {
        let threadVC = ThreadViewController(threadId: post.post.id)
        show(threadVC, sender: nil)
        return threadVC
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: postCellID, for: indexPath)
        if let cell = cell as? FeedCell {
            let data = posts[indexPath.row]
            cell.update(data,
                        didLike: LikeManager.instance.hasLiked(data.post.id),
                        didRepost: PostManager.instance.hasReposted(data.post.id),
                        didZap: WalletManager.instance.hasZapped(data.post.id),
                        isMuted: MuteManager.instance.isMuted(data.user.data.pubkey)
            )
            cell.delegate = self
        }
        
        if let postToPreload = posts[safe: indexPath.row + 10] {
            if let url = postToPreload.mediaResources.first?.url(for: .large), url.absoluteString.isImageURL {
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
            guard let videoCell = postCell.mainImages.visibleCells.first as? VideoCell ?? postCell.postPreview.mainImages.visibleCells.first as? VideoCell else { return }
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
    private(set) var lastContentOffset: CGFloat = 0
    private(set) var safeAreaSpacerHeight: CGFloat = 0
    @Published private(set) var isAnimatingBars = false
    @Published private(set) var isShowingBars = true
    var shouldShowBars: Bool {
        get { scrollDirectionCounter >= 0 }
        set { scrollDirectionCounter = newValue ? 50 : -50 }
    }
    @Published private var scrollDirectionCounter = 0 // This is used to track in which direction is the scrollview scrolling and for how long (disregard any scrolling that hasn't been happening for at least 5 update cycles because system sometimes scrolls the content)
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 100 {
            scrollDirectionCounter = 50
        } else {
            if (lastContentOffset > scrollView.contentOffset.y) {
                scrollDirectionCounter = max(1, scrollDirectionCounter + 1)
            }
            if (lastContentOffset < scrollView.contentOffset.y) {
                scrollDirectionCounter = min(-1, scrollDirectionCounter - 1)
            }
        }

        // update the new position acquired
        lastContentOffset = scrollView.contentOffset.y
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        shouldShowBars = true
        return true
    }
    
    func updateBars() {
        let shouldShowBars = ContentDisplaySettings.fullScreenFeed ? self.shouldShowBars : true
        
        safeAreaSpacer.isHidden = !shouldShowBars
        navigationBorder.isHidden = !shouldShowBars
        mainTabBarController?.setTabBarHidden(!shouldShowBars, animated: false)
        navigationController?.navigationBar.transform = shouldShowBars ? .identity : .init(translationX: 0, y: -100)
        if ContentDisplaySettings.fullScreenFeed {
            table.contentOffset = .init(x: 0, y: table.contentOffset.y + ((shouldShowBars ? 1 : -1) * self.safeAreaSpacerHeight))
        }

        isAnimatingBars = true
        isShowingBars = self.shouldShowBars
        isAnimatingBars = false
    }
    
    func animateBars() {
        var shouldShowBars = scrollDirectionCounter >= 0
        let endBarState = shouldShowBars
        guard !isAnimatingBars, shouldShowBars != isShowingBars else { return }
        
        if !ContentDisplaySettings.fullScreenFeed {
            shouldShowBars = true  // Disable override
        }
        
        isAnimatingBars = true
        table.bounces = shouldShowBars
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) {
            self.isShowingBars = endBarState
            self.isAnimatingBars = false
        }
        
        let oldValue = !shouldShowBars
        
        safeAreaSpacerHeight = max(safeAreaSpacerHeight, safeAreaSpacer.frame.height)
        
        let shouldMoveOffset = ContentDisplaySettings.fullScreenFeed && safeAreaSpacer.superview != nil
        
        if !shouldShowBars {
            // MAKE SURE TO DO THIS AFTER ANIMATION IN OTHER CASE
            safeAreaSpacer.isHidden = oldValue
            if shouldMoveOffset {
                table.contentOffset = .init(x: 0, y: table.contentOffset.y - safeAreaSpacerHeight)
            }
        }
        
        UIView.animate(withDuration: 0.3) {
            self.mainTabBarController?.setTabBarHidden(oldValue, animated: false)
            self.navigationController?.navigationBar.transform = shouldShowBars ? .identity : .init(translationX: 0, y: -100)
        } completion: { _ in
            if shouldShowBars {
                self.safeAreaSpacer.isHidden = oldValue
                self.navigationBorder.isHidden = oldValue
                if shouldMoveOffset {
                    self.table.contentOffset = .init(x: 0, y: self.table.contentOffset.y + self.safeAreaSpacerHeight)
                }
            }
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
        table.contentInset = .init(top: 0, left: 0, bottom: 90, right: 0)
        
        safeAreaSpacer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        table.refreshControl = refreshControl
        
        view.addSubview(loadingSpinner)
        loadingSpinner.centerToSuperview().constrainToSize(70)
        
        updateTheme()
    
        let shouldShowPublisher = $scrollDirectionCounter
            .filter({ abs($0) > 30 }) // Disregard small scrolling (sometimes the system scrolls quickly)
            .map { $0 > 0 }
        
        Publishers.CombineLatest3($isShowingBars, shouldShowPublisher, $isAnimatingBars)
            .dropFirst()
            .sink { [weak self] isShowing, shouldShow, isAnimating in
                guard isShowing != shouldShow, !isAnimating, self?.view.window != nil else { return }
                DispatchQueue.main.async {
                    self?.animateBars()
                }
            }
            .store(in: &cancellables)
        
        barForegroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] notification in
            // This is the only way it works, otherwise it gets stuck
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                guard let self else { return }
                self.isShowingBars = false
                self.shouldShowBars = true
            }
        }
    }
    
    func zapFromCell(_ cell: PostCell, showPopup: Bool) {
        guard let indexPath = table.indexPath(for: cell) else { return }
        
        let postUser = posts[indexPath.row].user.data
        if postUser.lnurl == nil {
            showErrorMessage(title: "Can’t Zap", "User you're trying to zap didn't set up their lightning wallet")
            return
        }
        
        guard let hasWallet = WalletManager.instance.userHasWallet else { return } // Unknown
        guard hasWallet else {
            let popup1 = PopupMenuViewController(message: "To zap people on Nostr, you need to activate your wallet and get some sats.", actions: [
                .init(title: "Go to wallet", image: .init(named: "selectedTabIcon-wallet"), handler: { [weak self] _ in
                    self?.mainTabBarController?.switchToTab(.wallet)
                })
            ])
            present(popup1, animated: true)
            return
        }
        
        if showPopup {
            let popup = PopupZapSelectionViewController(userToZap: postUser) { self.doZapFromCell(cell, amount: $0, message: $1) }
            present(popup, animated: true)
            return
        }
        
        let zapAmount = IdentityManager.instance.userSettings?.content.defaultZapAmount ?? 100
        doZapFromCell(cell, amount: zapAmount, message: "")
    }
    
    func doZapFromCell(_ cell: PostCell, amount: Int, message: String) {
        guard let indexPath = table.indexPath(for: cell) else { return }
        let index = indexPath.row
        let parsed = posts[index]
        
        let newZapAmount = parsed.post.satszapped + amount
        
        if WalletManager.instance.balance < newZapAmount {
            present(WalletInAppPurchaseController(), animated: true)
            return
        }

        animateZap(cell, amount: newZapAmount)

        Task { @MainActor [weak self] in
            do {
                try await WalletManager.instance.zap(post: parsed, sats: amount, note: message)
                
                UserDefaults.standard.howManyZaps += 1
                if UserDefaults.standard.howManyZaps >= 3 {
                    guard let scene = self?.view.window?.windowScene else { return }
                    SKStoreReviewController.requestReview(in: scene)
                }
            } catch {
                if let e = error as? WalletError {
                    self?.showErrorMessage(e.message)
                } else {
                    self?.showErrorMessage("Insufficient funds for this zap. Check your wallet.")
                }
                guard self?.posts.count ?? 0 > index else { return }
                self?.table.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
    
    func animateZap(_ cell: PostCell, amount: Int) {
        let animView = LottieAnimationView(animation: AnimationType.zapMedium.animation)
        view.addSubview(animView)
        animView
            .constrainToSize(width: 375, height: 100)
            .pin(to: cell.zapButton.iconView, edges: .top, padding: -38.5)
            .pin(to: cell.zapButton.iconView, edges: .leading, padding: -114.5)
        
        view.layoutIfNeeded()
        
        cell.zapButton.iconView.alpha = 0.01
        cell.zapButton.animateTo(amount, filled: true)
        
        heavy.impactOccurred()
            
        animView.play { _ in
            UIView.animate(withDuration: 0.2) {
                cell.zapButton.iconView.alpha = 1
                animView.alpha = 0
            } completion: { _ in
                animView.removeFromSuperview()
            }
        }
    }
}

extension FeedViewController: PostCellDelegate {
    func postCellDidLongTapZap(_ cell: PostCell) {
        zapFromCell(cell, showPopup: true)
    }
    
    func postCellDidTapZap(_ cell: PostCell) {
        zapFromCell(cell, showPopup: false)
    }
    
    func postCellDidTapProfile(_ cell: PostCell) {
        guard let index = table.indexPath(for: cell)?.row else { return }
        let profile = ProfileViewController(profile: posts[index].user)
        show(profile, sender: nil)
    }
    
    func postCellDidTapRepostedProfile(_ cell: PostCell) {
        guard let index = table.indexPath(for: cell)?.row, let profile = posts[index].reposted?.user else { return }
        show(ProfileViewController(profile: profile), sender: nil)
    }
    
    func postCellDidTapLike(_ cell: PostCell) {
        guard let indexPath = table.indexPath(for: cell) else { return }
        
        LikeManager.instance.sendLikeEvent(post: posts[indexPath.row].post)
        
        hapticGenerator.impactOccurred()
        
        cell.likeButton.animateTo(posts[indexPath.row].post.likes + 1, filled: true)
    }
    
    func postCellDidTapRepost(_ cell: PostCell) {
        guard let indexPath = table.indexPath(for: cell) else { return }
        let post = posts[indexPath.row].post
        let popup = PopupMenuViewController()
        
        popup.addAction(.init(title: "Repost", image: .init(named: "repostIconLarge"), handler: { _ in
            PostManager.instance.sendRepostEvent(nostrContent: post.toRepostNostrContent())
            cell.repostButton.animateTo(post.reposts + 1, filled: true)
        }))
        
        popup.addAction(.init(title: "Quote", image: .init(named: "quoteIconLarge"), handler: { _ in
            guard let noteRef = bech32_note_id(post.id) else { return }
            let new = NewPostViewController()
            new.textView.text = "\n\nnostr:\(noteRef)"
            self.present(new, animated: true)
        }))
        
        present(popup, animated: true)
    }
    
    func postCellDidTapReply(_ cell: PostCell) {
        guard
            let indexPath = table.indexPath(for: cell),
            let thread = open(post: posts[indexPath.row]) as? ThreadViewController
        else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
            thread.textInputView.becomeFirstResponder()
        }
    }
    
    func postCellDidTapPost(_ cell: PostCell) {
        guard let indexPath = table.indexPath(for: cell) else { return }
        open(post: posts[indexPath.row])
    }
    
    func postCellDidTapEmbededPost(_ cell: PostCell) {
        guard
            let indexPath = table.indexPath(for: cell),
            let post = posts[indexPath.row].embededPost
        else { return }
        
        open(post: post)
    }
    
    func postCellDidTapURL(_ cell: PostCell, url: URL?) {
        guard
            let indexPath = table.indexPath(for: cell),
            let url = url ?? posts[indexPath.row].linkPreview?.url
        else { return }
        
        let post = posts[indexPath.row]
        let urlString = url.absoluteString
        
        if urlString.isValidURL && urlString.lowercased().hasPrefix("http") {
            let safari = SFSafariViewController(url: url)
            present(safari, animated: true)
            return
        }
        
        guard let infoSub = urlString.split(separator: "//").last else { return }
        let info = String(infoSub)
        
        if urlString.hasPrefix("hashtag"), info.isHashtag {
            let feed = RegularFeedViewController(feed: FeedManager(search: info))
            show(feed, sender: nil)
            return
        }
        
        if urlString.hasPrefix("mention") {
            guard let user = post.mentionedUsers.first(where: { $0.pubkey == info }) else { return }
            
            let profile = ProfileViewController(profile: .init(data: user))
            show(profile, sender: nil)
            return
        }
        
        if urlString.hasPrefix("note") {
            guard let ref = post.notes.first(where: { $0.text == info })?.reference else { return }
            
            print(ref)
            return
        }
        
        return
    }
    
    func postCellDidTapImages(_ cell: PostCell, resource: MediaMetadata.Resource) {
        if resource.url.isVideoURL {
            handleVideoUrlTapped(resource.url, in: cell)
            return
        }
        
        weak var viewController: UIViewController?
        let binding = UIHostingController(rootView: ImageViewerRemote(
            imageURL: .init(get: { resource.url }, set: { _ in }),
            viewerShown: .init(get: { true }, set: { _ in viewController?.dismiss(animated: true) })
        ))
        viewController = binding
        binding.view.backgroundColor = .clear
        binding.modalPresentationStyle = .overFullScreen
        present(binding, animated: true)
    }
    
    func handleVideoUrlTapped(_ url: String, in cell: PostCell) {
        guard url.isVideoURL else { return }
        
        if let videoCell = cell.mainImages.visibleCells.first as? VideoCell, videoCell.player?.avPlayer.rate ?? 1 < 0.01 {
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
    
    // MARK: - Menu actions
    func postCellDidTapShare(_ cell: PostCell) {
        guard let indexPath = table.indexPath(for: cell) else { return }
        
        let activityViewController = UIActivityViewController(activityItems: [posts[indexPath.row].webURL()], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    func postCellDidTapCopyLink(_ cell: PostCell) {
        guard let indexPath = table.indexPath(for: cell) else { return }
        
        UIPasteboard.general.string = posts[indexPath.row].webURL()
        view.showToast("Copied!")
    }
    
    func postCellDidTapCopyContent(_ cell: PostCell) {
        guard let indexPath = table.indexPath(for: cell) else { return }
        
        UIPasteboard.general.string = posts[indexPath.row].attributedText.string
        view.showToast("Copied!")
    }
    
    func postCellDidTapReport(_ cell: PostCell) {
        
    }
    
    @objc func postCellDidTapMute(_ cell: PostCell) {
        guard let indexPath = table.indexPath(for: cell) else { return }
        let pubkey = posts[indexPath.row].user.data.pubkey
        let mm = MuteManager.instance
        mm.toggleMute(pubkey)
    }
}

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        open(post: posts[indexPath.row])
    }
}

