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

class FeedViewController: UIViewController, UITableViewDataSource {
    let feed: Feed
    lazy var likingManager = LikingManager(feed: feed)
    lazy var repostingManager = RepostingManager(feed: feed)
    
    let navigationBarLengthner = SpacerView(size: 7)
    let table = UITableView()
    
    var posts: [(PrimalPost, ParsedContent)] = [] {
        didSet {
            table.reloadData()
        }
    }
    
    var cancellables: Set<AnyCancellable> = []
    
    init(feed: Feed) {
        self.feed = feed
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func open(post: PrimalPost) {
        let threadVC = ThreadViewController(feed: feed, threadId: post.post.id)
        show(threadVC, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? FeedCell {
            let data = posts[indexPath.row]
            cell.update(data.0,
                        parsedContent: data.1,
                        didLike: likingManager.hasLiked(data.0.post.id),
                        didRepost: repostingManager.hasReposted(data.0.post.id)
            )
            cell.delegate = self
        }
        
        if indexPath.row == posts.count - 10 {
            feed.requestNewPage()
        }
        return cell
    }
}

private extension FeedViewController {
    func setup() {
        navigationBarLengthner.backgroundColor = .black
        let stack = UIStackView(arrangedSubviews: [navigationBarLengthner, table])
        stack.axis = .vertical
        view.addSubview(stack)
        stack
            .pinToSuperview(edges: [.horizontal, .bottom])
            .pinToSuperview(edges: .top, safeArea: true)
        
        table.register(FeedCell.self, forCellReuseIdentifier: "cell")
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
    }
}

extension FeedViewController: PostCellDelegate {
    func postCellDidTapLike(_ cell: PostCell) {
        guard let indexPath = table.indexPath(for: cell) else { return }
        likingManager.sendLikeEvent(post: posts[indexPath.row].0.post)
    }
    
    func postCellDidTapRepost(_ cell: PostCell) {
        guard let indexPath = table.indexPath(for: cell) else { return }
        repostingManager.sendRepostEvent(nostrContent: posts[indexPath.row].0.post.toRepostNostrContent()) 
    }
    
    func postCellDidTapPost(_ cell: PostCell) {
        guard let indexPath = table.indexPath(for: cell) else { return }
        open(post: posts[indexPath.row].0)
    }
    
    func postCellDidTapURL(_ cell: PostCell, url: URL) {
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
    
    func postCellDidTapImages(_ cell: PostCell, image: URL, images: [URL]) {
        weak var viewController: UIViewController?
        let binding = UIHostingController(rootView: ImageViewerRemote(
            imageURL: .init(get: { image.absoluteString }, set: { _ in }),
            viewerShown: .init(get: { true }, set: { _ in viewController?.dismiss(animated: true) })
        ))
        viewController = binding
        binding.modalPresentationStyle = .overFullScreen
        present(binding, animated: true)
    }
}

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        open(post: posts[indexPath.row].0)
    }
}
