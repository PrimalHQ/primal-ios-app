//
//  MessagesViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 25.9.24..
//

import Combine
import UIKit

final class MessagesViewController: UIViewController, Themeable {
    
    @Published var selectedType: ChatManager.Relation = .follows
    
    private let manager = ChatManager()
    
    private let followsButton = UIButton()
    private let otherButton = UIButton()
    private let markAllRead = UIButton()
    private let selectionIndicator = UIView()
    
    private let loadingSpinner = LoadingSpinnerView()
    
    private let newChatButton = UIButton()
    
    private let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    
    var cancellables: Set<AnyCancellable> = []
    
    private lazy var followsVC = ChatListViewController(selectedType: .follows, manager: manager)
    private lazy var othersVC = ChatListViewController(selectedType: .other, manager: manager)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Messages"
        
        setup()
        
        switchTo(selectedType, animated: true)
        
        $selectedType.dropFirst().receive(on: DispatchQueue.main).sink { [weak self] relation in
            guard let self else { return }
                     
            updateButtonFonts()
            selectionIndicator.removeFromSuperview()
            view.addSubview(self.selectionIndicator)
                
            selectionIndicator.pin(to: relation == .follows ? self.followsButton : self.otherButton, edges: [.horizontal, .bottom]).constrainToSize(height: 4)
                
            if view.window != nil {
                UIView.animate(withDuration: 0.2) {
                    self.view.layoutIfNeeded()
                }
            }
        }
        .store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        mainTabBarController?.setTabBarHidden(false, animated: animated)
    }
    
    func updateTheme() {
        view.backgroundColor = .background
        
        navigationItem.leftBarButtonItem = customBackButton
        
        updateButtonFonts()
        
        selectionIndicator.backgroundColor = .accent
        
        followsButton.setTitleColor(.foreground, for: .normal)
        otherButton.setTitleColor(.foreground, for: .normal)
        markAllRead.setTitleColor(.accent, for: .normal)
        
        newChatButton.backgroundColor = .accent
        
        followsVC.updateTheme()
        othersVC.updateTheme()
    }
    
    func updateButtonFonts() {
        followsButton.titleLabel?.font = .appFont(withSize: 14, weight: selectedType == .follows ? .bold : .regular)
        otherButton.titleLabel?.font = .appFont(withSize: 14, weight: selectedType == .other ? .bold : .regular)
    }
    
    func switchTo(_ relation: ChatManager.Relation, animated: Bool) {
        switch relation {
        case .follows:
            pageVC.setViewControllers([followsVC], direction: .reverse, animated: animated)
        case .other:
            pageVC.setViewControllers([othersVC], direction: .forward, animated: animated)
        }
        
        selectedType = relation
    }
}

private extension MessagesViewController {
    func setup() {
        updateTheme()
        
        let hstack = UIStackView([SpacerView(width: 12), followsButton, SpacerView(width: 32), otherButton, UIView(), markAllRead, SpacerView(width: 12)])
        let vStack = UIStackView(axis: .vertical, [
            hstack.constrainToSize(height: 46),
            SpacerView(height: 4),
            ThemeableView().constrainToSize(height: 1).setTheme { $0.backgroundColor = .background3 },
            pageVC.view
        ])
        
        pageVC.willMove(toParent: self)
        addChild(pageVC)
        
        view.addSubview(vStack)
        vStack.pinToSuperview(edges: [.horizontal, .bottom]).pinToSuperview(edges: .top, safeArea: true)
        
        pageVC.didMove(toParent: self)
        pageVC.dataSource = self
        pageVC.delegate = self
        
        view.addSubview(selectionIndicator)
        selectionIndicator.pin(to: followsButton, edges: [.horizontal, .bottom]).constrainToSize(height: 4)
        selectionIndicator.layer.cornerRadius = 2
        
        followsButton.setTitle("FOLLOWS", for: .normal)
        otherButton.setTitle("OTHER", for: .normal)
        markAllRead.setTitle("Mark All Read", for: .normal)
        
        markAllRead.titleLabel?.font = .appFont(withSize: 14, weight: .regular)
        
        view.addSubview(newChatButton)
        newChatButton.pinToSuperview(edges: .trailing, padding: 8).pinToSuperview(edges: .bottom, padding: 64, safeArea: true).constrainToSize(56)
        newChatButton.setImage(UIImage(named: "newChat"), for: .normal)
        newChatButton.layer.cornerRadius = 28
        
        view.addSubview(loadingSpinner)
        loadingSpinner.centerToSuperview().constrainToSize(70)
        loadingSpinner.isHidden = true
        loadingSpinner.play()
        
        newChatButton.addAction(.init(handler: { [weak self] _ in
            self?.show(ChatSearchController(manager: self!.manager), sender: nil)
        }), for: .touchUpInside)
        
        otherButton.addAction(.init(handler: { [weak self] _ in
            self?.switchTo(.other, animated: true)
        }), for: .touchUpInside)
        
        followsButton.addAction(.init(handler: { [weak self] _ in
            self?.switchTo(.follows, animated: true)
        }), for: .touchUpInside)
        
        markAllRead.addAction(.init(handler: { [weak self] _ in
            self?.manager.markAllChatsAsRead()
        }), for: .touchUpInside)
        
        manager.updateChatCount()
    }
}

extension MessagesViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController == followsVC {
            return nil
        }
        return followsVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController == othersVC {
            return nil
        }
        return othersVC
    }
}

extension MessagesViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        selectedType = pageViewController.viewControllers?.first == followsVC ? .follows : .other
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        selectedType = pendingViewControllers.first == followsVC ? .follows : .other
    }
}
