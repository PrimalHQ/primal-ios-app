//
//  FeedsSelectionController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 4.5.23..
//

import UIKit
import Kingfisher

final class FeedsSelectionController: UIViewController {
    let feed: FeedManager
    
    init(feed: FeedManager) {
        self.feed = feed
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension FeedsSelectionController {
    @objc func feedButtonPressed(_ button: UIButton) {
        dismiss(animated: true)
        
        guard let feed = IdentityManager.instance.userSettings?.content.feeds?[safe: button.tag] else { return }
        
        KingfisherManager.shared.cache.clearMemoryCache()
        
        Connection.dispatchQueue.async {
            self.feed.setCurrentFeed(feed)
        }
    }
    
    func setup() {
        view.backgroundColor = .background2
        if let pc = presentationController as? UISheetPresentationController {
            if #available(iOS 16.0, *) {
                pc.detents = [.custom(resolver: { context in
                    guard let count = IdentityManager.instance.userSettings?.content.feeds?.count else { return 700 }
                    
                    return 100 + CGFloat(count) * 66
                })]
            } else {
                pc.detents = [.large()]
            }
        }
        
        let pullBar = UIView()
        let title = UILabel()
        let titleStack = UIStackView(arrangedSubviews: [UIImageView(image: UIImage(named: "ostrich")), title])
        
        var buttons: [UIButton] = []
        let settings = IdentityManager.instance.userSettings?.content.feeds ?? []
        for (index, feed) in settings.enumerated() {
            let button = UIButton()
            button.setTitle(feed.name, for: .normal)
            button.setTitleColor(.foreground, for: .normal)
            button.titleLabel?.font = .appFont(withSize: 20, weight: .regular)
            button.addTarget(self, action: #selector(feedButtonPressed), for: .touchUpInside)
            button.tag = index
            
            buttons.append(button)
        }
        
        let scrollView = UIScrollView(frame: .zero)
        let buttonStack = UIStackView(arrangedSubviews: buttons)
        
        scrollView.addSubview(buttonStack)
        buttonStack.pinToSuperview()
        buttonStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        let scrollHeight = scrollView.heightAnchor.constraint(equalToConstant: CGFloat(settings.count) * 66)
        scrollHeight.priority = .defaultHigh
        scrollHeight.isActive = true
        
        scrollView.showsVerticalScrollIndicator = false
        
//        let border = GradientView(colors: [.clear, .white, .clear])
//        border.gradientLayer.startPoint = .init(x: 0, y: 0.5)
//        border.gradientLayer.endPoint = .init(x: 1, y: 0.5)
//
        let stack = UIStackView(arrangedSubviews: [pullBar, SpacerView(height: 42), scrollView, SpacerView(height: 42)])
        
        view.addSubview(stack)
        stack.pinToSuperview(edges: .vertical, padding: 16, safeArea: true).pinToSuperview(edges: .horizontal, padding: 32)
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.setCustomSpacing(10, after: titleStack)
        
        titleStack.spacing = 10
        
        buttonStack.axis = .vertical
        buttonStack.spacing = 30
        buttonStack.alignment = .center
        
        pullBar.constrainToSize(width: 60, height: 5)
        pullBar.backgroundColor = .foreground.withAlphaComponent(0.8)
        pullBar.layer.cornerRadius = 2.5
        
        title.text = "My Nostr Feeds"
        title.font = .appFont(withSize: 32, weight: .semibold)
        title.textColor = .foreground
        
//        border
//            .constrainToSize(height: 1)
//            .widthAnchor.constraint(equalTo: titleStack.widthAnchor, multiplier: 1.2).isActive = true
    }
}
