//
//  SettingsConnectedAppPermissionsController.swift
//  Primal
//
//  Created by Pavle Stevanović on 9. 12. 2025..
//

import Combine
import UIKit
import PrimalShared

class SettingsConnectedAppPermissionsController: UIViewController {
    
    enum TableSections: Int, CaseIterable {
        case main
        case permissions
        case reset
    }
    
    enum TableItem: Hashable {
        case mainInfo(AppConnection, lastSession: AppSession?)
        case permission(AppPermissionGroup, AppConnection)
        case reset
        
        var cellId: String {
            switch self {
            case .mainInfo:     return RemoteSignerConnectionInfoCell.reuseID
            case .permission:   return RemoteSignerPermissionEditCell.reuseID
            case .reset:        return RemoteSignerConnectionSimpleAccentCell.reuseID
            }
        }
    }
    
    var cancellables: Set<AnyCancellable> = []
    
    @Published var items: [AppConnection] = []
    
    let dataSource: UITableViewDiffableDataSource<TableSections, TableItem>
    
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    let connectionID: String
    
    init(connectionId: String) {
        connectionID = connectionId
        var wSelf: SettingsConnectedAppPermissionsController?
        
        dataSource = UITableViewDiffableDataSource<TableSections, TableItem>(tableView: tableView) { tableView, indexPath, item in
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: item.cellId,
                for: indexPath
            )
            
            switch item {
            case .mainInfo(let connection, let lastSession):
                var lastStart: Date?
                if let start = lastSession?.sessionStartedAt {
                    lastStart = .init(timeIntervalSince1970: TimeInterval(start))
                }
                (cell as? RemoteSignerConnectionInfoCell)?.configure(connection: connection, lastStart: lastStart)
            case .permission(let permission, let connection):
                (cell as? RemoteSignerPermissionEditCell)?.configure(permission: permission, connection: connection)

//                (cell as? RemoteSignerPermissionEditCell)?.configure(connection: connection, delegate: wSelf)
            case .reset:
                (cell as? RemoteSignerConnectionSimpleAccentCell)?.configureWithText("Reset Permissions")
            }
            
            return cell
        }
        dataSource.defaultRowAnimation = .none

        super.init(nibName: nil, bundle: nil)
        
        wSelf = self
        title = "Connected App Details"
        
        updateTheme()
        navigationItem.backButtonDisplayMode = .default
        
        view.addSubview(tableView)
        tableView.pinToSuperview()
        tableView.register(RemoteSignerConnectionInfoCell.self, forCellReuseIdentifier: RemoteSignerConnectionInfoCell.reuseID)
        tableView.register(RemoteSignerPermissionEditCell.self, forCellReuseIdentifier: RemoteSignerPermissionEditCell.reuseID)
        tableView.register(RemoteSignerConnectionSimpleAccentCell.self, forCellReuseIdentifier: RemoteSignerConnectionSimpleAccentCell.reuseID)
        
        tableView.delegate = self
        
            
            Publishers.CombineLatest3(
                RemoteSigningManager.instance.sessionRepo.observeSessionsByClientPubKey(clientPubKey: connectionId).toPublisher().map { $0 as [AppSession] },
                RemoteSigningManager.instance.connectionRepo.observeConnection(clientPubKey: connectionId).toPublisher(),
                RemoteSigningManager.instance.permissionRepo.observePermissions(clientPubKey: connectionId).toPublisher()
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessions, connection, permissions in
                guard let connection else { return }
                
                var snapshot = NSDiffableDataSourceSnapshot<TableSections, TableItem>()
                snapshot.appendSections([.main, .permissions, .reset])
                
                snapshot.appendItems([.mainInfo(connection, lastSession: sessions.first)], toSection: .main)
                
                snapshot.appendItems(permissions.map { .permission($0, connection) }, toSection: .permissions)
                
                snapshot.appendItems([.reset], toSection: .reset)
                
                self?.dataSource.apply(snapshot)
            }
            .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        navigationItem.leftBarButtonItem = customBackButton
        
        tableView.backgroundColor = .background
        tableView.reloadData()
    }
}

// MARK: - Section Header Titles
extension SettingsConnectedAppPermissionsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snapshot = dataSource.snapshot()
        guard let sectionId = snapshot.sectionIdentifiers[safe: indexPath.section], let item = snapshot.itemIdentifiers(inSection: sectionId)[safe: indexPath.row] else {
            return
        }
        
        switch item {
        case .reset:
            showErrorMessage("Reset not implemented")
        default: return
        }
    }
}
