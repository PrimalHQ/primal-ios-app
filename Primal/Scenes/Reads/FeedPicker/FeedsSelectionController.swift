//
//  ArticleFeedSelectionController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 4.5.23..
//

import UIKit
import Kingfisher
import Combine
import GenericJSON

extension UIButton.Configuration {
    static func accent18(_ title: String) -> UIButton.Configuration {
        var config = UIButton.Configuration.plain()
        config.attributedTitle = .init(title, attributes: .init([
            .font: UIFont.appFont(withSize: 18, weight: .regular),
            .foregroundColor: UIColor.accent
        ]))
        return config
    }
}

extension PrimalFeed {
    var isFromBackend: Bool {
        get { feedkind == "primal" }
    }
    var isEnabled: Bool {
        get { enabled ?? true }
        set { enabled = newValue }
    }
}

enum PrimalFeedType {
    case note, article
    
    var subkey: String {
        switch self {
        case .note:     return "user-home-feeds"
        case .article:  return "user-reads-feeds"
        }
    }
}

extension PrimalFeed {
    static func setServerFeeds(_ feeds: [PrimalFeed], type: PrimalFeedType) {
        var allFeeds = getAllFeeds(type)
        
        allFeeds.removeAll(where: { feed in
            feed.isFromBackend && !feeds.contains(where: { $0.spec == feed.spec })
        })
        
        for feed in feeds where !allFeeds.contains(where: { $0.spec == feed.spec }) {
            allFeeds.append(feed)
        }
        
        setAllFeeds(allFeeds, type: type)
    }
    
    static var lastTimeFeedsFetched: [PrimalFeedType: Date] = [:]
    
    static func setAllFeeds(_ feeds: [PrimalFeed], type: PrimalFeedType, notifyBackend: Bool = false)  {
        let encodedToString = feeds.encodeToString()
        switch type {
        case .article:
            UserDefaults.standard.setValue(encodedToString, forKey: allReadsKey)
        case .note:
            UserDefaults.standard.setValue(encodedToString, forKey: allNotesKey)
        }
        if notifyBackend {
            guard
                let feedSettings: JSON = encodedToString?.decode(),
                let contentString = JSON(dictionaryLiteral:
                    ("subkey", .string(type.subkey)),
                    ("settings", feedSettings)
                ).encodeToString(),
                let ev = NostrObject.create(content: contentString, kind: 30078)?.toJSON()
            else { return }
            
            Connection.regular.requestCache(name: "set_app_subsettings", payload: ["event_from_user": ev]) { result in
                print(result)
            }
        }
    }
    
    private static var allReadsKey: String { IdentityManager.instance.userHexPubkey + "allReadsFeedsKey" }
    private static var allNotesKey: String { IdentityManager.instance.userHexPubkey + "allNotesFeedsKey" }
    static func getAllFeeds(_ type: PrimalFeedType) -> [PrimalFeed] {
        switch type {
        case .note:
            return UserDefaults.standard.string(forKey: allNotesKey)?.decode() ?? []
        case .article:
            return UserDefaults.standard.string(forKey: allReadsKey)?.decode() ?? []
        }
    }
    
    static func getActiveFeeds(_ type: PrimalFeedType) -> [PrimalFeed] {
        getAllFeeds(type).filter { $0.isEnabled }
    }
    
    static let defaultReadsFeed = PrimalFeed(name: "Nostr Reads", spec: "{\"kind\":\"reads\",\"scope\":\"follows\"}")
    static let defaultNotesFeed = PrimalFeed(name: "Latest", spec: "{\"kind\":\"notes\",\"id\":\"latest\"}")
}

final class FeedsSelectionController: UIViewController {
    var cancellables: Set<AnyCancellable> = []
    
    let table = UITableView()
    
    var callback: (PrimalFeed) -> Void
    
    lazy var feeds = PrimalFeed.getActiveFeeds(type)
    
    let addFeedButton = UIButton(configuration: .accent18("Add Feed"))
    let editButton = UIButton(configuration: .accent18("Edit"))
    let doneButton = UIButton(configuration: .accent18("Done"))
    
