//
//  PremiumManageContentController.swift
//  Primal
//
//  Created by Pavle Stevanović on 17.11.24..
//

import Combine
import UIKit
import GenericJSON

private struct EventCountsResponse: Codable {
    var kind: Int
    var cnt: Int
}

class PremiumManageContentController: UITableViewController {
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var counts: [EventCountsResponse] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        navigationItem.leftBarButtonItem = customBackButton
        title = "Content Backup"
        
        tableView.register(PremiumManageContentHeaderCell.self, forCellReuseIdentifier: "header")
        tableView.register(PremiumManageContentDataCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        
        guard let event = NostrObject.create(content: "", kind: 30078) else { return }

        SocketRequest(name: "membership_content_stats", payload: ["event_from_user": event.toJSON()])
            .publisher()
            .compactMap({
                guard let event = $0.events.first(where: { Int($0["kind"]?.doubleValue ?? 0) == NostrKind.eventKindCounts.rawValue }) else { return nil }
                return event["content"]?.stringValue?.decode()
            })
            .receive(on: DispatchQueue.main)
            .assign(to: \.counts, onWeak: self)
            .store(in: &cancellables)
    }
    
    func titleForIndex(_ index: Int) -> String {
        switch index {
        case 0:
            return "Notes"
        case 1:
            return "Reactions"
        default:
            return "Articles"
        }
    }
    
    func countForIndex(_ index: Int) -> Int {
        let kinds = kindsForIndex(index)
        var total = 0
        for count in counts {
            if kinds.contains(count.kind) {
                total += count.cnt
            }
        }
        return total
    }
    
    func kindsForIndex(_ index: Int) -> [Int] {
        switch index {
        case 0: 
            return [NostrKind.text.rawValue]
        case 1: 
            return [NostrKind.repost.rawValue, NostrKind.reaction.rawValue]
        default:
            return [NostrKind.longForm.rawValue]
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int { 2 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { section == 0 ? 1 : 3 }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "header", for: indexPath)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? PremiumManageContentDataCell {
            cell.set(title: titleForIndex(indexPath.row), count: countForIndex(indexPath.row))
            cell.delegate = self
        }
        return cell
    }
}

extension PremiumManageContentController: PremiumManageContentDataCellDelegate {
    func rebroadcastButtonPressedInCell(_ cell: PremiumManageContentDataCell) {
        guard let index = tableView.indexPath(for: cell)?.row else { return }

        
        let alert = UIAlertController(title: "Are you sure?", message: "Broadcast \(countForIndex(index).localized()) events to all your selected relays?", preferredStyle: .alert)
        alert.addAction(.init(title: "Cancel", style: .cancel))
        alert.addAction(.init(title: "Broadcast", style: .destructive, handler: { _ in
            
            
            RootViewController.instance.view.showToast("Rebroadcasting started", extraPadding: 20)
        }))
        present(alert, animated: true)
    }
}
