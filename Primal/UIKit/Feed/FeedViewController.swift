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

class FeedViewController: UIViewController {
    let feed: Feed
    
    private let table = UITableView()
    
    var fullBleed = false
    var posts: [(PrimalPost, String, [URL])] = [] {
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
    
    @objc func toggleFullBleed() {
        fullBleed.toggle()
        table.reloadData()
    }
}

private extension FeedViewController {
    func setup() {        
        view.addSubview(table)
        table.pinToSuperview(safeArea: true)
        table.register(FeedCell.self, forCellReuseIdentifier: "cell")
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
    }
}

extension FeedViewController: FeedCellDelegate {
    func feedCellDidTapPost(_ cell: FeedCell) {
        guard let indexPath = table.indexPath(for: cell) else { return }
        let item = posts[indexPath.row].0
        feed.requestThread(postId: item.post.id, subId: item.post.id)
        let threadVC = ThreadViewController(feed: feed)
        show(threadVC, sender: nil)
    }
    
    func feedCellDidTapURL(_ cell: FeedCell, url: URL) {
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
    
    func feedCellDidTapImages(_ cell: FeedCell, image: URL, images: [URL]) {
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
        let item = posts[indexPath.row].0
        feed.requestThread(postId: item.post.id, subId: item.post.id)
        let threadVC = ThreadViewController(feed: feed)
        show(threadVC, sender: nil)
    }
}

extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? FeedCell {
            let data = posts[indexPath.row]
            cell.update(data.0, text: data.1, imageUrls: data.2, edgeBleed: fullBleed)
            cell.delegate = self
        }
        
        if indexPath.row == posts.count - 10 {
            feed.requestNewPage()
        }
        return cell
    }
}
