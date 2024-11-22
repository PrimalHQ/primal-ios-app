//
//  FeedArticlePreviewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.8.24..
//

import UIKit
import Kingfisher
import Combine

final class FeedPreviewParentController: UIViewController {
    var cancellables: Set<AnyCancellable> = []
    
    let feed: PrimalFeed
    let type: PrimalFeedType
    let info: ParsedFeedFromMarket
    
    let addButton = UIButton().constrainToSize(height: 52)
    
    init(feed: PrimalFeed, type: PrimalFeedType, feedInfo: ParsedFeedFromMarket) {
        self.feed = feed
        self.type = type
        info = feedInfo
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension FeedPreviewParentController {
    func setup() {
        view.backgroundColor = .background
        
        let pullBarParent = UIView()
        let pullBar = UIView()
        pullBarParent.addSubview(pullBar)
        pullBar.pinToSuperview(edges: .vertical).centerToSuperview(axis: .horizontal)
        
        let title = UILabel()
        title.text = "Feed Details"
        title.font = .appFont(withSize: 20, weight: .bold)
        title.textColor = .foreground
        title.setContentCompressionResistancePriority(.required, for: .vertical)
        title.textAlignment = .center
        
        let previewFeed: UIViewController
        switch type {
        case .article:
            previewFeed = ArticleFeedPreviewFeedController(feed: feed, feedInfo: info)
        case .note:
            previewFeed = NoteFeedPreviewController(feed: feed, feedInfo: info)
        }
        previewFeed.willMove(toParent: self)
        
        addButton.layer.cornerRadius = 26
        addButton.titleLabel?.font = .appFont(withSize: 18, weight: .semibold)
        addButton.backgroundColor = .accent
        addButton.setTitleColor(.white, for: .normal)
        let addButtonParent = UIView()
        addButtonParent.addSubview(addButton)
        addButton.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .top, padding: 20).pinToSuperview(edges: .bottom)
        
        let stack = UIStackView(axis: .vertical, [
            pullBarParent, SpacerView(height: 20, priority: .required),
            title, SpacerView(height: 14, priority: .required),
            previewFeed.view,
            addButtonParent
        ])
        
        view.addSubview(stack)
        stack.pinToSuperview(edges: .top, padding: 16).pinToSuperview(edges: .bottom, safeArea: true).pinToSuperview(edges: .horizontal)
        
        addChild(previewFeed)
        previewFeed.didMove(toParent: self)
        
        pullBar.constrainToSize(width: 60, height: 5)
        pullBar.backgroundColor = .foreground.withAlphaComponent(0.8)
        pullBar.layer.cornerRadius = 2.5
        
        if let backButton = customBackButton.customView as? UIButton {
            view.addSubview(backButton)
            backButton
                .pinToSuperview(edges: .leading, padding: 20)
                .centerToView(title, axis: .vertical)
        }
        
        addButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            
            var all = PrimalFeed.getAllFeeds(type)
            
            if all.contains(where: { $0.spec == self.feed.spec }) {
                all.removeAll(where: { $0.spec == self.feed.spec })
            } else {
                all.append(feed)
                
                navigationController?.popToRootViewController(animated: true)
            }
            
            PrimalFeed.setAllFeeds(all, type: type, notifyBackend: true)
            updateButton()
        }), for: .touchUpInside)
        updateButton()
    }
    
    func updateButton() {
        if PrimalFeed.getAllFeeds(type).contains(where: { $0.spec == feed.spec }) {
            addButton.setTitle("Remove Feed", for: .normal)
        } else {
            addButton.setTitle("Add Feed", for: .normal)
        }
    }
}
