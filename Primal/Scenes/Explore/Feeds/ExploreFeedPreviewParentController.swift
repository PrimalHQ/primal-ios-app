//
//  ExploreFeedPreviewParentController.swift
//  Primal
//
//  Created by Pavle Stevanović on 26.9.24..
//

import UIKit
import Kingfisher
import Combine

extension UIButton.Configuration {
    static func capsule14BlackWhite(_ text: String) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.attributedTitle = .init(text, attributes: .init([
            .font: UIFont.appFont(withSize: 14, weight: .semibold),
            .foregroundColor: UIColor.background2
        ]))
        config.baseForegroundColor = .background2
        config.baseBackgroundColor = .foreground
        return config
    }
    
    static func capsule14Grey(_ text: String) -> UIButton.Configuration {
        capsuleBackground3(text: text, font: UIFont.appFont(withSize: 14, weight: .semibold))
    }
}

class ExploreNoteFeedPreviewController: NoteFeedPreviewController {
    override var contentInset: UIEdgeInsets { .init(top: 106, left: 0, bottom: 60, right: 0) }
    override var disableInteraction: Bool { false }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        view.backgroundColor = .clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        table.backgroundColor = .background
    }
}

class ExploreArticleFeedPreviewFeedController: ArticleFeedPreviewFeedController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        table.contentInsetAdjustmentBehavior = .never
        table.contentInset = .init(top: 106, left: 0, bottom: 60, right: 0)
    }
    
    override func updateTheme() {
        super.updateTheme()
        
        table.backgroundColor = .background
    }
}

final class ExploreFeedPreviewParentController: UIViewController, Themeable {
    var cancellables: Set<AnyCancellable> = []
    
    let feed: PrimalFeed
    let type: PrimalFeedType
    let info: ParsedFeedFromMarket
    
    let addButton = UIButton()
    
    init(feed: PrimalFeed, type: PrimalFeedType, feedInfo: ParsedFeedFromMarket) {
        self.feed = feed
        self.type = type
        info = feedInfo
        super.init(nibName: nil, bundle: nil)
        setup()
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateButton()
    }
    
    func updateTheme() {
        navigationItem.leftBarButtonItem = customBackButton
        updateButton()
    }
}

private extension ExploreFeedPreviewParentController {
    func setup() {
        view.backgroundColor = .background
        let addParent = UIView()
        addParent.addSubview(addButton)
        addButton.pinToSuperview(edges: [.trailing]).centerToSuperview(axis: .vertical).constrainToSize(height: 36)
        [addButton.leadingAnchor.constraint(equalTo: addParent.leadingAnchor), addButton.bottomAnchor.constraint(equalTo: addParent.bottomAnchor)]
            .forEach { c in
                c.priority = .defaultHigh
                c.isActive = true
            }
        
        navigationItem.rightBarButtonItem = .init(customView: addParent)
        
        let previewFeed: UIViewController
        switch type {
        case .article:
            previewFeed = ExploreArticleFeedPreviewFeedController(feed: feed, feedInfo: info)
        case .note:
            previewFeed = ExploreNoteFeedPreviewController(feed: feed, feedInfo: info)
        }
        previewFeed.willMove(toParent: self)
                
        view.addSubview(previewFeed.view)
        previewFeed.view.pinToSuperview()
        
        addChild(previewFeed)
        previewFeed.didMove(toParent: self)
        
        addButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            
            var all = PrimalFeed.getAllFeeds(type)
            
            if let existingFeedIndex = all.firstIndex(where: { $0.spec == self.feed.spec }) {
                if all[existingFeedIndex].isFromBackend {
                    all[existingFeedIndex].enabled.toggle()
                } else {
                    all.remove(at: existingFeedIndex)
                }
            } else {
                all.append(feed)
            }
            
            PrimalFeed.setAllFeeds(all, type: type, notifyBackend: true)
            updateButton()
        }), for: .touchUpInside)
        updateButton()
    }
    
    func updateButton() {
        let name = type == .article ? "reads" : "home"
        let allFeeds = PrimalFeed.getAllFeeds(type)
        if let index = allFeeds.firstIndex(where: { $0.spec == feed.spec }) {
            addButton.configuration = allFeeds[index].isFromBackend && !allFeeds[index].enabled ?
                .capsule14BlackWhite("Add to \(name) feeds") :
                .capsule14Grey("Remove from \(name) feeds")
        } else {
            addButton.configuration = .capsule14BlackWhite("Add to \(name) feeds")
        }
    }
}
