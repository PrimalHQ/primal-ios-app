//
//  SaveFeedController.swift
//  Primal
//
//  Created by Pavle Stevanović on 17.10.24..
//

import UIKit

class SaveFeedController: UIViewController {
    let feedType: PrimalFeedType
    let feed: PrimalFeed
    
    lazy var nameInput = inputView(feed.name)
    lazy var descInput = inputView(feed.description)
    
    let callback: () -> ()
    
    init(feedType: PrimalFeedType, feed: PrimalFeed, callback: @escaping () -> ()) {
        self.feedType = feedType
        self.feed = feed
        self.callback = callback
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = Theme.current.userInterfaceStyle
        
        if let sheetPresentationController {
            sheetPresentationController.detents = [
                .custom(resolver: { context in
                    return 355
                }),
            ]
        }
        
        view.backgroundColor = .background4
                
        let pullBar = UIView().constrainToSize(width: 60, height: 5)
        pullBar.backgroundColor = .foreground
        pullBar.layer.cornerRadius = 2.5
        
        let titleLabel = UILabel()
        titleLabel.font = .appFont(withSize: 20, weight: .bold)
        switch feedType {
        case .note:     titleLabel.text = "Save to Home Feeds"
        case .article:  titleLabel.text = "Save to Reads Feeds"
        }
        titleLabel.textColor = .foreground2
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        
        let saveButton = UIButton.largeRoundedButton(title: "Save")
        
        let subStack = UIStackView(axis: .vertical, [
            subtitleLabel("Feed name:"), SpacerView(height: 12, priority: .required),
            nameInput, SpacerView(height: 24),
            subtitleLabel("Feed description:"), SpacerView(height: 12, priority: .required),
            descInput, SpacerView(height: 36, priority: .required),
            SpacerView(height: 0, priority: .defaultLow), saveButton
        ])
        
        let stack = UIStackView(axis: .vertical, [
            pullBar, SpacerView(height: 20, priority: .required),
            titleLabel, SpacerView(height: 26, priority: .required),
            subStack
        ])
        stack.alignment = .center
        subStack.pinToSuperview(edges: .horizontal)
        
        view.addSubview(stack)
        stack
            .pinToSuperview(edges: .horizontal, padding: 20)
            .pinToSuperview(edges: .top, padding: 12)
        stack.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -20).isActive = true
        
        if let backButton = customBackButton.customView {
            view.addSubview(backButton)
            backButton.pin(to: stack, edges: .leading).centerToView(titleLabel, axis: .vertical)
        }
        
        saveButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            var newFeed = feed
            newFeed.name = nameInput.text ?? newFeed.name
            newFeed.description = descInput.text ?? newFeed.description
            var feeds = PrimalFeed.getAllFeeds(feedType)
            feeds.append(newFeed)
            PrimalFeed.setAllFeeds(feeds, type: feedType, notifyBackend: true)
            
            dismiss(animated: true) {
                self.callback()
                
                RootViewController.instance.showToast("Saved to \(self.feedType.name) feeds")
            }
        }), for: .touchUpInside)
    }
    
    func subtitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.font = .appFont(withSize: 16, weight: .regular)
        label.text = text
        label.textColor = .foreground2
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }
    
    func inputView(_ text: String) -> UITextField {
        let field = UITextField()
        field.font = .appFont(withSize: 16, weight: .regular)
        field.text = text
        field.textColor = .foreground
        field.backgroundColor = .background3
        field.layer.cornerRadius = 18
        field.leftView = UIView().constrainToSize(width: 16)
        field.leftViewMode = .always
        field.clearButtonMode = .always
        return field.constrainToSize(height: 36)
    }
}
