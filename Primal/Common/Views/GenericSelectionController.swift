//
//  GenericSelectionController.swift
//  Primal
//
//  Created by Pavle Stevanović on 24.4.26..
//

import UIKit

protocol SelectionItem: Equatable {
    var selectionTitle: String { get }
    var selectionSubtitle: String? { get }
}

extension SelectionItem {
    var selectionSubtitle: String? { nil }
}

final class GenericSelectionController<Item: SelectionItem>: SlideDownShellViewController, UITableViewDataSource, UITableViewDelegate {
    private let table = UITableView()
    private let closeButton = UIButton(configuration: .accent18("Close"))

    private var items: [Item]
    private var selectedItem: Item?
    private let onSelect: (Item) -> Void

    init(
        title: String,
        subtitle: String = "",
        items: [Item],
        selectedItem: Item?,
        onSelect: @escaping (Item) -> Void
    ) {
        self.items = items
        self.selectedItem = selectedItem
        self.onSelect = onSelect
        super.init()
        primalNavigationBar.title = title
        primalNavigationBar.subtitle = subtitle
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        DispatchQueue.main.async { [self] in
            if let selectedItem, let index = items.firstIndex(of: selectedItem) {
                table.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: false)
            }
        }

        table.reloadData()
    }

    private func setupContent() {
        table.showsVerticalScrollIndicator = false
        table.register(GenericSelectionCell.self, forCellReuseIdentifier: "cell")
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.backgroundColor = .background2

        let botMenu = UIStackView([UIView(), closeButton])
        botMenu.isLayoutMarginsRelativeArrangement = true
        botMenu.layoutMargins = .init(top: 5, left: 16, bottom: 0, right: 16)

        let contentStack = UIStackView(arrangedSubviews: [
            table, SpacerView(height: 1, color: .background3, priority: .required),
            botMenu
        ])
        contentStack.axis = .vertical

        contentView.addSubview(contentStack)
        contentStack.pinToSuperview()

        primalNavigationBar.showChevron = true
        primalNavigationBar.onTitleTapped = { [weak self] in
            self?.dismissAnimated()
        }

        closeButton.addAction(.init(handler: { [weak self] _ in
            self?.dismissAnimated()
        }), for: .touchUpInside)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = items[indexPath.row]
        (cell as? GenericSelectionCell)?.setup(
            title: item.selectionTitle,
            subtitle: item.selectionSubtitle,
            selected: item == selectedItem
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        selectedItem = item
        table.reloadData()
        onSelect(item)

        UIView.transition(with: primalNavigationBar.subtitleLabel, duration: 0.25, options: .transitionCrossDissolve) { [self] in
            primalNavigationBar.subtitle = item.selectionTitle
        }
        dismissAnimated()
    }
}

final class GenericSelectionCell: UITableViewCell {
    private let backgroundColorView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    private var mySelected = false

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        backgroundColorView.isHidden = !highlighted && !mySelected
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        let vStack = UIStackView(axis: .vertical, [titleLabel, subtitleLabel])
        vStack.alignment = .leading

        contentView.addSubview(backgroundColorView)
        backgroundColorView.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .vertical, padding: 6)

        contentView.addSubview(vStack)
        vStack.pinToSuperview(edges: .vertical, padding: 16).centerToSuperview()
        let leading = vStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32)
        leading.priority = .required
        leading.isActive = true

        backgroundColorView.backgroundColor = .background3
        backgroundColorView.layer.cornerRadius = 8

        titleLabel.font = .appFont(withSize: 20, weight: .regular)
        titleLabel.textColor = .foreground

        subtitleLabel.font = .appFont(withSize: 15, weight: .regular)
        subtitleLabel.textColor = .foreground4

        backgroundColor = .background2
        contentView.backgroundColor = .background2
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(title: String, subtitle: String?, selected: Bool) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = (subtitle ?? "").isEmpty

        mySelected = selected
        backgroundColorView.isHidden = !selected
    }
}
