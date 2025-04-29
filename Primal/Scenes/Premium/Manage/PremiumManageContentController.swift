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

private struct EventBackupStats: Codable {
    var running: Bool
    var kinds: [Int]?
    var status: String
    var progress: Double
}

class PremiumManageContentController: UITableViewController {
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var counts: [EventCountsResponse] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var data: [(String, NostrKind)] = [
        ("Notes", NostrKind.text),
        ("Reactions", NostrKind.reaction),
        ("DMs", NostrKind.encryptedDirectMessage),
        ("Articles", NostrKind.longForm),
    ]
    
    private var stats: EventBackupStats? { didSet { tableView.reloadData() } }
    
    var update: ContinousConnection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        navigationItem.leftBarButtonItem = customBackButton
        title = "Content Backup"
        
        tableView.register(PremiumManageContentHeaderCell.self, forCellReuseIdentifier: "header")
        tableView.register(PremiumManageContentDataCell.self, forCellReuseIdentifier: "cell")
        tableView.register(PremiumManageContentFooterCell.self, forCellReuseIdentifier: "footer")
        tableView.separatorStyle = .none
        
        requestUpdate()
        
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
    
    func requestUpdate() {
        guard let event = NostrObject.create(content: "", kind: 30078) else { return }
        
        update = Connection.regular.requestCacheContinous(name: "rebroadcasting_status", request: ["event_from_user": event.toJSON()], { [weak self] json in
            guard let stats: EventBackupStats = json.arrayValue?.last?.objectValue?["content"]?.stringValue?.decode() else {
                print("Unable to decode EventBackupStats")
                return
            }
            
            DispatchQueue.main.async {
                self?.stats = stats
            }
        })
    }
    
    func countForKinds(_ kinds: [Int]) -> Int {
        var total = 0
        for count in counts {
            if kinds.contains(count.kind) {
                total += count.cnt
            }
        }
        return total
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int { 3 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { section == 1 ? data.count + 1 : 1 }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "header", for: indexPath)
        }
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "footer", for: indexPath)
            (cell as? PremiumManageContentFooterCell)?.label.text = {
                guard let stats = stats else { return "" }
                
                let name: String
                if let kindInt = stats.kinds?.first, let kind = NostrKind(rawValue: kindInt) {
                    switch kind {
                    case .text:
                        name = "Notes"
                    case .encryptedDirectMessage:
                        name = "DMs"
                    case .longForm:
                        name = "Articles"
                    case .reaction:
                        name = "Reactions"
                    default:
                        name = "Other"
                    }
                } else {
                    name = "All"
                }
                
                if stats.running {
                    let percent = Int(stats.progress * 100)
                    return "Broadcasting \(name) Events: \(percent)%"
                }
                return "Broadcasting \(name) \(stats.status)"
            }()
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if let cell = cell as? PremiumManageContentDataCell {
            if let content = data[safe: indexPath.row] {
                cell.set(title: content.0, count: countForKinds([content.1.rawValue]))
            } else {
                let total = counts.reduce(0, { $0 + $1.cnt })
                cell.set(title: "All Events", count: total)
            }
            cell.delegate = self
        }
        cell.updateBackground(isLast: data.count == indexPath.row)
        return cell
    }
}

extension PremiumManageContentController: PremiumManageContentDataCellDelegate {
    func rebroadcastButtonPressedInCell(_ cell: PremiumManageContentDataCell) {
        guard let index = tableView.indexPath(for: cell)?.row else { return }

        let count: Int
        let kinds: [Int]
        if let content = data[safe: index] {
            kinds = [content.1.rawValue]
            count = countForKinds(kinds)
        } else {
            kinds = []
            count = counts.reduce(0, { $0 + $1.cnt })
        }
        
        let alert = UIAlertController(title: "Are you sure?", message: "Broadcast \(count.localized()) events to all your selected relays?", preferredStyle: .alert)
        alert.addAction(.init(title: "Cancel", style: .cancel))
        alert.addAction(.init(title: "Broadcast", style: .destructive, handler: { [weak self] _ in
            guard let self, let event = NostrObject.create(content: "{}", kind: 30078) else { return }

            var payload = ["event_from_user": event.toJSON()]
            if !kinds.isEmpty {
                payload["kinds"] = .array(kinds.map { .number(Double($0)) })
            }
            
            SocketRequest(name: "membership_content_rebroadcast_start", payload: .object(payload)).publisher()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] res in
                    if res.message == nil {
                        self?.requestUpdate()
                        RootViewController.instance.view.showToast("Rebroadcasting started", extraPadding: 0)
                    }
                }
                .store(in: &self.cancellables)
            
        }))
        present(alert, animated: true)
    }
}
