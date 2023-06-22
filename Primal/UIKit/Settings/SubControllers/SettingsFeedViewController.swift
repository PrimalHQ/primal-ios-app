//
//  SettingsFeedViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.6.23..
//

import Combine
import UIKit

final class SettingsFeedViewController: UIViewController, Themeable {
    let table = UITableView()
    
    var feeds: [PrimalSettingsFeed] = []
    
    var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Feeds"
        navigationItem.leftBarButtonItem = customBackButton
        
        view.addSubview(table)
        table.pinToSuperview(edges: [.leading, .vertical], safeArea: true).pinToSuperview(edges: .trailing, padding: 6)
        table.backgroundColor = .background
        table.delegate = self
        table.dataSource = self
        table.dragDelegate = self
        table.dragInteractionEnabled = true
        table.isEditing = true
        table.separatorStyle = .none
        table.register(SettingsFeedCell.self, forCellReuseIdentifier: "cell")
        table.register(SettingsFeedHeaderView.self, forHeaderFooterViewReuseIdentifier: "header")
        table.register(SettingsFeedRestoreView.self, forHeaderFooterViewReuseIdentifier: "footer")
        
        IdentityManager.instance.$userSettings.receive(on: DispatchQueue.main).sink { [weak self] settings in
            self?.feeds = settings?.content.feeds ?? []
            self?.table.reloadData()
        }
        .store(in: &cancellables)
        
        IdentityManager.instance.requestUserSettings()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        IdentityManager.instance.updateFeeds(feeds)
    }
    
    func updateTheme() {
        table.reloadData()
        table.backgroundColor = .background
    }
}

extension SettingsFeedViewController: UITableViewDelegate, UITableViewDataSource, UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = feeds[indexPath.row]
        return [dragItem]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { feeds.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        
        // Configure content.
        content.text = feeds[indexPath.row].name

        // Customize appearance.
        content.textProperties.font = .appFont(withSize: 16, weight: .regular)
        content.textProperties.color = .foreground

        cell.contentConfiguration = content
        cell.showsReorderControl = true
        
        (cell as? Themeable)?.updateTheme()

        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        feeds[indexPath.row].name == "Latest" ? .none : .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        feeds.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let feed = feeds.remove(at: sourceIndexPath.row)
        if destinationIndexPath.row < feeds.count {
            feeds.insert(feed, at: destinationIndexPath.row)
        } else {
            feeds.append(feed)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        (view as? Themeable)?.updateTheme()
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view =  tableView.dequeueReusableHeaderFooterView(withIdentifier: "footer")
        (view as? Themeable)?.updateTheme()
        return view
    }
}

final class SettingsFeedCell: UITableViewCell, Themeable {
    let border = SpacerView(height: 1)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.constrainToSize(height: 44)
        addSubview(border)
        border.pinToSuperview(edges: .bottom).pinToSuperview(edges: .leading, padding: 20).pinToSuperview(edges: .trailing, padding: 14)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        border.backgroundColor = .foreground6
        backgroundColor = .background
    }
}

final class SettingsFeedHeaderView: UITableViewHeaderFooterView, Themeable {
    let label = UILabel()
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        label.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .top, padding: 10).pinToSuperview(edges: .bottom, padding: 12)
        label.font = .appFont(withSize: 14, weight: .medium)
        label.text = "YOUR NOSTR FEEDS"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        label.textColor = .foreground
        backgroundColor = .background
        contentView.backgroundColor = .background
    }
}

final class SettingsFeedRestoreView: UITableViewHeaderFooterView, Themeable {
    let button = UIButton()
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(button)
        button.pinToSuperview(edges: .trailing, padding: 14).pinToSuperview(edges: .top, padding: 30).pinToSuperview(edges: .bottom, padding: 12)
        
        button.setTitle("restore defaults", for: .normal)
        button.titleLabel?.font = .appFont(withSize: 18, weight: .medium)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        button.setTitleColor(.accent, for: .normal)
        button.setTitleColor(.accent.withAlphaComponent(0.5), for: .highlighted)
        backgroundColor = .background
        contentView.backgroundColor = .background
    }
}
