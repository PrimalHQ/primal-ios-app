//
//  PublicBookmarksViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 10.4.24..
//

import Combine
import UIKit

final class PublicBookmarksViewController: PrimalPageController {
    lazy var navTitleView = DropdownNavigationView(title: "Bookmarked Notes")

    init() {
        super.init(tabs: [
            ("NOTES", { BookmarkedNoteFeedController() }),
            ("READS", { BookmarkedArticleFeedController() })
        ])
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = navTitleView
        navTitleView.button.addAction(.init(handler: { [weak self] _ in
            self?.present(PopupMenuViewController(message: nil, actions: [
                .init(title: "Notes", handler: { _ in
                    if self?.currentTab == 1 {
                        self?.set(tab: 0, old: 1)
                        self?.navTitleView.title = "Bookmarked Notes"
                    }
                }),
                .init(title: "Articles", handler: { _ in
                    if self?.currentTab == 0 {
                        self?.set(tab: 1, old: 0)
                        self?.navTitleView.title = "Bookmarked Articles"
                    }
                })
            ]), animated: true)
        }), for: .touchUpInside)
        
        tabSelectionView.isHidden = true
        border.isHidden = true
        
        pageVC.dataSource = nil
    }

    override func updateTheme() {
        super.updateTheme()
        
        navigationItem.leftBarButtonItem = customBackButton
    }
}

class EmptyTableViewCell: UITableViewCell {
    let view = EmptyTableView()
    
    var refreshCallback: (() -> ())?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(view)
        view.pinToSuperview().constrainToSize(height: 400)
        
        view.refresh.addAction(.init(handler: { [weak self] _ in
            self?.refreshCallback?()
        }), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class EmptyTableView: UIView, Themeable {
    let label = UILabel()
    let refresh = UIButton()
    
    convenience init(title: String) {
        self.init()
        label.text = title        
    }
    
    init() {
        super.init(frame: .zero)
        
        let stack = UIStackView(axis: .vertical, [label, refresh])
        addSubview(stack)
        stack.centerToSuperview()
        
        stack.alignment = .center
        stack.spacing = 18
    
        label.font = .appFont(withSize: 15, weight: .regular)
        
        refresh.titleLabel?.font = .appFont(withSize: 15, weight: .bold)
        refresh.setTitle("REFRESH", for: .normal)
        
        updateTheme()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        label.textColor = .foreground
        refresh.setTitleColor(.accent, for: .normal)
        refresh.setTitleColor(.accent.withAlphaComponent(0.5), for: .highlighted)
        
        backgroundColor = .background2
    }
}
