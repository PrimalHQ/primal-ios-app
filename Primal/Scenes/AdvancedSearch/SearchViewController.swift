//
//  SearchViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 19.6.23..
//

import Combine
import UIKit
import SafariServices

protocol AdvancedSearchControllerProtocol: UIViewController {
    var advancedSearchManager: AdvancedSearchManager { get }
}

final class SearchViewController: MainNavigationController {
    static func present(from presenter: UIViewController, scope: SearchScope = .global, type: SearchType = .notes, advanced: Bool) {
        let search = SearchViewController(scope: scope, type: type, advanced: advanced)

        if let sheet = search.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            if #available(iOS 17.0, *) {
                sheet.traitOverrides.userInterfaceStyle = Theme.current.userInterfaceStyle
            }
        }

        presenter.present(search, animated: true)
    }

    /// Opens the advanced search builder pre-populated from an existing
    /// `AdvancedSearchManager` (e.g. profile search preselects the user).
    static func present(from presenter: UIViewController, manager: AdvancedSearchManager) {
        let search = SearchViewController(manager: manager)

        if let sheet = search.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            if #available(iOS 17.0, *) {
                sheet.traitOverrides.userInterfaceStyle = Theme.current.userInterfaceStyle
            }
        }

        presenter.present(search, animated: true)
    }

    /// Re-opens the advanced search builder pre-populated from a saved
    /// advanced-search feed. Calls `parse_advanced_search_query` to
    /// decompose the query string back into UI fields.
    static func presentForEditing(from presenter: UIViewController, feed: PrimalFeed) {
        let search = SearchViewController(scope: .global, type: .notes, advanced: true)
        search.child.advancedSearchManager.editingFeed = feed
        if let sheet = search.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            if #available(iOS 17.0, *) {
                sheet.traitOverrides.userInterfaceStyle = Theme.current.userInterfaceStyle
            }
        }

        presenter.present(search, animated: true)
    }

    let child: AdvancedSearchControllerProtocol

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(scope: SearchScope = .global, type: SearchType = .notes, advanced: Bool) {
        let searchChild = SearchViewChildController(scope: scope, type: type)
        child = advanced ? AdvancedSearchHomeController(manager: searchChild.advancedSearchManager) : searchChild
        super.init(rootViewController: child)
    }

    init(manager: AdvancedSearchManager) {
        child = AdvancedSearchHomeController(manager: manager)
        super.init(rootViewController: child)
    }
    
    override func updateAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .background4
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .font: UIFont.appFont(withSize: 20, weight: .bold),
            .foregroundColor: UIColor.foreground2
        ]
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.standardAppearance = appearance
        navigationBar.compactScrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
    }
}

final class SearchViewChildController: UIViewController, Themeable, WalletSearchController, AdvancedSearchControllerProtocol {
    let searchView = SearchInputHeaderView()
    let userTable = UITableView()

    let configButton = UIButton(configuration: .simpleImage(.searchConfig))

    @Published var userSearchText: String = ""

    var textSearch: String?

    var cancellables: Set<AnyCancellable> = []

    var users: [ParsedUser] = [] {
        didSet {
            userTable.reloadData()
        }
    }

    var navigationControllerForSearchResults: UINavigationController? {
        presentingViewController?.findInChildren()
    }

    let scope: SearchScope
    let searchType: SearchType
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(scope: SearchScope = .global, type: SearchType = .notes) {
        self.scope = scope
        searchType = type
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        searchView.inputField.becomeFirstResponder()
    }

    func updateTheme() {
        userTable.reloadData()
        searchView.updateTheme()
        
        userTable.backgroundColor = .background4
        view.backgroundColor = .background4

        configButton.tintColor = .foreground
    }
    
    var advancedSearchManager: AdvancedSearchManager {
        let advancedSearch = AdvancedSearchManager()
        advancedSearch.searchScope = scope
        advancedSearch.searchType = searchType
        let text = userSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !text.isEmpty {
            advancedSearch.includeWordsText = text
        }
        return advancedSearch
    }
}

