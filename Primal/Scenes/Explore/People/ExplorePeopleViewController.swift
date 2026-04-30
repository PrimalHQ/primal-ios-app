//
//  ExplorePeopleViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 29.4.26..
//

import Combine
import UIKit

final class ExplorePeopleViewController: UIViewController, Themeable {

    private static let userColumns = 4
    private static let userRows = 3
    private static var maxUsers: Int { userColumns * userRows }
    private static let maxSearches = 5

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let recentUsersHeader = UILabel()
    private let usersGridStack = UIStackView()
    private var userViews: [RecentUserView] = []

    private let recentSearchesHeader = UILabel()
    private let searchesStack = UIStackView()
    private let searchesSection = UIStackView()
    private var searchRows: [RecentSearchRowView] = []

    private var cancellables: Set<AnyCancellable> = []

    private var users: [ParsedUser] = [] {
        didSet { applyUsers() }
    }

    private var searches: [String] = [] {
        didSet { applySearches() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
    }

    func updateTheme() {
        view.backgroundColor = .background
        scrollView.backgroundColor = .background
        recentUsersHeader.textColor = .foreground
        recentSearchesHeader.textColor = .foreground
        userViews.forEach { $0.updateTheme() }
        searchRows.forEach { $0.updateTheme() }
    }
}

private extension ExplorePeopleViewController {
    func setup() {
        recentUsersHeader.text = "Recent Users"
        recentUsersHeader.font = .appFont(withSize: 16, weight: .semibold)

        recentSearchesHeader.text = "Recent Searches"
        recentSearchesHeader.font = .appFont(withSize: 16, weight: .semibold)

        let usersHeaderRow = wrapWithHorizontalPadding(recentUsersHeader, padding: 16)
        let searchesHeaderRow = wrapWithHorizontalPadding(recentSearchesHeader, padding: 16)

        buildUsersGrid()
        buildSearchesStack()

        searchesSection.axis = .vertical
        searchesSection.spacing = 0
        searchesSection.alignment = .fill
        searchesSection.addArrangedSubview(SpacerView(height: 24))
        searchesSection.addArrangedSubview(searchesHeaderRow)
        searchesSection.addArrangedSubview(SpacerView(height: 8))
        searchesSection.addArrangedSubview(searchesStack)

        contentStack.axis = .vertical
        contentStack.spacing = 0
        contentStack.alignment = .fill

        contentStack.addArrangedSubview(SpacerView(height: 24))
        contentStack.addArrangedSubview(usersHeaderRow)
        contentStack.addArrangedSubview(SpacerView(height: 16))
        contentStack.addArrangedSubview(usersGridStack)
        contentStack.addArrangedSubview(searchesSection)
        contentStack.addArrangedSubview(SpacerView(height: 24))

        view.addSubview(scrollView)
        scrollView.pinToSuperview()
        scrollView.alwaysBounceVertical = true
        scrollView.contentInset = .init(top: 0, left: 0, bottom: 80, right: 0)

        scrollView.addSubview(contentStack)
        contentStack.pinToSuperview(edges: .vertical).pinToSuperview(edges: .horizontal)
        contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true

        updateTheme()
    }

    func wrapWithHorizontalPadding(_ inner: UIView, padding: CGFloat) -> UIView {
        let wrapper = UIView()
        wrapper.addSubview(inner)
        inner.pinToSuperview(edges: .vertical).pinToSuperview(edges: .horizontal, padding: padding)
        return wrapper
    }

    func buildUsersGrid() {
        usersGridStack.axis = .vertical
        usersGridStack.spacing = 16
        usersGridStack.alignment = .fill
        usersGridStack.distribution = .fill

        userViews = (0..<Self.maxUsers).map { _ in RecentUserView() }

        for row in 0..<Self.userRows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 8
            rowStack.alignment = .top
            rowStack.distribution = .fillEqually

            for col in 0..<Self.userColumns {
                rowStack.addArrangedSubview(userViews[row * Self.userColumns + col])
            }
            usersGridStack.addArrangedSubview(wrapWithHorizontalPadding(rowStack, padding: 16))
        }

        for (index, view) in userViews.enumerated() {
            view.onTap = { [weak self] in
                guard let self, let user = self.users[safe: index] else { return }
                self.show(ProfileViewController(profile: user), sender: nil)
            }
        }
    }

    func buildSearchesStack() {
        searchesStack.axis = .vertical
        searchesStack.spacing = 0
        searchesStack.alignment = .fill

        searchRows = (0..<Self.maxSearches).map { _ in RecentSearchRowView() }
        for row in searchRows { searchesStack.addArrangedSubview(row) }

        for (index, row) in searchRows.enumerated() {
            row.onTap = { [weak self] in
                guard let self, let term = self.searches[safe: index] else { return }
                self.openSearchResults(for: term)
            }
        }
    }

    func bind() {
        SmartContactsManager.instance.userSearchPublisher("")
            .receive(on: DispatchQueue.main)
            .sink { [weak self] users in
                self?.users = Array(users.prefix(Self.maxUsers))
            }
            .store(in: &cancellables)

        RecentSearchManager.instance.$recentSearches
            .receive(on: DispatchQueue.main)
            .sink { [weak self] searches in
                self?.searches = Array(searches.prefix(Self.maxSearches))
            }
            .store(in: &cancellables)
    }

    func applyUsers() {
        for (index, view) in userViews.enumerated() {
            if let user = users[safe: index] {
                view.setUser(user)
                view.isHidden = false
            } else {
                view.isHidden = true
            }
        }
    }

    func applySearches() {
        searchesSection.isHidden = searches.isEmpty

        for (index, row) in searchRows.enumerated() {
            if let term = searches[safe: index] {
                row.setSearch(term)
                row.isHidden = false
            } else {
                row.isHidden = true
            }
        }
    }

    func openSearchResults(for term: String) {
        let advancedSearch = AdvancedSearchManager()
        advancedSearch.searchScope = .global
        advancedSearch.searchType = .notes
        advancedSearch.includeWordsText = term

        RecentSearchManager.instance.addSearch(term)

        let feed = SearchNoteFeedController(feed: FeedManager(newFeed: advancedSearch.feed))
        show(feed, sender: nil)
    }
}
