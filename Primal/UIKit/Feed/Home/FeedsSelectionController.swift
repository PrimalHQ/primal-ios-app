//
//  FeedsSelectionController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 4.5.23..
//

import UIKit

class FeedsSelectionController: UIViewController {
    let feed: Feed
    init(feed: Feed) {
        self.feed = feed
        super.init(nibName: nil, bundle: nil)
        setup()
        
//        self.feed.requestUserContacts {
//            let miljanHex = "d61f3bc5b3eb4400efdae6169a5c17cabf3246b514361de939ce4a1a0da6ef4a"
//            self.feed.sendFollowEvent(miljanHex)
//            self.feed.sendUnfollowEvent(miljanHex)
//        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension FeedsSelectionController {
    @objc func feedButtonPressed(_ button: UIButton) {
        guard let title = button.title(for: .normal), !title.isEmpty else { return }
        feed.setCurrentFeed(title)
        dismiss(animated: true)
    }
    
    func setup() {
        view.backgroundColor = UIColor(rgb: 0x1C1C1E)
        if let pc = presentationController as? UISheetPresentationController {
            if #available(iOS 16.0, *) {
                pc.detents = [.custom(resolver: { [weak self] context in
                    guard let count = self?.feed.currentUserSettings?.content.feeds.count else { return 700 }
                    
                    return 200 + CGFloat(count) * 66
                })]
            } else {
                pc.detents = [.large()]
            }
        }
        
        let pullBar = UIView()
        let title = UILabel()
        
        var buttons: [UIButton] = []
        for settings in (feed.currentUserSettings?.content.feeds ?? []) {
            let button = UIButton()
            button.setTitle(settings.name, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = .appFont(withSize: 20, weight: .regular)
            button.addTarget(self, action: #selector(feedButtonPressed), for: .touchUpInside)
            
            buttons.append(button)
        }
        
        let buttonStack = UIStackView(arrangedSubviews: buttons)
        let stack = UIStackView(arrangedSubviews: [pullBar, SpacerView(size: 42), title, SpacerView(size: 42), buttonStack, SpacerView(size: 42)])
        
        view.addSubview(stack)
        stack.pinToSuperview(edges: .vertical, padding: 16, safeArea: true).pinToSuperview(edges: .horizontal, padding: 32)
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.alignment = .center
        
        buttonStack.axis = .vertical
        buttonStack.spacing = 30
        buttonStack.alignment = .center
        
        pullBar.constrainToSize(width: 60, height: 5)
        pullBar.backgroundColor = .white
        pullBar.layer.cornerRadius = 2.5
        
        title.text = "My Nostr Feeds"
        title.font = .appFont(withSize: 32, weight: .semibold)
        title.textColor = .white
    }
}
