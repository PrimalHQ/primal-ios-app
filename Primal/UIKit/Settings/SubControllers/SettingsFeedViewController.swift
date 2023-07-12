//
//  SettingsFeedViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.6.23..
//

import Combine
import UIKit
import GenericJSON

final class SettingsFeedViewController: UIViewController, Themeable {
    let table = UITableView()
    
    var feeds: [PrimalSettingsFeed] = []
    
    var cancellables: Set<AnyCancellable> = []
    
    var didChange = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Feeds"
        navigationItem.leftBarButtonItem = customBackButton
        
        view.addSubview(table)
        table.pinToSuperview(edges: [.leading, .top], safeArea: true).pinToSuperview(edges: .trailing, padding: 6)
        table.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        
        table.backgroundColor = .background
        table.delegate = self
        table.dataSource = self
        table.dragDelegate = self
        table.dragInteractionEnabled = true
        table.keyboardDismissMode = .onDrag
        table.isEditing = true
        table.separatorStyle = .none
        table.register(SettingsFeedCell.self, forCellReuseIdentifier: "cell")
        table.register(SettingsFeedHeaderView.self, forHeaderFooterViewReuseIdentifier: "header")
        table.register(SettingsFeedRestoreView.self, forHeaderFooterViewReuseIdentifier: "footer")
        
        IdentityManager.instance.$userSettings.receive(on: DispatchQueue.main).sink { [weak self] settings in
            self?.feeds = settings?.content.feeds ?? []
            self?.table.reloadData()
            self?.didChange = false
        }
        .store(in: &cancellables)
        
        IdentityManager.instance.requestUserSettings()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if didChange {
            IdentityManager.instance.updateFeeds(feeds)
            didChange = false
        }
    }
    
    func updateTheme() {
        table.reloadData()
        table.backgroundColor = .background
    }
    
    func shouldEditIndexPath(_ indexPath: IndexPath) -> Bool {
        feeds[indexPath.row].name != "Latest"
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
        
        if let settingsCell = cell as? SettingsFeedCell {
            settingsCell.inputField.text = feeds[indexPath.row].name
            settingsCell.inputField.delegate = self
            settingsCell.inputField.isEnabled = shouldEditIndexPath(indexPath)
            if settingsCell.inputField.allTargets.isEmpty {
                settingsCell.inputField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
            }
            
            settingsCell.updateTheme()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        shouldEditIndexPath(indexPath) ? .delete : .none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        feeds.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        
        didChange = true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let feed = feeds.remove(at: sourceIndexPath.row)
        if destinationIndexPath.row < feeds.count {
            feeds.insert(feed, at: destinationIndexPath.row)
        } else {
            feeds.append(feed)
        }
        
        didChange = true
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        (view as? Themeable)?.updateTheme()
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view =  tableView.dequeueReusableHeaderFooterView(withIdentifier: "footer")
        (view as? Themeable)?.updateTheme()
        if let footer = view as? SettingsFeedRestoreView {
            if footer.button.allTargets.isEmpty {
                footer.button.addTarget(self, action: #selector(restoreButtonPressed), for: .touchUpInside)
            }
            footer.updateTheme()
        }
        return view
    }
    
    @objc func restoreButtonPressed() {
        guard let userPubkey = IdentityManager.instance.user?.pubkey else { return }
        
        Connection.instance.requestCache(name: "get_default_app_settings", request: .object(["client": .string("Primal iOS")])) { result in
            
            var defaultFeeds: [PrimalSettingsFeed] = [.init(name: "Latest", hex: userPubkey)]
            
            for object in result {
                guard
                    let payload = object.arrayValue?.last?.objectValue,
                    let kind = NostrKind(rawValue: Int(payload["kind"]?.doubleValue ?? -1377)),
                    case .defaultSettings = kind,
                    let contentString = payload["content"]?.stringValue,
                    let content = (try? JSONDecoder().decode(JSON.self, from: Data(contentString.utf8)))?.objectValue,
                    let feeds = content["feeds"]?.arrayValue
                else { continue }
                
                for feed in feeds {
                    guard
                        let obj = feed.objectValue,
                        let name = obj["name"]?.stringValue,
                        let hex = obj["hex"]?.stringValue
                    else {
                        continue
                    }
                    
                    defaultFeeds.append(.init(name: name, hex: hex))
                }
            }
            
            IdentityManager.instance.updateFeeds(defaultFeeds)
        }
    }
}

extension SettingsFeedViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let indexes = table.indexPathsForVisibleRows else { return }
        
        for index in indexes {
            guard let cell = table.cellForRow(at: index) as? SettingsFeedCell else { continue }
            
            if cell.inputField == textField {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                    self.table.scrollToRow(at: index, at: .middle, animated: true)
                }
                return
            }
        }
    }
}

private extension SettingsFeedViewController {
    @objc func textFieldDidChange() {
        guard let indexPaths = table.indexPathsForVisibleRows else { return }
     
        didChange = true
        
        for indexPath in indexPaths {
            guard let text = (table.cellForRow(at: indexPath) as? SettingsFeedCell)?.inputField.text else { continue }
            feeds[indexPath.row].name = text
        }
    }
}

final class SettingsFeedCell: UITableViewCell, Themeable {
    let border = SpacerView(height: 1)
    let inputField = UITextField()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.constrainToSize(height: 44)
        addSubview(border)
        border.pinToSuperview(edges: .bottom).pinToSuperview(edges: .leading, padding: 20).pinToSuperview(edges: .trailing, padding: 14)
        
        contentView.addSubview(inputField)
        inputField.centerToSuperview(axis: .vertical).pinToSuperview(edges: .horizontal, padding: 56)
        
        inputField.font = .appFont(withSize: 16, weight: .regular)
        inputField.returnKeyType = .done
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        border.backgroundColor = .foreground6
        backgroundColor = .background
        inputField.textColor = .foreground
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
