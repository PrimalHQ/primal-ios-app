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

class AdvancedSearchHomeController: UIViewController, AdvancedSearchControllerProtocol {
    let advancedSearchManager: AdvancedSearchManager
    init(manager: AdvancedSearchManager = .init()) {
        advancedSearchManager = manager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let textViews: [UITextField] = self.view.findAllSubviews()
        textViews.forEach { $0.resignFirstResponder() }
    }
}

extension AdvancedSearchHomeController {
    func setup() {
        title = advancedSearchManager.editingFeed == nil ? "Advanced Search" : "Edit Feed"

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

        let loadingOverlay = UIView()
        loadingOverlay.backgroundColor = UIColor.background4.withAlphaComponent(0.6)
        let spinner = LoadingSpinnerView().constrainToSize(60)
        loadingOverlay.addSubview(spinner)
        spinner.centerToSuperview()
        view.addSubview(loadingOverlay)
        loadingOverlay.pinToSuperview()
        loadingOverlay.isHidden = true

        advancedSearchManager.$isLoadingEdit
            .receive(on: DispatchQueue.main)
            .sink { isLoading in
                loadingOverlay.isHidden = !isLoading
                if isLoading { spinner.play() } else { spinner.stop() }
                mainStack.isUserInteractionEnabled = !isLoading
            }
            .store(in: &cancellables)

        searchButton.addAction(.init(handler: { [weak self] _ in
            guard let self, let nav: UINavigationController = presentingViewController?.findInChildren()  else { return }

            let editingFeed = advancedSearchManager.editingFeed
            if advancedSearchManager.searchType == .reads {
                let vc = SearchArticleFeedController(feed: advancedSearchManager.feed)
                vc.editingFeed = editingFeed
                nav.pushViewController(vc, animated: false)
            } else {
                let vc = SearchNoteFeedController(feed: .init(newFeed: advancedSearchManager.feed))
                vc.editingFeed = editingFeed
                nav.pushViewController(vc, animated: false)
            }

            dismiss(animated: true)
        }), for: .touchUpInside)

        keyboardSpacer.updateHeightCancellable().store(in: &cancellables)

        if let feed = advancedSearchManager.editingFeed {
            advancedSearchManager.loadAdvancedSearch(for: feed)
                .sink { _ in }
                .store(in: &cancellables)
        }
    }
    
