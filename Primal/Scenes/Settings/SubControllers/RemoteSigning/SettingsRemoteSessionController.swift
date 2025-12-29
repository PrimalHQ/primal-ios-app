//
//  SettingsRemoteSessionController.swift
//  Primal
//
//  Created by Pavle Stevanović on 29. 12. 2025..
//

import Combine
import UIKit
import PrimalShared

final class SettingsRemoteSessionController: UIViewController {
    
    enum TableSections: Int, CaseIterable {
        case main
        case connection
        case actions
    }
    
    enum TableItem: Hashable {
        case sessionInfo(RemoteAppSession)
        case connectionInfo(RemoteAppConnection, lastSession: RemoteAppSession?)
        case endSession(RemoteAppSession)
        
        var cellId: String {
            switch self {
            case .sessionInfo:
                return RemoteSignerConnectionSessionCell.reuseID
            case .connectionInfo:
                return RemoteSignerConnectionInfoActionCell.reuseID
            case .endSession:
                return RemoteSignerConnectionSimpleAccentCell.reuseID
            }
        }
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    let dataSource: UITableViewDiffableDataSource<TableSections, TableItem>
    
    private let sessionId: String
    private let initialSession: RemoteAppSession
    
    // Cached values to build the snapshot
    private var currentSession: RemoteAppSession
    private var parentConnection: RemoteAppConnection?
    private var recentSessionsForConnection: [RemoteAppSession] = []
    
    init(session: RemoteAppSession) {
        self.initialSession = session
        self.currentSession = session
        self.sessionId = session.sessionId
        
        var wSelf: SettingsRemoteSessionController?
        
        dataSource = UITableViewDiffableDataSource<TableSections, TableItem>(tableView: tableView) { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: item.cellId, for: indexPath)
            
            switch item {
            case .sessionInfo(let session):
                (cell as? RemoteSignerConnectionSessionCell)?.configure(session: session)
            case .connectionInfo(let connection, let lastSession):
                var lastStart: Date?
                if let start = lastSession?.sessionStartedAt {
                    lastStart = .init(timeIntervalSince1970: TimeInterval(start))
                }
                (cell as? RemoteSignerConnectionInfoActionCell)?.configure(
                    connection: connection,
                    lastStart: lastStart,
                    isActive: lastSession != nil && lastSession?.sessionEndedAt == nil,
                    delegate: wSelf
                )
            case .endSession:
                (cell as? RemoteSignerConnectionSimpleAccentCell)?.configureWithText("End Session")
            }
            
            return cell
        }
        dataSource.defaultRowAnimation = .none
        
        super.init(nibName: nil, bundle: nil)
        
        wSelf = self
        title = "Session Details"
        
