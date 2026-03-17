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
        case events
    }
    
    enum TableItem: Hashable {
        case sessionInfo(RemoteAppSession)
        case eventInfo(SessionEvent)
        case empty
        
        var cellId: String {
            switch self {
            case .sessionInfo:
                return RemoteSignerConnectionInfoCell.reuseID
            case .eventInfo:
                return RemoteSignerEventCell.reuseID
            case .empty:
                return "empty"
            }
        }
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    let dataSource: UITableViewDiffableDataSource<TableSections, TableItem>
    
    private let sessionId: String
    private var session: RemoteAppSession
    private var events: [SessionEvent] = []
    
    init(session: RemoteAppSession) {
        self.session = session
        self.sessionId = session.sessionId
        
        dataSource = UITableViewDiffableDataSource<TableSections, TableItem>(tableView: tableView) { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: item.cellId, for: indexPath)
            
            switch item {
            case .sessionInfo(let session):
                (cell as? RemoteSignerConnectionInfoCell)?.configure(session: session)
            case .eventInfo(let event):
                (cell as? RemoteSignerEventCell)?.configure(event: event)
            case .empty:
                (cell as? EmptyMuteListCell)?.label.text = "No session events yet"
            }
            
            return cell
        }
        dataSource.defaultRowAnimation = .none
        
        super.init(nibName: nil, bundle: nil)
        
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
        tableView.contentInset = .init(top: -10, left: 0, bottom: 60, right: 0)
        
        tableView.register(RemoteSignerConnectionInfoCell.self, forCellReuseIdentifier: RemoteSignerConnectionInfoCell.reuseID)
        tableView.register(RemoteSignerEventCell.self, forCellReuseIdentifier: RemoteSignerEventCell.reuseID)
        tableView.register(EmptyMuteListCell.self, forCellReuseIdentifier: "empty")
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<TableSections, TableItem>()
        snapshot.appendSections([.main, .events])
        
        snapshot.appendItems([.sessionInfo(session)], toSection: .main)
        if events.isEmpty {
            snapshot.appendItems([.empty], toSection: .events)
        } else {
            snapshot.appendItems(events.map { .eventInfo($0) }, toSection: .events)
        }
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Data
private extension SettingsRemoteSessionController {
    func bindData() {
        // Observe updates to the specific session
        let sessionPub = RemoteSignerManager.instance.sessionRepo
            .observeRemoteSession(sessionId: sessionId)
            .toPublisher()
        
        let eventsPub = RemoteSignerManager.instance.sessionEventRepo
            .observeCompletedEventsForRemoteSession(sessionId: sessionId)
            .toPublisher()
        
        Publishers.CombineLatest(sessionPub, eventsPub)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] session, events in
                guard let self else { return }
                
                self.session = session ?? self.session
                self.events = events
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
        case .empty, .sessionInfo:
            break
        case .eventInfo(let event):
            show(SettingsRemoteEventController(event: event), sender: nil)
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