    func contentStack() -> UIStackView {
        let includeField = SearchInputView(placeholder: "Include these words...")
        let excludeField = SearchInputView(icon: UIImage(named: "xIcon10")?.scalePreservingAspectRatio(size: 12).withRenderingMode(.alwaysTemplate), placeholder: "Exclude these words...")
        
        includeField.inputField.text = advancedSearchManager.includeWordsText
        excludeField.inputField.text = advancedSearchManager.excludeWordsText

        advancedSearchManager.$includeWordsText
            .sink { newValue in
                if includeField.inputField.text != newValue {
                    includeField.inputField.text = newValue
                }
            }
            .store(in: &cancellables)
        advancedSearchManager.$excludeWordsText
            .sink { newValue in
                if excludeField.inputField.text != newValue {
                    excludeField.inputField.text = newValue
                }
            }
            .store(in: &cancellables)

        let searchType = AdvancedSearchMenuItemView(title: "Search")
        let postedBy = AdvancedSearchUsersMenuItemView(title: "Posted By")
        let replyingTo = AdvancedSearchUsersMenuItemView(title: "Replying To")
        let zappedBy = AdvancedSearchUsersMenuItemView(title: "Zapped By")
        let timePosted = AdvancedSearchMenuItemView(title: "Time Posted")
        let scope = AdvancedSearchMenuItemView(title: "Scope")
        let filters = AdvancedSearchAccentMenuItemView(title: "Filter(s)")
        let orderBy = AdvancedSearchMenuItemView(title: "Order By")
        
        advancedSearchManager.$searchType.map({ $0.name }).assign(to: \.value, on: searchType).store(in: &cancellables)
        advancedSearchManager.$searchScope.map({ $0.name }).assign(to: \.value, on: scope).store(in: &cancellables)
        advancedSearchManager.$searchOrder.map({ $0.name }).assign(to: \.value, on: orderBy).store(in: &cancellables)
        
        advancedSearchManager.$postedBy.sink(receiveValue: { postedBy.setUsers($0) }).store(in: &cancellables)
        advancedSearchManager.$replyingTo.sink(receiveValue: { replyingTo.setUsers($0) }).store(in: &cancellables)
        advancedSearchManager.$zappedBy.sink(receiveValue: { zappedBy.setUsers($0) }).store(in: &cancellables)
        
        advancedSearchManager.$timePosted
            .map({ $0.name })
            .assign(to: \.value, on: timePosted).store(in: &cancellables)
        
        Publishers.CombineLatest(advancedSearchManager.$filters, advancedSearchManager.$searchType)
            .map({ $0.configurationString(type: $1) })
            .assign(to: \.accentValue, on: filters).store(in: &cancellables)
        
        includeField.inputField.addAction(.init(handler: { [weak self] _ in
            self?.advancedSearchManager.includeWordsText = includeField.inputField.text ?? ""
        }), for: .editingChanged)
        excludeField.inputField.addAction(.init(handler: { [weak self] _ in
            self?.advancedSearchManager.excludeWordsText = excludeField.inputField.text ?? ""
        }), for: .editingChanged)
        
        postedBy.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            show(AdvancedSearchUserPickerController(current: advancedSearchManager.postedBy, title: "Posted By", callback: { [weak self] users in
                self?.advancedSearchManager.postedBy = users
            }), sender: nil)
        }), for: .touchUpInside)
        replyingTo.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            show(AdvancedSearchUserPickerController(current: advancedSearchManager.replyingTo, title: "Replying To", callback: { [weak self] users in
                self?.advancedSearchManager.replyingTo = users
            }), sender: nil)
        }), for: .touchUpInside)
        zappedBy.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            show(AdvancedSearchUserPickerController(current: advancedSearchManager.zappedBy, title: "Zapped By", callback: { [weak self] users in
                self?.advancedSearchManager.zappedBy = users
            }), sender: nil)
        }), for: .touchUpInside)
        
        searchType.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            show(AdvancedSearchEnumPickerController(currentValue: advancedSearchManager.searchType) { [weak self] type in
                self?.advancedSearchManager.searchType = type
            }, sender: nil)
        }), for: .touchUpInside)
        scope.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            show(AdvancedSearchEnumPickerController(currentValue: advancedSearchManager.searchScope) { [weak self] scope in
                self?.advancedSearchManager.searchScope = scope
            }, sender: nil)
        }), for: .touchUpInside)
        orderBy.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            show(AdvancedSearchEnumPickerController(currentValue: advancedSearchManager.searchOrder) { [weak self] order in
                self?.advancedSearchManager.searchOrder = order
            }, sender: nil)
        }), for: .touchUpInside)
        
        timePosted.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            show(AdvancedSearchTimePickerController(currentValue: advancedSearchManager.timePosted, callback: { [weak self] time in
                self?.advancedSearchManager.timePosted = time
            }), sender: nil)
        }), for: .touchUpInside)
        
        filters.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            show(AdvancedSearchFilterController(values: advancedSearchManager.filters, type: advancedSearchManager.searchType, callback: { [weak self] filters in
                self?.advancedSearchManager.filters = filters
            }), sender: nil)
        }), for: .touchUpInside)
        
        let contentStack = UIStackView(axis: .vertical, [
            includeField, SpacerView(height: 20), excludeField, SpacerView(height: 15),
            searchType, postedBy, replyingTo, zappedBy, timePosted, scope, filters, orderBy
        ])
        return contentStack
    }
}
