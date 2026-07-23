//
//  ExploreViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 16.5.23..
//

import UIKit

final class ExploreViewController: UIViewController, Themeable, TitleSwipeController, SearchBarButtonController {
    let primalNavigationBar = PrimalNavigationBar()
    let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)

    let searchBarButton = SearchBarButton()
    let separator = SpacerView(height: 1)

    let postButtonParent = UIView()
    let postButton = NewPostButton()

    private var currentCategory: ExploreCategory = .people

    private var cachedTabVCs: [ExploreCategory: UIViewController] = [:]

    private func categoryVC(_ category: ExploreCategory) -> UIViewController {
        if let cached = cachedTabVCs[category] { return cached }
        let new: UIViewController
        switch category {
        case .people: new = ExplorePeopleViewController()
        case .feeds:  new = ExploreFeedsViewController()
        case .followPacks: new = ExploreFollowPacksViewController()
        case .zaps:   new = ExploreZapsViewController()
        case .media:  new = ExploreMediaController()
        }
        cachedTabVCs[category] = new
        return new
    }

    private func category(of vc: UIViewController) -> ExploreCategory? {
        cachedTabVCs.first(where: { $0.value === vc })?.key
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)
        mainTabBarController?.setTabBarHidden(false, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // In viewDidAppear because on tab revisits viewWillAppear fires before this controller is re-attached to the tab bar controller
        mainTabBarController?.showExploreHintIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        mainTabBarController?.hideExploreHint()
    }

    func updateTheme() {
        view.backgroundColor = .background

        primalNavigationBar.updateTheme()
        searchBarButton.updateTheme()
        separator.backgroundColor = .background3

        cachedTabVCs.values.forEach {
            ($0 as? Themeable)?.updateTheme()
            let views: [Themeable] = $0.view.findAllSubviews()
            for view in views { view.updateTheme() }
        }
    }

    func titleSubtitleToLeftOfCurrent() -> (title: String, subtitle: String)? {
        guard let prev = ExploreCategory(rawValue: currentCategory.rawValue - 1) else { return nil }
        return (prev.selectionTitle, prev.selectionSubtitle ?? "")
    }

    func titleSubtitleToRightOfCurrent() -> (title: String, subtitle: String)? {
        guard let next = ExploreCategory(rawValue: currentCategory.rawValue + 1) else { return nil }
        return (next.selectionTitle, next.selectionSubtitle ?? "")
    }
}

extension ExploreViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard
            let current = category(of: viewController),
            let prev = ExploreCategory(rawValue: current.rawValue - 1)
        else { return nil }
        return categoryVC(prev)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard
            let current = category(of: viewController),
            let next = ExploreCategory(rawValue: current.rawValue + 1)
        else { return nil }
        return categoryVC(next)
    }
}

extension ExploreViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else {
            primalNavigationBar.cancelTransition()
            return
        }

        guard let finishedVC = pageViewController.viewControllers?.first, let newCategory = category(of: finishedVC) else { return }
        currentCategory = newCategory
        primalNavigationBar.completeTransition(newTitle: newCategory.selectionTitle, newSubtitle: newCategory.selectionSubtitle ?? "")
    }
}

private extension ExploreViewController {
    func setup() {
        updateTheme()

        pageVC.willMove(toParent: self)
        view.addSubview(pageVC.view)
        pageVC.view.pinToSuperview(edges: [.horizontal, .bottom])
        addChild(pageVC)
        pageVC.didMove(toParent: self)

        pageVC.dataSource = self
        pageVC.delegate = self
        pageVC.setViewControllers([categoryVC(currentCategory)], direction: .forward, animated: false)

        view.addGestureRecognizer(TitleSwipeGesture(vc: self))

        addNavigationBar()
        primalNavigationBar.title = currentCategory.selectionTitle
        primalNavigationBar.subtitle = currentCategory.selectionSubtitle ?? ""
        primalNavigationBar.showChevron = true
        primalNavigationBar.showBorder = false
        primalNavigationBar.onAvatarTapped = { [weak self] in
            guard let self else { return }
            MenuController().present(from: self)
        }
        primalNavigationBar.onTitleTapped = { [weak self] in
            guard let self else { return }
            GenericSelectionController(
                items: ExploreCategory.allCases,
                selectedItem: currentCategory
            ) { [weak self] cat in
                self?.setCategory(cat)
            }.present(from: self)
        }

        view.addSubview(searchBarButton)
        searchBarButton.topAnchor.constraint(equalTo: primalNavigationBar.bottomAnchor, constant: 8).isActive = true
        searchBarButton.pinToSuperview(edges: .horizontal, padding: 16)

        view.addSubview(separator)
        separator.topAnchor.constraint(equalTo: searchBarButton.bottomAnchor, constant: 12).isActive = true
        separator.pinToSuperview(edges: .horizontal)

        pageVC.view.topAnchor.constraint(equalTo: separator.bottomAnchor).isActive = true

        setupSearchBarActions()

        postButton.addAction(.init(handler: { [weak self] _ in
            self?.present(AdvancedEmbedPostViewController(), animated: true)
        }), for: .touchUpInside)
        view.addSubview(postButtonParent)
        postButtonParent.addSubview(postButton)
        postButton.constrainToSize(56).pinToSuperview(padding: 8)
        postButtonParent.pinToSuperview(edges: .trailing, padding: 13).pinToSuperview(edges: .bottom, padding: 48, safeArea: true)
    }

    func setCategory(_ category: ExploreCategory) {
        guard category != currentCategory else { return }
        pageVC.setViewControllers([categoryVC(category)], direction: .forward, animated: false)
        currentCategory = category
        primalNavigationBar.completeTransition(newTitle: category.selectionTitle, newSubtitle: category.selectionSubtitle ?? "")
    }
}
