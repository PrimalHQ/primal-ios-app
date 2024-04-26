//
//  NoteReactionsParentController.swift
//  Primal
//
//  Created by Pavle Stevanović on 18.4.24..
//

import UIKit
import Combine

class NoteReactionsParentController: UIViewController, Themeable {
    enum Tab: Int {
        case zaps = 0
        case likes = 1
        case reposts = 2
    }
    
    private let tabSelectionView = TabSelectionView(tabs: ["ZAPS", "LIKES", "REPOSTS"])
    private let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private var updatePage = true
    
    private let noteId: String
    private lazy var zapsVC = NoteZapsViewController(noteId: noteId)
    private lazy var likesVC = NoteLikesViewController(noteId: noteId)
    private lazy var repostsVC = NoteRepostsViewController(noteId: noteId)
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(_ startingTab: Tab, noteId: String) {
        self.noteId = noteId
        super.init(nibName: nil, bundle: nil)
        tabSelectionView.set(tab: startingTab.rawValue)
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    func updateTheme() {
        view.backgroundColor = .background
     
        navigationItem.leftBarButtonItem = customBackButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        mainTabBarController?.setTabBarHidden(false, animated: animated)
    }
}

private extension NoteReactionsParentController {
    func setup() {
        updateTheme()
        title = "Note Reactions"
        
        let stack = UIStackView(axis: .vertical, [tabSelectionView, pageVC.view])
        
        addChild(pageVC)
        view.addSubview(stack)
        stack.pinToSuperview(edges: .top, safeArea: true).pinToSuperview(edges: .horizontal).pinToSuperview(edges: .bottom, padding: 56, safeArea: true)
        pageVC.didMove(toParent: self)
        
        pageVC.dataSource = self
        pageVC.delegate = self
        
        // Blocker is just to make the edge slidable
        let blockerView = UIView()
        view.addSubview(blockerView)
        blockerView.pinToSuperview(edges: [.leading, .vertical]).constrainToSize(width: 20)
        
        tabSelectionView.$selectedTab.compactMap({ Tab(rawValue: $0) })
            .sink(receiveValue: { [weak self] tab in
                guard let self, self.updatePage else { return }
                
                switch tab {
                case .zaps:
                    pageVC.setViewControllers([zapsVC], direction: .reverse, animated: false)
                case .likes:
                    pageVC.setViewControllers([likesVC], direction: .forward , animated: false)
                case .reposts:
                    pageVC.setViewControllers([repostsVC], direction: .forward, animated: false)
                }
            })
            .store(in: &cancellables)
    }
}

extension NoteReactionsParentController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        switch viewController {
        case zapsVC:    return nil
        case likesVC:   return zapsVC
        case repostsVC: return likesVC
        default:        return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        switch viewController {
        case zapsVC:    return likesVC
        case likesVC:   return repostsVC
        case repostsVC: return nil
        default:        return nil
        }
    }
}

extension NoteReactionsParentController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else { return }
        
        updatePage = false
        tabSelectionView.set(tab: {
            switch pageViewController.viewControllers?.first {
            case zapsVC:    return 0
            case likesVC:   return 1
            case repostsVC: return 2
            default:        return 0
            }
        }())
        updatePage = true
    }
}
