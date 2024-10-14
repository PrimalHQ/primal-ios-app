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
    let manager = AdvancedSearchManager()
    
    var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

extension AdvancedSearchHomeController {
    func setup() {
        title = "Advanced Search"
        
        let searchButton = UIButton.largeRoundedButton(title: "Search")
        let mainStack = UIStackView(axis: .vertical, [contentStack(), searchButton])
        mainStack.distribution = .equalSpacing
        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .top, safeArea: true)
            .pinToSuperview(edges: .horizontal, padding: 20)
            .pinToSuperview(edges: .bottom, padding: 20, safeArea: true)
        
        view.backgroundColor = .background4
    }
    
    func contentStack() -> UIStackView {
        let searchType = AdvancedSearchMenuItemView(title: "Search")
        let postedBy = AdvancedSearchUsersMenuItemView(title: "Posted By")
        let replyingTo = AdvancedSearchUsersMenuItemView(title: "Replying To")
        let zappedBy = AdvancedSearchUsersMenuItemView(title: "Zapped By")
        let timePosted = AdvancedSearchMenuItemView(title: "Time Posted")
        let scope = AdvancedSearchMenuItemView(title: "Scope")
        let filters = AdvancedSearchMenuItemView(title: "Filter(s)")
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
        
        manager.$filters.map({ $0 ?? "None" }).assign(to: \.value, on: filters).store(in: &cancellables)
        
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
        
        let contentStack = UIStackView(axis: .vertical, [
            searchType, postedBy, replyingTo, zappedBy, timePosted, scope, filters, orderBy
        ])
        return contentStack
    }

}
