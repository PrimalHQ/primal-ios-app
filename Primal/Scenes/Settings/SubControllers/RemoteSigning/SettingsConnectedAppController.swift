//
//  SettingsConnectedAppController.swift
//  Primal
//
//  Created by Pavle Stevanović on 8. 12. 2025..
//

import Combine
import UIKit
import PrimalShared

class SettingsConnectedAppController: UIViewController {
    
    enum TableSections: Int, CaseIterable {
        case main
        case permissions
        case sessions
    }
    
    enum TableItem: Hashable {
        case mainInfo(AppConnection, lastSession: AppSession?)
        case autoStart(AppConnection)
        case trust(TrustLevel, AppConnection)
        case permissionDetails
        case session(AppSession)
        
        var cellId: String {
            switch self {
            case .mainInfo:         return RemoteSignerConnectionInfoActionCell.reuseID
            case .autoStart:        return RemoteSignerConnectionAutostartCell.reuseID
            case .trust:            return RemoteSignerConnectionTrustCell.reuseID
            case .permissionDetails:return RemoteSignerConnectionSimpleAccentCell.reuseID
            case .session:          return RemoteSignerConnectionSessionCell.reuseID
            }
        }
    }
    
    var cancellables: Set<AnyCancellable> = []
    
    @Published var items: [AppConnection] = []
    
    let dataSource: UITableViewDiffableDataSource<TableSections, TableItem>
    
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    let connectionID: String
    let connection: AppConnection
    
    init(appConnection: AppConnection) {
        connection = appConnection
        connectionID = appConnection.clientPubKey
        var wSelf: SettingsConnectedAppController?
        
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
                (cell as? RemoteSignerConnectionInfoActionCell)?.configure(connection: connection, lastStart: lastStart, isActive: lastSession != nil && lastSession?.sessionEndedAt == nil, delegate: wSelf)
            case .autoStart(let connection):
                (cell as? RemoteSignerConnectionAutostartCell)?.configure(connection: connection, delegate: wSelf)
            case .trust(let level, let connection):
                (cell as? RemoteSignerConnectionTrustCell)?.configure(trustLevel: level.appLevel, connection: connection, delegate: wSelf)
            case .permissionDetails:
                (cell as? RemoteSignerConnectionSimpleAccentCell)?.configureWithText("Permission Details")
            case .session(let session):
                (cell as? RemoteSignerConnectionSessionCell)?.configure(session: session)
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
        tableView.register(RemoteSignerConnectionInfoActionCell.self, forCellReuseIdentifier: RemoteSignerConnectionInfoActionCell.reuseID)
        tableView.register(RemoteSignerConnectionAutostartCell.self, forCellReuseIdentifier: RemoteSignerConnectionAutostartCell.reuseID)
        tableView.register(RemoteSignerConnectionTrustCell.self, forCellReuseIdentifier: RemoteSignerConnectionTrustCell.reuseID)
        tableView.register(RemoteSignerConnectionSimpleAccentCell.self, forCellReuseIdentifier: RemoteSignerConnectionSimpleAccentCell.reuseID)
        tableView.register(RemoteSignerConnectionSessionCell.self, forCellReuseIdentifier: RemoteSignerConnectionSessionCell.reuseID)
        
        tableView.delegate = self
        
        Publishers.CombineLatest(
            RemoteSigningManager.instance.sessionRepo.observeSessionsByClientPubKey(clientPubKey: connectionID).toPublisher(),
            RemoteSigningManager.instance.connectionRepo.observeConnection(clientPubKey: connectionID).toPublisher()
        )
        .map { ($0.0 as [AppSession], $0.1) }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] sessions, connection in
            guard let connection else { return }
            
            var snapshot = NSDiffableDataSourceSnapshot<TableSections, TableItem>()
            snapshot.appendSections([.main, .permissions, .sessions])
            
            snapshot.appendItems([.mainInfo(connection, lastSession: sessions.first), .autoStart(connection)], toSection: .main)
            
            snapshot.appendItems([.trust(.full, connection), .trust(.medium, connection), .trust(.low, connection), .permissionDetails], toSection: .permissions)
            
            snapshot.appendItems(sessions.map({ .session($0) }), toSection: .sessions)
            
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
extension SettingsConnectedAppController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snapshot = dataSource.snapshot()
        guard let sectionId = snapshot.sectionIdentifiers[safe: indexPath.section], let item = snapshot.itemIdentifiers(inSection: sectionId)[safe: indexPath.row] else {
            return
        }
        
        switch item {
        case .permissionDetails:
            show(SettingsConnectedAppPermissionsController(connectionId: connectionID), sender: nil)
        case .session(let session):
            showErrorMessage("Not ready to show session \(session.sessionId)")
        default: return
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let tableSection = TableSections(rawValue: section) else { return nil }

        switch tableSection {
        case .main:
            return nil
        case .permissions:
            return UILabel("PERMISISONS", color: .foreground, font: .appFont(withSize: 16, weight: .semibold))
        case .sessions:
            return UILabel("RECENT SESSIONS", color: .foreground, font: .appFont(withSize: 16, weight: .semibold))
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let tableSection = TableSections(rawValue: section) else { return 0.01 }

        switch tableSection {
        case .main:
            return 0.01
        case .permissions:
            return 40
        case .sessions:
            return 40
        }
    }
}

extension SettingsConnectedAppController: RemoteSignerConnectionAutostartCellDelegate, RemoteSignerConnectionInfoActionCellDelegate, RemoteSignerConnectionTrustCellDelegate {
    func trustSelected(_ trustLevel: PrimalShared.TrustLevel) {
        Task {
            try? await RemoteSigningManager.instance.connectionRepo.updateTrustLevel(clientPubKey: connectionID, trustLevel: trustLevel)
        }
    }
    
    func autostartChanged(_ isOn: Bool) {
        Task {
            try? await RemoteSigningManager.instance.connectionRepo.updateConnectionAutoStart(clientPubKey: connectionID, autoStart: isOn)
        }
    }

    func deleteConnection() {
        let alert = UIAlertController(title: "Are you sure?", message: "Delete this connection?", preferredStyle: .alert)
        alert.addAction(.init(title: "Cancel", style: .cancel))
        alert.addAction(.init(title: "Delete", style: .destructive, handler: { [weak self] _ in
            guard let self else { return }
            
            navigationController?.popViewController(animated: true)
            Task { @MainActor in
                do {
                    try await RemoteSigningManager.instance.connectionRepo.deleteConnectionAndData(clientPubKey: self.connectionID)
                } catch {
                    print(error)
                }
            }
        }))
        present(alert, animated: true)
    }

    func editName() {
        show(SettingsEditConnectionName(connection: connection), sender: nil)
    }

    func startStopSession() {
        showErrorMessage("Unable to start/stop session")
        
        Task {
            try? await RemoteSigningManager.instance.sessionRepo.startSession(clientPubKey: connectionID)
            try? await RemoteSigningManager.instance.sessionRepo.endSessions(sessionIds: [])
        }

    }
}
