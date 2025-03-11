//
//  PremiumManageContactsController.swift
//  Primal
//
//  Created by Pavle Stevanović on 17.11.24..
//

import Combine
import UIKit
import GenericJSON

class PremiumManageContactsController: UITableViewController {
    
    private var cancellables: Set<AnyCancellable> = []
    
    var contacts: [DatedSet] = [] { didSet { tableView.reloadData() }}
    
    var didReachEnd = false
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        navigationItem.leftBarButtonItem = customBackButton
        title = "Recover Contact List"
        
        tableView.register(PremiumManageContactsHeaderCell.self, forCellReuseIdentifier: "header")
        tableView.register(PremiumManageContactsDataCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        
        guard let event = NostrObject.create(content: "", kind: 30078) else { return }

        SocketRequest(name: "membership_recovery_contact_lists", payload: ["event_from_user": event.toJSON()])
            .publisher()
            .compactMap({ $0.allContacts.sorted(by: { $0.created_at > $1.created_at }) })
            .receive(on: DispatchQueue.main)
            .assign(to: \.contacts, onWeak: self)
            .store(in: &cancellables)
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int { 2 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { section == 0 ? 1 : contacts.count }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "header", for: indexPath)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? PremiumManageContactsDataCell {
            cell.setData(contacts: contacts[indexPath.row])
            cell.delegate = self
        }
        cell.updateBackground(isLast: contacts.count - 1 == indexPath.row)
        return cell
    }
}

extension PremiumManageContactsController: PremiumManageContactsDataCellDelegate {
    func recoverButtonPressedInCell(_ cell: PremiumManageContactsDataCell) {
        guard let index = tableView.indexPath(for: cell)?.row, let set = contacts[safe: index] else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        let date = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(set.created_at)))
        let count = set.set.count.localized()
        
        let alert = UIAlertController(title: "Are you sure?", message: "Update your contact list based on the state from: \(date) (\(count) follows)?", preferredStyle: .alert)
        alert.addAction(.init(title: "Cancel", style: .cancel))
        alert.addAction(.init(title: "Update", style: .destructive, handler: { _ in
            FollowManager.instance.sendBatchFollowEvent(set.set, successHandler: {
                RootViewController.instance.view.showToast("Contact list updated", extraPadding: 0)
            })
        }))
        present(alert, animated: true)
    }
}
