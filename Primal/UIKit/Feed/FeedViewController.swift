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
    let navigationBarLengthner = SpacerView(size: 7)
    var table = UITableView()
    lazy var stack = UIStackView(arrangedSubviews: [navigationBarLengthner, table])
    
    var posts: [(PrimalPost, ParsedContent)] = [] {
        didSet {
            table.reloadData()
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
    
    func open(post: PrimalPost) {
        let threadVC = ThreadViewController(threadId: post.post.id)
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
                        didLike: LikeManager.the.hasLiked(data.0.post.id),
                        didRepost: PostManager.the.hasReposted(data.0.post.id)
            )
            cell.delegate = self
        }
        
        if indexPath.row > posts.count - 10  {
            FeedManager.the.requestNewPage()
        }
        return cell
    }
    
    func updateTheme() {
        posts.forEach { $0.1.buildContentString() }
        
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
    func postCellDidTapLike(_ cell: PostCell) {
        guard let indexPath = table.indexPath(for: cell) else { return }
        
        LikeManager.the.sendLikeEvent(post: posts[indexPath.row].0.post)
        
        cell.updateButtons(posts[indexPath.row].0, didLike: true, didRepost: PostManager.the.hasReposted(posts[indexPath.row].0.post.id))
    }
    
    func postCellDidTapRepost(_ cell: PostCell) {
        guard let indexPath = table.indexPath(for: cell) else { return }
        PostManager.the.sendRepostEvent(nostrContent: posts[indexPath.row].0.post.toRepostNostrContent())
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
        binding.view.backgroundColor = .clear
        binding.modalPresentationStyle = .overFullScreen
        present(binding, animated: true)
    }
    
    func postCellDidLoadImage(_ cell: PostCell) {
        guard let indexPath = table.indexPath(for: cell) else { return }
        table.reloadRows(at: [indexPath], with: .none)
    }
}

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        open(post: posts[indexPath.row].0)
    }
}