        setupUI()
        bindData()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - UI
private extension SettingsRemoteSessionController {
    func setupUI() {
        updateTheme()
        navigationItem.backButtonDisplayMode = .default
        
        view.addSubview(tableView)
        tableView.pinToSuperview(safeArea: true)
        
        tableView.delegate = self
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.contentInset = .init(top: 20, left: 0, bottom: 60, right: 0)
        
        tableView.register(RemoteSignerConnectionSessionCell.self, forCellReuseIdentifier: RemoteSignerConnectionSessionCell.reuseID)
        tableView.register(RemoteSignerConnectionInfoActionCell.self, forCellReuseIdentifier: RemoteSignerConnectionInfoActionCell.reuseID)
        tableView.register(RemoteSignerConnectionSimpleAccentCell.self, forCellReuseIdentifier: RemoteSignerConnectionSimpleAccentCell.reuseID)
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<TableSections, TableItem>()
        snapshot.appendSections([.main, .connection, .actions])
        
        snapshot.appendItems([.sessionInfo(currentSession)], toSection: .main)
        
        if let connection = parentConnection {
            let last = recentSessionsForConnection.first
            snapshot.appendItems([.connectionInfo(connection, lastSession: last)], toSection: .connection)
        }
        
        if currentSession.sessionEndedAt == nil {
            snapshot.appendItems([.endSession(currentSession)], toSection: .actions)
        }
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Data
private extension SettingsRemoteSessionController {
    func bindData() {
        // Observe updates to the specific session
        let sessionPub = RemoteSignerManager.instance.sessionRepo
            .observeSession(sessionId: sessionId)
            .toPublisher()
        
        // Observe parent connection and its recent sessions
        // We derive clientPubKey from the initial session to subscribe to relevant streams.
        let clientPubKey = initialSession.clientPubKey
        
        let connectionPub = RemoteSignerManager.instance.connectionRepo
            .observeConnection(clientPubKey: clientPubKey)
            .toPublisher()
        
        let sessionsForConnectionPub = RemoteSignerManager.instance.sessionRepo
            .observeSessionsByClientPubKey(clientPubKey: clientPubKey)
            .toPublisher()
        
        Publishers.CombineLatest3(sessionPub, connectionPub, sessionsForConnectionPub)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] session, connection, sessions in
                guard let self else { return }
                if let session { self.currentSession = session }
                self.parentConnection = connection
                self.recentSessionsForConnection = sessions
                self.applySnapshot()
            }
            .store(in: &cancellables)
    }
}

// MARK: - Theme
extension SettingsRemoteSessionController: Themeable {
    func updateTheme() {
        navigationItem.leftBarButtonItem = customBackButton
        tableView.backgroundColor = .background
        tableView.reloadData()
    }
}

// MARK: - Delegate
extension SettingsRemoteSessionController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snapshot = dataSource.snapshot()
        guard
            let sectionId = snapshot.sectionIdentifiers[safe: indexPath.section],
            let item = snapshot.itemIdentifiers(inSection: sectionId)[safe: indexPath.row]
        else { return }
        
        switch item {
        case .endSession(let session):
            confirmEndSession(session)
        case .connectionInfo(let connection, _):
            show(SettingsConnectedAppController(appConnection: connection), sender: nil)
        case .sessionInfo:
            // Could push a deeper detail if desired
            break
        }
    }
    
    private func confirmEndSession(_ session: RemoteAppSession) {
        let alert = UIAlertController(
            title: "End Session?",
            message: "Are you sure you want to end this session?",
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "Cancel", style: .cancel))
        alert.addAction(.init(title: "End", style: .destructive, handler: { _ in
            Task {
                _ = try? await RemoteSignerManager.instance.sessionRepo.endSessions(sessionIds: [session.sessionId])
            }
        }))
        present(alert, animated: true)
    }
}

// MARK: - Bridge actions from connection info cell (edit name / delete / start-stop)
extension SettingsRemoteSessionController: RemoteSignerConnectionInfoActionCellDelegate {
    func deleteConnection() {
        guard let connection = parentConnection else { return }
        let alert = UIAlertController(title: "Are you sure?", message: "Delete this connection?", preferredStyle: .alert)
        alert.addAction(.init(title: "Cancel", style: .cancel))
        alert.addAction(.init(title: "Delete", style: .destructive, handler: { [weak self] _ in
            guard let self else { return }
            self.navigationController?.popViewController(animated: true)
            Task { @MainActor in
                try? await RemoteSignerManager.instance.connectionRepo.deleteConnectionAndData(clientPubKey: connection.clientPubKey)
            }
        }))
        present(alert, animated: true)
    }
    
    func editName() {
        guard let connection = parentConnection else { return }
        show(SettingsEditConnectionName(connection: connection), sender: nil)
    }
    
    func startStopSession() {
        guard let connection = parentConnection else { return }
        let repo = RemoteSignerManager.instance.sessionRepo
        
        Task {
            do {
                if currentSession.sessionEndedAt == nil {
                    _ = try await repo.endSessions(sessionIds: [currentSession.sessionId])
                } else {
                    _ = try await repo.startSession(clientPubKey: connection.clientPubKey)
                }
            }
        }
    }
}