private extension SearchViewChildController {
    func setup() {
        title = "Quick Search"
        
        configButton.constrainToSize(40)
        configButton.setContentHuggingPriority(.required, for: .horizontal)
        configButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        let searchRow = UIStackView(axis: .horizontal, spacing: 8, [searchView, configButton])
        searchRow.alignment = .center

        let searchRowWrapper = UIView()
        searchRowWrapper.addSubview(searchRow)
        searchRow.pinToSuperview(edges: .vertical).pinToSuperview(edges: .horizontal, padding: 16)
        
        let keyboardSpacer = KeyboardSizingView()

        let stack = UIStackView(axis: .vertical, [
            searchRowWrapper,
            SpacerView(height: 12, priority: .required),
            userTable, keyboardSpacer
        ])
        stack.alignment = .fill
        view.addSubview(stack)
        stack
            .pinToSuperview(edges: .top, safeArea: true)
            .pinToSuperview(edges: [.horizontal, .bottom])
        
        keyboardSpacer.updateHeightCancellable().store(in: &cancellables)
        updateTheme()
        setBindings()

        userTable.register(UserInfoTableCell.self, forCellReuseIdentifier: "userCell")
        userTable.register(SearchTermTableCell.self, forCellReuseIdentifier: "search")
        userTable.separatorStyle = .none
        userTable.delegate = self
        userTable.dataSource = self

        searchView.inputField.delegate = self
        searchView.inputField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        configButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            navigationController?.setViewControllers([AdvancedSearchHomeController(manager: advancedSearchManager)], animated: true)
        }), for: .touchUpInside)
    }

    func setBindings() {
        $userSearchText
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.userTable.reloadData()
            })

            .map { SmartContactsManager.instance.userSearchPublisher($0) }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] users in
                self?.users = users
            })
            .store(in: &cancellables)
    }

    func dismissAndPush(_ vc: UIViewController) {
        guard let nav: UINavigationController = presentingViewController?.findInChildren() else { return }
        searchView.inputField.resignFirstResponder()
        nav.pushViewController(vc, animated: false)
        dismiss(animated: true)
    }

    func doSearch() {
        if userSearchText.isEmpty { return }

        let userSearchText = userSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowerCased = userSearchText.lowercased()

        if lowerCased.hasPrefix("npub1") && userSearchText.count == 63 {
            notify(.primalProfileLink, userSearchText)
            dismiss(animated: true)
            return
        }

        if lowerCased.hasPrefix("note1") && userSearchText.count == 63, let text = userSearchText.noteIdToHex() {
            notify(.primalNoteLink, text)
            dismiss(animated: true)
            return
        }

        if (lowerCased.hasPrefix("lnurl") || lowerCased.hasPrefix("lnbc")) && lowerCased.count > 20 {
            search(userSearchText)
            return
        }

        if let url = URL(string: userSearchText), url.scheme?.lowercased() == "https" {
            let target = presentingViewController
            searchView.inputField.resignFirstResponder()
            dismiss(animated: true) {
                target?.present(SFSafariViewController(url: url), animated: true)
            }
            return
        }

        switch searchType {
        case .reads:
            let articleFeed = SearchArticleFeedController(feed: advancedSearchManager.feed)
            dismissAndPush(articleFeed)
        default:
            RecentSearchManager.instance.addSearch(userSearchText)

            let feed = SearchNoteFeedController(feed: FeedManager(newFeed: advancedSearchManager.feed))
            dismissAndPush(feed)
        }
    }

    @objc func textFieldDidChange() {
        userSearchText = searchView.inputField.text ?? ""
    }
}

extension SearchViewChildController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        doSearch()
        return true
    }
}

extension SearchViewChildController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "search", for: indexPath)
            if let cell = cell as? SearchTermTableCell {
                cell.termLabel.text = userSearchText.isEmpty ? "Enter text to search" : userSearchText
                switch searchType {
                case .reads:
                    cell.titleLabel.text = "Search reads"
                default:
                    switch scope {
                    case .myNotifications:
                        cell.titleLabel.text = "Search notifications"
                    default:
                        cell.titleLabel.text = "Search notes"
                    }
                }
                cell.updateTheme()
            }
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        (cell as? UserInfoTableCell)?.update(user: users[indexPath.row - 1])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            doSearch()
            return
        }

        let profile = ProfileViewController(profile: users[indexPath.row - 1])
        dismissAndPush(profile)
    }
}

final class SearchInputHeaderView: UIView, Themeable {
    let inputField = UITextField()
    let icon = UIImageView(image: UIImage(named: "searchIconSmall"))

    init() {
        super.init(frame: .zero)

        constrainToSize(height: 32)
        let width = widthAnchor.constraint(equalToConstant: 255)
        width.priority = .defaultLow
        width.isActive = true

        layer.cornerRadius = 16

        let stack = UIStackView(arrangedSubviews: [icon, inputField])
        stack.alignment = .center
        stack.spacing = 8

        addSubview(stack)
        stack.centerToSuperview().pinToSuperview(edges: .horizontal, padding: 12)

        icon.setContentHuggingPriority(.required, for: .horizontal)

        inputField.font = .appFont(withSize: 16, weight: .medium)
        inputField.autocorrectionType = .no
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateTheme() {
        backgroundColor = .background3
        inputField.textColor = .foreground
        icon.tintColor = .foreground
    }
}
