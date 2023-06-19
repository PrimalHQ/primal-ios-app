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
    var table = UITableView()
    lazy var stack = UIStackView(arrangedSubviews: [navigationBarLengthner, table])
    let feed: FeedManager
    
    let hapticGenerator = UIImpactFeedbackGenerator(style: .light)
    let heavy = UIImpactFeedbackGenerator(style: .heavy)
    
    var postSection: Int { 0 }
    var posts: [ParsedContent] = [] {
        didSet {
            guard oldValue.count != 0, oldValue.count < posts.count else {
                table.reloadData()
                return
            }
            let indexes = (oldValue.count..<posts.count).map { IndexPath(row: $0, section: postSection) }
            table.insertRows(at: indexes, with: .none)
        }
    }
        
    var cancellables: Set<AnyCancellable> = []
    
    init(feed: FeedManager) {
        self.feed = feed
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
    
    func open(post: PrimalFeedPost) {
        let threadVC = ThreadViewController(threadId: post.id)
        show(threadVC, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? FeedCell {
            let data = posts[indexPath.row]
            cell.update(data,
                        didLike: LikeManager.instance.hasLiked(data.post.id),
                        didRepost: PostManager.instance.hasReposted(data.post.id),
                        didZap: ZapManager.instance.hasZapped(data.post.id)
            )
            cell.delegate = self
        }
        
        if indexPath.row > posts.count - 10  {
            feed.requestNewPage()
        }
        return cell
    }
    
    func updateTheme() {
        posts.forEach {
            $0.buildContentString()
            $0.embededPost?.buildContentString()
        }
        
        navigationBarLengthner.backgroundColor = .background
        
        table.removeFromSuperview()
        table = UITableView() // We need to flush old cells
        table.register(FeedCell.self, forCellReuseIdentifier: "cell")
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        
        stack.addArrangedSubview(table)
        
        view.backgroundColor = .background
        table.backgroundColor = .background
    }
}

private extension FeedViewController {
    func setup() {
        stack.axis = .vertical
        view.insertSubview(stack, at: 0)
        stack
            .pinToSuperview(edges: [.horizontal, .bottom])
            .pinToSuperview(edges: .top, safeArea: true)
        
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
    func postCellDidTapZap(_ cell: PostCell) {
        guard let index = table.indexPath(for: cell)?.row else { return }

        let post = posts[index].post
        let postUser = posts[index].user.data
             
        guard let lnurl = postUser.lnurl else {
            showErrorMessage("User you're trying to zap didn't set up their lightning wallet")
            return
        }
        
        guard UserDefaults.standard.nwc != nil else {
            let walletSettings = SettingsWalletViewController()
            show(walletSettings, sender: nil)
            return
        }
        
        let zapAmount = IdentityManager.instance.userSettings?.content.defaultZapAmount ?? 10;
        let newZapAmount = post.satszapped + Int32(zapAmount)
        
        animateZap(cell, amount: newZapAmount)
        
        ZapManager.instance.zap(lnurl: lnurl, target: .note(id: post.id, author: post.pubkey), type: .pub, amount: zapAmount) { [weak self] in
            
        }
    }
    
    func postCellDidTapProfile(_ cell: PostCell) {
        guard let index = table.indexPath(for: cell)?.row else { return }
        let profile = ProfileViewController(profile: posts[index].user)
        show(profile, sender: nil)
    }
    
    func postCellDidTapRepostedProfile(_ cell: PostCell) {
        guard let index = table.indexPath(for: cell)?.row, let profile = posts[index].reposted else { return }
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
        PostManager.instance.sendRepostEvent(nostrContent: posts[indexPath.row].post.toRepostNostrContent())
        cell.repostButton.animateTo(posts[indexPath.row].post.reposts + 1, filled: true)
    }
    
    func postCellDidTapPost(_ cell: PostCell) {
        guard let indexPath = table.indexPath(for: cell) else { return }
        open(post: posts[indexPath.row].post)
    }
    
    func postCellDidTapEmbededPost(_ cell: PostCell) {
        guard
            let indexPath = table.indexPath(for: cell),
            let post = posts[indexPath.row].embededPost?.post
        else { return }
        
        open(post: post)
    }
    
    func postCellDidTapURL(_ cell: PostCell, url: URL?) {
        guard let url else {
            guard
                let indexPath = table.indexPath(for: cell),
                let url = posts[indexPath.row].firstExtractedURL
            else { return }
            
            let safari = SFSafariViewController(url: url)
            present(safari, animated: true)
            return
        }
        
        if url.absoluteString.isVideoURL {
            let player = AVPlayerViewController()
            player.player = AVPlayer(url: url)
            present(player, animated: true) {
                player.player?.play()
            }
            return
        }
        
        let safari = SFSafariViewController(url: url)
        present(safari, animated: true)
    }
    
    func postCellDidTapImages(_ cell: PostCell, resource: MediaMetadata.Resource, resources: [MediaMetadata.Resource]) {
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
}

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        open(post: posts[indexPath.row].post)
    }
}
