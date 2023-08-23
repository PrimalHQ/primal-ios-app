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
    let navigationBarLengthner = SpacerView(height: 7)
    let table = UITableView()
    let safeAreaSpacer = UIView()
    lazy var stack = UIStackView(arrangedSubviews: [safeAreaSpacer, navigationBarLengthner, table])
    
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
        
        navigationBarLengthner.backgroundColor = .background
        
        updateCellID()
        table.register(FeedDesign.current.feedCellClass, forCellReuseIdentifier: postCellID)
        table.reloadData()
        
        view.backgroundColor = .background
        table.backgroundColor = .background
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
        
        safeAreaSpacer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        updateTheme()
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
            guard
                let ref = post.mentions.first(where: { $0.text == info })?.reference,
                let user = post.mentionedUsers.first(where: { $0.pubkey == ref })
            else { return }
            
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
