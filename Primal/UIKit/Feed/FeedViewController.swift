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

class FeedViewController: UIViewController, UITableViewDataSource, Themeable {
    let navigationBarLengthner = SpacerView(height: 7)
    var table = UITableView()
    lazy var stack = UIStackView(arrangedSubviews: [navigationBarLengthner, table])
    let feed: FeedManager
    
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
                        didRepost: PostManager.instance.hasReposted(data.post.id)
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
}

extension FeedViewController: PostCellDelegate {
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
        
        cell.updateButtons(posts[indexPath.row], didLike: true, didRepost: PostManager.instance.hasReposted(posts[indexPath.row].post.id))
    }
    
    func postCellDidTapRepost(_ cell: PostCell) {
        guard let indexPath = table.indexPath(for: cell) else { return }
        PostManager.instance.sendRepostEvent(nostrContent: posts[indexPath.row].post.toRepostNostrContent())
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
