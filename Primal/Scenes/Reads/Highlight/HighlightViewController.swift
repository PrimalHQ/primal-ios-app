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
    func highlightControllerDidAddComment(_ controller: HighlightViewController)
}

class HighlightViewController: UIViewController {
    
    let article: Article
    
    var highlights: [Highlight] {
        didSet {
            usersView.users = highlights.map { $0.user }
            usersView.isHidden = highlights.isEmpty
        }
    }
    
    var comments: [ParsedContent] {
        didSet {
            commentsVC.posts = comments
        }
    }
    
    var content: String
    
    lazy var highlightToggleButton = UIButton(configuration:
        isHighlighted ?
            .highlightActionButton(icon: UIImage(named: "removeHighlightIcon24"), title: "Remove") :
            .highlightActionButton(icon: UIImage(named: "highlightIcon24"), title: "Highlight")
    )
    
    lazy var usersView = HighlightUsersView(users: highlights.map { $0.user })
    let commentsVC: HighlightCommentsController
    
    var isHighlighted: Bool {
        didSet {
            highlightToggleButton.configuration = isHighlighted ?
                .highlightActionButton(icon: UIImage(named: "removeHighlightIcon24"), title: "Remove") :
                .highlightActionButton(icon: UIImage(named: "highlightIcon24"), title: "Highlight")
        }
    }
    
    weak var delegate: HighlightViewControllerDelegate?
    
    var cancellables: Set<AnyCancellable> = []
    
    init(article: Article, highlights: [Highlight], comments: [ParsedContent]) {
        self.article = article
        self.highlights = highlights
        self.content = highlights.first?.content ?? ""
        self.comments = comments
        commentsVC = .init(comments: comments)
        
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
                    
                    let base: CGFloat = highlights.isEmpty ? 215 : 275
                    
                    return base + commentsVC.viewHeight
                })
            ]
        }
        
        commentsVC.$viewHeight.debounce(for: 0.1, scheduler: DispatchQueue.main).sink { [weak self] _ in
            let sheet = self?.presentationController as? UISheetPresentationController
            sheet?.animateChanges {
                sheet?.invalidateDetents()
            }
        }
        .store(in: &cancellables)
        
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
            UIButton(configuration: .highlightActionButton(icon: UIImage(named: "quoteIcon24"), title: "Quote"), primaryAction: .init(handler: { [weak self] _ in
                guard let self, let highlight = highlights.first else { return }
                
                present(AdvancedEmbedPostViewController(including: .highlight(article, highlight), onPost: { [weak self] in
                    self?.dismiss(animated: true)
                }), animated: true)
            })),
            UIButton(configuration: .highlightActionButton(icon: UIImage(named: "commentIcon24"), title: "Comment"), primaryAction: .init(handler: { [weak self] _ in
                guard let self, let hightlight = highlights.first else { return }
                
                present(NewPostViewController(
                    replyToPost: .init(nostrPost: hightlight.event, nostrPostStats: .empty("")), onPost: { [weak self] in
                        guard let self else { return }
                        delegate?.highlightControllerDidAddComment(self)
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
            commentsVC.view,
            SpacerView(height: 24, priority: .init(rawValue: 1)),
            buttonStack
        ])
        
        commentsVC.willMove(toParent: self)
        addChild(commentsVC)
        
        view.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, padding: 12).pinToSuperview(edges: .bottom, padding: 52)
        
        commentsVC.didMove(toParent: self)
        
        highlightToggleButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            
            if isHighlighted {
                isHighlighted = false
                
                let myHighlights = highlights.filter({ $0.user.isCurrentUser })
                guard !myHighlights.isEmpty else { return }
                
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
                    } else {
                        isHighlighted = true
                    }
                }
                return
            } else {
                guard !content.isEmpty else { return }
                
                isHighlighted = true
                
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