    var currentFeed: PrimalFeed
    let type: PrimalFeedType
    init(currentFeed: PrimalFeed, type: PrimalFeedType, _ callback: @escaping (PrimalFeed) -> Void) {
        self.callback = callback
        self.currentFeed = currentFeed
        self.type = type
        super.init(nibName: nil, bundle: nil)
        setup()
        
        if let lastFetch = PrimalFeed.lastTimeFeedsFetched[type], abs(lastFetch.timeIntervalSinceNow) < 300 {
            // Do nothing
            print("NOTHING")
        } else if let ev = NostrObject.create(content: "{\"subkey\":\"\(type.subkey)\"}", kind: 30078)?.toJSON() {
            SocketRequest(name: "get_app_subsettings", payload: ["event_from_user": ev]).publisher()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] result in
                    let feeds = result.readFeeds
                    
                    guard let self, !feeds.isEmpty else { return }
                    PrimalFeed.setAllFeeds(feeds, type: type)
                    PrimalFeed.lastTimeFeedsFetched[type] = Date()
                    updateTable()
                    
                    SocketRequest(name: "get_default_app_subsettings", payload: ["subkey": .string(type.subkey)]).publisher()
                        .receive(on: DispatchQueue.main)
                        .sink { [weak self] result in
                            let feeds = result.readFeeds
                            
                            if feeds.isEmpty { return }
                            
                            PrimalFeed.setServerFeeds(feeds, type: type)
                            self?.updateTable()
                        }
                        .store(in: &cancellables)
                }
                .store(in: &cancellables)
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateTable()
        
        DispatchQueue.main.async { [self] in
            if let index = feeds.firstIndex(where: { $0.spec == currentFeed.spec }) {
                table.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: false)
            }
        }
        
        table.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension FeedsSelectionController {
    func updateTable() {
        if isEditing {
            startEditing()
        } else {
            endEditing()
        }
    }
    
    func startEditing() {
        editButton.isHidden = true
        doneButton.isHidden = false
        addFeedButton.isHidden = false
        
        isEditing = true
        table.dragDelegate = self
        
        updateFeeds(feeds, PrimalFeed.getAllFeeds(type))
    }
    
    func endEditing() {
        editButton.isHidden = LoginManager.instance.method() == .nsec ? false : true
        doneButton.isHidden = true
        addFeedButton.isHidden = true
        
        isEditing = false
        table.dragDelegate = nil
        
        updateFeeds(feeds, PrimalFeed.getActiveFeeds(type))
    }
    
    func updateFeeds(_ oldValue: [PrimalFeed], _ newValue: [PrimalFeed]) {
        if table.window == nil {
            feeds = newValue
            return
        }
        
        let old = (0...oldValue.count).map { IndexPath(row: $0, section: 0) }
        table.reloadRows(at: old, with: .automatic)
        
        feeds = newValue
        
        if oldValue.count > newValue.count {
            let changed = oldValue.enumerated().filter { old in !newValue.contains(where: { $0.spec == old.element.spec })}.map { IndexPath(row: $0.offset, section: 0) }
            
            table.deleteRows(at: changed, with: .automatic)
        } else if oldValue.count < newValue.count {
            let changed = newValue.enumerated().filter { new in !oldValue.contains(where: { $0.spec == new.element.spec })}.map { IndexPath(row: $0.offset, section: 0) }
            
            table.insertRows(at: changed, with: .automatic)
        } else {
            table.reloadData()
        }
    }
    
    func setup() {
        view.backgroundColor = .background2
        
        let pullBarParent = UIView()
        let pullBar = UIView()
        pullBarParent.addSubview(pullBar)
        pullBar.pinToSuperview(edges: .vertical).centerToSuperview(axis: .horizontal)
        
        let title = UILabel()
        switch type {
        case .note:
            title.text = "Home Feeds"
        case .article:
            title.text = "Reads Feeds"
        }
        title.font = .appFont(withSize: 20, weight: .bold)
        title.textColor = .foreground
        title.setContentCompressionResistancePriority(.required, for: .vertical)
        title.textAlignment = .center
        
        table.showsVerticalScrollIndicator = false
        table.register(ArticleFeedSelectionCell.self, forCellReuseIdentifier: "cell")
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.backgroundColor = .background2
        
        let botMenu = UIStackView([addFeedButton, UIView(), editButton, doneButton])
        botMenu.isLayoutMarginsRelativeArrangement = true
        botMenu.layoutMargins = .init(top: 5, left: 16, bottom: 0, right: 16)
        
        let stack = UIStackView(arrangedSubviews: [
            pullBarParent, SpacerView(height: 20, priority: .required),
            title, SpacerView(height: 14, priority: .required),
            table, SpacerView(height: 1, color: .background3, priority: .required),
            botMenu
        ])
        table.pinToSuperview(edges: .horizontal)
        
        view.addSubview(stack)
        stack.pinToSuperview(edges: .top, padding: 16).pinToSuperview(edges: .bottom, safeArea: true).pinToSuperview(edges: .horizontal)
        stack.axis = .vertical
        
        pullBar.constrainToSize(width: 60, height: 5)
        pullBar.backgroundColor = .foreground.withAlphaComponent(0.8)
        pullBar.layer.cornerRadius = 2.5
        
        addFeedButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            show(FeedMarketplaceController(type: type), sender: nil)
        }), for: .touchUpInside)
        
        editButton.addAction(.init(handler: { [weak self] _ in self?.startEditing() }), for: .touchUpInside)
        doneButton.addAction(.init(handler: { [weak self] _ in self?.endEditing() }), for: .touchUpInside)
        
        endEditing()
    }
}

