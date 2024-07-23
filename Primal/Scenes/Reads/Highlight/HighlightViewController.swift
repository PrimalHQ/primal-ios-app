//
//  HighlightViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 18.7.24..
//

import Combine
import UIKit

extension UIButton.Configuration {
    static func highlightActionButton(icon: UIImage?, title: String) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.image = icon?.withTintColor(.foreground, renderingMode: .alwaysOriginal)
        config.imagePlacement = .top
        config.imagePadding = 8
        
        config.titleAlignment = .center
        
        config.background.backgroundColor = Theme.current.isDarkTheme ? .init(rgb: 0x282828) : .white
        config.background.cornerRadius = 8

        config.attributedTitle = .init(title, attributes: .init([
            .font: UIFont.appFont(withSize: 15, weight: .medium),
            .foregroundColor: UIColor.foreground
        ]))
        
        return config
    }
}

protocol HighlightViewControllerDelegate: AnyObject {
    func highlightControllerDidHighlight(_ controller: HighlightViewController, highlight: Highlight)
    func highlightControllerDidRemoveHighlight(_ controller: HighlightViewController, highlight: Highlight)
}

class HighlightViewController: UIViewController {
    
    let article: Article
    
    var highlights: [Highlight] {
        didSet {
            usersView.users = highlights.map { $0.user }
            usersView.isHidden = highlights.isEmpty
            
            (presentationController as? UISheetPresentationController)?.invalidateDetents()
        }
    }
    
    var content: String
    
    lazy var highlightToggleButton = UIButton(configuration:
        isHighlighted ?
            .highlightActionButton(icon: UIImage(named: "removeHighlightIcon24"), title: "Remove") :
            .highlightActionButton(icon: UIImage(named: "highlightIcon24"), title: "Highlight")
    )
    
    lazy var usersView = HighlightUsersView(users: highlights.map { $0.user })
    
    var isHighlighted: Bool {
        didSet {
            highlightToggleButton.configuration = isHighlighted ?
                .highlightActionButton(icon: UIImage(named: "removeHighlightIcon24"), title: "Remove") :
                .highlightActionButton(icon: UIImage(named: "highlightIcon24"), title: "Highlight")
        }
    }
    
    weak var delegate: HighlightViewControllerDelegate?
    
    init(article: Article, highlights: [Highlight]) {
        self.article = article
        self.highlights = highlights
        self.content = highlights.first?.content ?? ""
        
        isHighlighted = highlights.contains(where: { $0.user.isCurrentUser })
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension HighlightViewController {
    func setup() {
        view.backgroundColor = .background4
        if let pc = presentationController as? UISheetPresentationController {
            pc.detents = [
                .custom(resolver: { [weak self] _ in
                    guard let self else { return 295 }
                    
                    let base: CGFloat = highlights.isEmpty ? 215 : 295
                    
                    return base
                })
            ]
        }
        
        let pullBarParent = UIView()
        let pullBar = UIView()
        pullBarParent.addSubview(pullBar)
        pullBar.centerToSuperview().pinToSuperview(edges: .vertical).constrainToSize(width: 60, height: 5)
        pullBar.backgroundColor = .foreground
        pullBar.layer.cornerRadius = 2.5
        
        let title = UILabel()
        title.text = "Highlight Activity"
        title.textAlignment = .center
        title.font = .appFont(withSize: 20, weight: .bold)
        title.textColor = .foreground
        
        let buttonStack = UIStackView([
            UIButton(configuration: .highlightActionButton(icon: UIImage(named: "commentIcon24"), title: "Quote"), primaryAction: .init(handler: { [weak self] _ in
                guard let self, let highlight = highlights.first else { return }
                
                present(NewHighlightPostViewController(article: article, highlight: highlight), animated: true)
            })),
            UIButton(configuration: .highlightActionButton(icon: UIImage(named: "quoteIcon24"), title: "Comment"), primaryAction: .init(handler: { [weak self] _ in
                guard let self, let hightlight = highlights.first else { return }
                
                present(NewPostViewController(
                    replyToPost: .init(nostrPost: hightlight.event, nostrPostStats: .empty("")), onPost: {
                        // TODO: REFRESH COMMENTS
                    }),
                    animated: true
                )
            })),
            highlightToggleButton
        ])
        buttonStack.constrainToSize(height: 80)
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        buttonStack.isLayoutMarginsRelativeArrangement = true
        buttonStack.layoutMargins = .init(top: 0, left: 20, bottom: 0, right: 20)
        
        let stack = UIStackView(axis: .vertical, [
            pullBarParent, SpacerView(height: 20),
            title, SpacerView(height: 24),
            BorderView(), usersView, BorderView(),
            // Here goes table view with comments
            SpacerView(height: 24, priority: .init(rawValue: 1)),
            buttonStack
        ])
        view.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, padding: 12).pinToSuperview(edges: .bottom, padding: 52)
        
        highlightToggleButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            
            if isHighlighted {
                let myHighlights = highlights.filter({ $0.user.isCurrentUser })
                
                guard !myHighlights.isEmpty else {
                    isHighlighted = false
                    return
                }
                
                highlightToggleButton.isEnabled = false
                PostingManager.instance.deleteHighlightEvents(myHighlights) { [weak self] success in
                    guard let self else { return }
                    
                    highlightToggleButton.isEnabled = true
                    if success {
                        for highlight in myHighlights {
                            delegate?.highlightControllerDidRemoveHighlight(self, highlight: highlight)
                            highlights.removeAll(where: { $0.event.id == highlight.event.id })
                        }
                        isHighlighted = highlights.contains(where: { $0.user.isCurrentUser })
                        if highlights.isEmpty {
                            dismiss(animated: true)
                        }
                    }
                }
                return
            } else {
                guard !content.isEmpty else { return }
                
                highlightToggleButton.isEnabled = false
                var event: NostrObject?
                event = PostingManager.instance.sendHighlightEvent(content, article: article) {  [weak self] success in
                    guard let self else { return }
                    
                    highlightToggleButton.isEnabled = true
                    isHighlighted = success
                    if success {
                        guard let user = IdentityManager.instance.parsedUser else { return }

                        let highlight = Highlight(user: user, event: NostrContent(
                            kind: Int32(NostrKind.highlight.rawValue),
                            content: event?.content ?? content,
                            id: event?.id ?? "",
                            created_at: Double(event?.created_at ?? Int64(Date().timeIntervalSince1970)),
                            pubkey: event?.pubkey ?? IdentityManager.instance.userHexPubkey,
                            sig: event?.sig ?? "",
                            tags: event?.tags ?? [])
                        )
                        
                        delegate?.highlightControllerDidHighlight(self, highlight: highlight)
                        highlights.insert(highlight, at: 0)
                    }
                }
            }
        }), for: .touchUpInside)
    }
}
