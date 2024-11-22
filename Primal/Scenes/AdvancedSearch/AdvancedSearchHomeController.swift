//
//  AdvancedSearchHomeController.swift
//  Primal
//
//  Created by Pavle Stevanović on 11.10.24..
//

import Combine
import UIKit

extension UIButton {
    static func largeRoundedButton(title: String) -> UIButton {
        let button = UIButton()
        button.layer.cornerRadius = 26
        button.titleLabel?.font = .appFont(withSize: 18, weight: .semibold)
        button.backgroundColor = .accent
        button.setTitleColor(.white, for: .normal)
        button.setTitle(title, for: .normal)
        return button.constrainToSize(height: 52)
    }
}

class AdvancedSearchHomeController: UIViewController {
    let manager: AdvancedSearchManager
    init(manager: AdvancedSearchManager = .init()) {
        self.manager = manager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let textViews: [UITextField] = self.view.findAllSubviews()
        textViews.forEach { $0.resignFirstResponder() }
    }
}

extension AdvancedSearchHomeController {
    func setup() {
        title = "Advanced Search"
        
        let scroll = UIScrollView()
        let content = contentStack()
        scroll.addSubview(content)
        content.pinToSuperview()
        content.widthAnchor.constraint(equalTo: scroll.widthAnchor).isActive = true
        scroll.keyboardDismissMode = .onDrag
        
        let searchButton = UIButton.largeRoundedButton(title: "Search")
        let keyboardSpacer = KeyboardSizingView()
        let mainStack = UIStackView(axis: .vertical, [scroll, SpacerView(height: 20, priority: .required), searchButton, keyboardSpacer])
        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .top, safeArea: true)
            .pinToSuperview(edges: .horizontal, padding: 20)
            .pinToSuperview(edges: .bottom)
        
        mainStack.setCustomSpacing(20, after: searchButton)
        searchButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        view.backgroundColor = .background4
        
        searchButton.addAction(.init(handler: { [weak self] _ in
            guard let self, let nav: UINavigationController = presentingViewController?.findInChildren()  else { return }
            
            if manager.searchType == .reads {
                nav.pushViewController(SearchArticleFeedController(feed: manager.feed), animated: false)
            } else {
                nav.pushViewController(SearchNoteFeedController(feed: .init(newFeed: manager.feed)), animated: false)
            }
            
            dismiss(animated: true)
        }), for: .touchUpInside)
        
        keyboardSpacer.updateHeightCancellable().store(in: &cancellables)
    }
    
    func contentStack() -> UIStackView {
        let includeField = SearchInputView(placeholder: "Include these words...")
        let excludeField = SearchInputView(icon: UIImage(named: "xIcon10")?.scalePreservingAspectRatio(size: 12).withRenderingMode(.alwaysTemplate), placeholder: "Exclude these words...")
        
        includeField.inputField.text = manager.includeWordsText
        
        let searchType = AdvancedSearchMenuItemView(title: "Search")
        let postedBy = AdvancedSearchUsersMenuItemView(title: "Posted By")
        let replyingTo = AdvancedSearchUsersMenuItemView(title: "Replying To")
        let zappedBy = AdvancedSearchUsersMenuItemView(title: "Zapped By")
        let timePosted = AdvancedSearchMenuItemView(title: "Time Posted")
        let scope = AdvancedSearchMenuItemView(title: "Scope")
        let filters = AdvancedSearchAccentMenuItemView(title: "Filter(s)")
        let orderBy = AdvancedSearchMenuItemView(title: "Order By")
        
        manager.$searchType.map({ $0.name }).assign(to: \.value, on: searchType).store(in: &cancellables)
        manager.$searchScope.map({ $0.name }).assign(to: \.value, on: scope).store(in: &cancellables)
        manager.$searchOrder.map({ $0.name }).assign(to: \.value, on: orderBy).store(in: &cancellables)
        
        manager.$postedBy.sink(receiveValue: { postedBy.setUsers($0) }).store(in: &cancellables)
        manager.$replyingTo.sink(receiveValue: { replyingTo.setUsers($0) }).store(in: &cancellables)
        manager.$zappedBy.sink(receiveValue: { zappedBy.setUsers($0) }).store(in: &cancellables)
        
        manager.$timePosted
            .map({ $0.name })
            .assign(to: \.value, on: timePosted).store(in: &cancellables)
        
        Publishers.CombineLatest(manager.$filters, manager.$searchType)
            .map({ $0.configurationString(type: $1) })
            .assign(to: \.accentValue, on: filters).store(in: &cancellables)
        
        includeField.inputField.addAction(.init(handler: { [weak self] _ in
            self?.manager.includeWordsText = includeField.inputField.text ?? ""
        }), for: .editingChanged)
        excludeField.inputField.addAction(.init(handler: { [weak self] _ in
            self?.manager.excludeWordsText = excludeField.inputField.text ?? ""
        }), for: .editingChanged)
        
        postedBy.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            show(AdvancedSearchUserPickerController(current: manager.postedBy, title: "Posted By", callback: { [weak self] users in
                self?.manager.postedBy = users
            }), sender: nil)
        }), for: .touchUpInside)
        replyingTo.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            show(AdvancedSearchUserPickerController(current: manager.replyingTo, title: "Replying To", callback: { [weak self] users in
                self?.manager.replyingTo = users
            }), sender: nil)
        }), for: .touchUpInside)
        zappedBy.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            show(AdvancedSearchUserPickerController(current: manager.zappedBy, title: "Zapped By", callback: { [weak self] users in
                self?.manager.zappedBy = users
            }), sender: nil)
        }), for: .touchUpInside)
        
        searchType.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            show(AdvancedSearchEnumPickerController(currentValue: manager.searchType) { [weak self] type in
                self?.manager.searchType = type
            }, sender: nil)
        }), for: .touchUpInside)
        scope.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            show(AdvancedSearchEnumPickerController(currentValue: manager.searchScope) { [weak self] scope in
                self?.manager.searchScope = scope
            }, sender: nil)
        }), for: .touchUpInside)
        orderBy.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            show(AdvancedSearchEnumPickerController(currentValue: manager.searchOrder) { [weak self] order in
                self?.manager.searchOrder = order
            }, sender: nil)
        }), for: .touchUpInside)
        
        timePosted.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            show(AdvancedSearchTimePickerController(currentValue: manager.timePosted, callback: { [weak self] time in
                self?.manager.timePosted = time
            }), sender: nil)
        }), for: .touchUpInside)
        
        filters.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            show(AdvancedSearchFilterController(values: manager.filters, type: manager.searchType, callback: { [weak self] filters in
                self?.manager.filters = filters
            }), sender: nil)
        }), for: .touchUpInside)
        
        let contentStack = UIStackView(axis: .vertical, [
            includeField, SpacerView(height: 20), excludeField, SpacerView(height: 15),
            searchType, postedBy, replyingTo, zappedBy, timePosted, scope, filters, orderBy
        ])
        return contentStack
    }
}