extension FeedsSelectionController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = feeds[indexPath.row]
        return [dragItem]
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle { .none }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let feed = feeds.remove(at: sourceIndexPath.row)
        if destinationIndexPath.row < feeds.count {
            feeds.insert(feed, at: destinationIndexPath.row)
        } else {
            feeds.append(feed)
        }
        
        PrimalFeed.setAllFeeds(feeds, type: type, notifyBackend: true)
    }
}

extension FeedsSelectionController: ArticleFeedSelectionCellDelegate {
    func switchToggledInCell(_ cell: ArticleFeedSelectionCell) {
        guard let indexPath = table.indexPath(for: cell) else { return }
        
        let feed = feeds[indexPath.row]
        
        if cell.enableSwitch.isOn {
            feeds[indexPath.row].isEnabled = true
        } else if feed.isFromBackend {
            feeds[indexPath.row].isEnabled = false
        } else {
            let alert = UIAlertController(title: "Remove ‘\(feed.name)’ from your feed list?", message: nil, preferredStyle: .alert)
            alert.addAction(.init(title: "Cancel", style: .cancel, handler: { _ in
                cell.enableSwitch.setOn(true, animated: true)
            }))
            alert.addAction(.init(title: "Remove", style: .destructive, handler: { [weak self] _ in
                guard let self else { return }
                feeds.remove(at: indexPath.row)
                PrimalFeed.setAllFeeds(feeds, type: type, notifyBackend: true)
                table.reloadData()
            }))
            present(alert, animated: true)
            return
        }
        PrimalFeed.setAllFeeds(feeds, type: type, notifyBackend: true)
        table.reloadData()
    }
}

extension FeedsSelectionController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { feeds.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let feed = feeds[indexPath.row]
        
        (cell as? ArticleFeedSelectionCell)?.setup(feed, selected: feed.spec == currentFeed.spec, editing: isEditing, delegate: self)
        return cell
    }
}

extension FeedsSelectionController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditing { return }
        
        currentFeed = feeds[indexPath.row]
        table.reloadData()
        dismiss(animated: true)
        callback(currentFeed)
    }
}

protocol ArticleFeedSelectionCellDelegate: AnyObject {
    func switchToggledInCell(_ cell: ArticleFeedSelectionCell)
}

class ArticleFeedSelectionCell: UITableViewCell {
    let backgroundColorView = UIView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let enableSwitch = UISwitch()
    let dragIcon = UIImageView(image: UIImage(named: "dragGrabIcon"))
    
    weak var delegate: ArticleFeedSelectionCellDelegate?
    
    var myEditing = false
    var mySelected = false
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        backgroundColorView.isHidden = myEditing || (!highlighted && !mySelected)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        let switchParent = UIView().constrainToSize(42)
        switchParent.addSubview(enableSwitch)
        enableSwitch.centerToSuperview()
        enableSwitch.transform = .init(scaleX: 42 / 51, y: 42 / 51)
        
        let vStack = UIStackView(axis: .vertical, [titleLabel, subtitleLabel])
        vStack.alignment = .leading
        
        let mainStack = UIStackView([vStack, switchParent, dragIcon])
        mainStack.spacing = 20
        mainStack.alignment = .center
        
        contentView.addSubview(backgroundColorView)
        backgroundColorView.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .vertical, padding: 6)
        backgroundColorView.isHidden = isSelected
        
        contentView.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .vertical, padding: 16).centerToSuperview()
        let leading = mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32)
        leading.priority = .required
        leading.isActive = true
        
        backgroundColorView.backgroundColor = .background3
        backgroundColorView.layer.cornerRadius = 8
        
        titleLabel.font = .appFont(withSize: 20, weight: .regular)
        titleLabel.textColor = .foreground
        
        subtitleLabel.font = .appFont(withSize: 15, weight: .regular)
        subtitleLabel.textColor = .foreground4
        
        dragIcon.tintColor = .foreground6
        
        backgroundColor = .background2
        contentView.backgroundColor = .background2
        
        enableSwitch.addAction(.init(handler: { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
                guard let self else { return }
                self.delegate?.switchToggledInCell(self)
            }
        }), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(_ feed: PrimalFeed, selected: Bool, editing: Bool, delegate: ArticleFeedSelectionCellDelegate) {
        self.delegate = delegate
        
        titleLabel.text = feed.name
        subtitleLabel.text = feed.description
        
        enableSwitch.superview?.isHidden = !editing
        dragIcon.isHidden = !editing
        
        myEditing = editing
        mySelected = selected
        backgroundColorView.isHidden = selected && !editing
        
        if editing && feed.isFromBackend {
            enableSwitch.isOn = feed.isEnabled
        } else {
            enableSwitch.isOn = true
        }
    }
}
