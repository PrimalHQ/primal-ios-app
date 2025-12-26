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
        case mainInfo(RemoteAppConnection, lastSession: AppSession?)
        case permission(AppPermissionGroup, RemoteAppConnection)
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
    
    @Published var items: [RemoteAppConnection] = []
    
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
                (cell as? RemoteSignerPermissionEditCell)?.configure(permission: permission, connection: connection, delegate: wSelf)
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
        tableView.pinToSuperview(safeArea: true)
        tableView.register(RemoteSignerConnectionInfoCell.self, forCellReuseIdentifier: RemoteSignerConnectionInfoCell.reuseID)
        tableView.register(RemoteSignerPermissionEditCell.self, forCellReuseIdentifier: RemoteSignerPermissionEditCell.reuseID)
        tableView.register(RemoteSignerConnectionSimpleAccentCell.self, forCellReuseIdentifier: RemoteSignerConnectionSimpleAccentCell.reuseID)
        
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.contentInset = .init(top: 20, left: 0, bottom: 60, right: 0)
        
        tableView.delegate = self
        
        refresh()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        navigationItem.leftBarButtonItem = customBackButton
        
        tableView.backgroundColor = .background
        tableView.reloadData()
    }
    
    func refresh() {
        Publishers.CombineLatest3(
            RemoteSignerManager.instance.sessionRepo.observeSessionsByAppIdentifier(appIdentifier: connectionID).toPublisher().map { $0 as [AppSession] },
            RemoteSignerManager.instance.connectionRepo.observeConnection(clientPubKey: connectionID).toPublisher(),
            RemoteSignerManager.instance.permissionRepo.observePermissions(clientPubKey: connectionID).toPublisher()
        )
        .first()  // Ugly table jumps on successive changes (probably something about not being to identify permission groups as same cells
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (sessions, connection, permissions) in
            guard let connection else { return }
            
            var snapshot = NSDiffableDataSourceSnapshot<TableSections, TableItem>()
            snapshot.appendSections([.main, .permissions, .reset])
            
            snapshot.appendItems([.mainInfo(connection, lastSession: sessions.first)], toSection: .main)
            
            snapshot.appendItems(permissions.sorted(by: { $0.title < $1.title }).map { .permission($0, connection) }, toSection: .permissions)
            
            snapshot.appendItems([.reset], toSection: .reset)
            
            self?.dataSource.apply(snapshot)
        }
        .store(in: &cancellables)
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
            let alert = UIAlertController(title: "Reset Permissions", message: "This will reset all permissions to default settings. Do you wish to continue?", preferredStyle: .alert)
            alert.addAction(.init(title: "Cancel", style: .cancel))
            alert.addAction(.init(title: "Reset", style: .destructive, handler: { [weak self] _ in
                guard let self else { return }
                Task { @MainActor in
                    _ = try await RemoteSignerManager.instance.permissionRepo.resetPermissionsToDefault(clientPubKey: self.connectionID)
                    self.refresh()
                }
            }))
            present(alert, animated: true)
        default: return
        }
    }
}

extension SettingsConnectedAppPermissionsController: RemoteSignerPermissionEditCellDelegate {
    func remoteSignerPermissionEditCell(_ cell: RemoteSignerPermissionEditCell, didSelect action: PrimalShared.AppPermissionAction) {
        var snapshot = dataSource.snapshot()
        var permissions = snapshot.itemIdentifiers(inSection: .permissions)
        guard
            let index = tableView.indexPath(for: cell),
            let cellInfo = permissions[safe: index.row],
            case .permission(var group, let connection) = cellInfo
        else { return }
        
        Task { @MainActor in
            do {
                let result = try await RemoteSignerManager.instance.permissionRepo.updatePermissionsAction(
                    permissionIds: group.permissionIds,
                    clientPubKey: connection.clientPubKey,
                    action: action,
                )
                
                group = .init(groupId: group.groupId, title: group.title, action: action, permissionIds: group.permissionIds)
                permissions[index.row] = .permission(group, connection)
                snapshot.deleteSections([.permissions])
                snapshot.insertSections([.permissions], afterSection: .main)
                snapshot.appendItems(permissions, toSection: .permissions)
                await self.dataSource.apply(snapshot)
            } catch {
                print("Failed to update permission action: \(error)")
            }
        }
    }
}
