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

class FeedViewController: UIViewController, UITableViewDataSource, Themeable {
    let refreshControl = UIRefreshControl()
    let table = UITableView()
    let safeAreaSpacer = UIView()
    lazy var stack = UIStackView(arrangedSubviews: [safeAreaSpacer, table])
    
    let hapticGenerator = UIImpactFeedbackGenerator(style: .light)
    let heavy = UIImpactFeedbackGenerator(style: .heavy)
    
    var postCellID = "cell" // Needed for updating the theme
    
    var postSection: Int { 0 }
    var posts: [ParsedContent] = [] {
        didSet {
            guard oldValue.count != 0, oldValue.count < posts.count else {
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        hapticGenerator.prepare()
        heavy.prepare()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        scrollDirectionCounter = 100
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
                        didZap: ZapManager.instance.hasZapped(data.post.id),
                        isMuted: MuteManager.instance.isMuted(data.user.data.pubkey)
            )
            cell.delegate = self
        }
        return cell
    }
    
    func updateTheme() {
        posts.forEach {
            $0.buildContentString()
            $0.embededPost?.buildContentString()
        }
        
        updateCellID()
        table.register(FeedDesign.current.feedCellClass, forCellReuseIdentifier: postCellID)
        table.reloadData()
        
        refreshControl.tintColor = .accent
        
        view.backgroundColor = .background
        table.backgroundColor = .background
    }
    
    private(set) var lastContentOffset: CGFloat = 0
    private(set) var safeAreaSpacerHeight: CGFloat = 0
    @Published private(set) var isAnimatingBars = false
    @Published private(set) var isShowingBars = true
    var shouldShowBars: Bool { scrollDirectionCounter >= 0 }
    @Published private var scrollDirectionCounter = 0 // This is used to track in which direction is the scrollview scrolling and for how long (disregard any scrolling that hasn't been happening for at least 5 update cycles because system sometimes scrolls the content)
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 100 {
            scrollDirectionCounter = 100
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
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool { isShowingBars }
    
    func animateBars() {
        let shouldShowBars = scrollDirectionCounter >= 0
        guard !isAnimatingBars, shouldShowBars != isShowingBars else { return }
        
        isAnimatingBars = true
        table.bounces = shouldShowBars
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(900)) {
            self.isShowingBars = shouldShowBars
            self.isAnimatingBars = false
        }
        
        let oldValue = !shouldShowBars
        
        safeAreaSpacerHeight = max(safeAreaSpacerHeight, safeAreaSpacer.frame.height)
        
        var shouldMoveOffset = safeAreaSpacer.superview != nil
        
        if shouldShowBars {
            mainTabBarController?.buttonStack.alpha = 1
            mainTabBarController?.notificationIndicator.alpha = 1
        } else {
            // MAKE SURE TO DO THIS AFTER ANIMATION IN OTHER CASE
            safeAreaSpacer.isHidden = oldValue
            if shouldMoveOffset {
                table.contentOffset = .init(x: 0, y: table.contentOffset.y - safeAreaSpacerHeight)
            }
        }
        
        mainTabBarController?.setTabBarHidden(oldValue, animated: true)
        
        UIView.animate(withDuration: 0.3) {
            self.navigationController?.navigationBar.transform = shouldShowBars ? .identity : .init(translationX: 0, y: -100)
        } completion: { _ in
            if shouldShowBars {
                self.safeAreaSpacer.isHidden = oldValue
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
        
        safeAreaSpacer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        table.refreshControl = refreshControl
        
        updateTheme()
    
        Publishers.CombineLatest3($isShowingBars, $scrollDirectionCounter, $isAnimatingBars)
            .receive(on: DispatchQueue.main).sink { [weak self] isShowing, directionCounter, isAnimating in
                if abs(directionCounter) < 10 { return } // Disregard small scrolling (sometimes the system scrolls quickly)
                let shouldShow = directionCounter > 0
                guard isShowing != shouldShow, !isAnimating else { return }
                self?.animateBars()
            }
            .store(in: &cancellables)
    }
    
    func animateZap(_ cell: PostCell, amount: Int32) {
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
        guard let index = table.indexPath(for: cell)?.row else { return }
        
        let post = posts[index].post
        let postUser = posts[index].user.data
        
        guard let lnurl = postUser.lnurl else {
            showErrorMessage(title: "Can’t Zap", "User you're trying to zap didn't set up their lightning wallet")
            return
        }
        
        guard UserDefaults.standard.nwc != nil else {
            let walletSettings = SettingsWalletViewController()
            show(walletSettings, sender: nil)
            return
        }
        
        let popup = PopupZapSelectionViewController(userToZap: postUser) { [weak self] zapAmount in
            let newZapAmount = post.satszapped + Int32(zapAmount)
            
            self?.animateZap(cell, amount: newZapAmount)
    
            ZapManager.instance.zap(lnurl: lnurl, target: .note(NoteZapTarget(eventId: post.id, authorPubkey: post.pubkey)), type: .pub, amount: zapAmount) {
                // do nothing
            }
        }
        present(popup, animated: true)
    }
    
    func postCellDidTapZap(_ cell: PostCell) {
        guard let index = table.indexPath(for: cell)?.row else { return }

        let post = posts[index].post
        let postUser = posts[index].user.data
             
        guard let lnurl = postUser.lnurl else {
            showErrorMessage(title: "Can’t Zap", "User you're trying to zap didn't set up their lightning wallet")
            return
        }
        
        guard UserDefaults.standard.nwc != nil else {
            let walletSettings = SettingsWalletViewController()
            show(walletSettings, sender: nil)
            return
        }
        
        let zapAmount = IdentityManager.instance.userSettings?.content.defaultZapAmount ?? 100;
        let newZapAmount = post.satszapped + Int32(zapAmount)
        
        animateZap(cell, amount: newZapAmount)
        
        ZapManager.instance.zap(lnurl: lnurl, target: .note(NoteZapTarget(eventId: post.id, authorPubkey: post.pubkey)), type: .pub, amount: zapAmount) {
            // do nothing
        }
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
            new.textView.text = "nostr:\(noteRef)\n\n"
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
        
        guard !urlString.isValidURL || !urlString.hasPrefix("http") else {
            if urlString.isVideoURL {
                let player = AVPlayerViewController()
                player.player = AVPlayer(url: url)
                present(player, animated: true) {
                    player.player?.play()
                }
                return
            }
            
            if urlString.isValidURL {
                let safari = SFSafariViewController(url: url)
                present(safari, animated: true)
            }
            
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
    
    func postCellDidTapImages(resource: MediaMetadata.Resource) {
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
    
    func postCellDidTapImages(_ cell: PostCell, image: URL, images: [URL]) {
    }
    
    func postCellDidLoadImage(_ cell: PostCell) {
        guard let indexPath = table.indexPath(for: cell) else { return }
        table.reloadRows(at: [indexPath], with: .none)
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
