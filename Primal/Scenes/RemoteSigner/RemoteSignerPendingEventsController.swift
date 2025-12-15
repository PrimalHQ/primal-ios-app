//
//  RemoteSignerPendingEventsController.swift
//  Primal
//
//  Created by Pavle Stevanović on 10. 12. 2025..
//

import Combine
import UIKit
import PrimalShared

class RemoteSignerPendingEventsController: UIViewController {
    
    var cancellables: Set<AnyCancellable> = []
    
    @Published var allEvents = [SessionEvent]()
    @Published var selectedEvents = Set<String>()
    
    let sessionId: String
    
    let table = UITableView(frame: .zero, style: .insetGrouped)
    let alwaysSwitch = UISwitch()
    
    init(sessionId: String, events: [SessionEvent]) {
        allEvents = events
        selectedEvents = Set(events.map { $0.eventId })
        self.sessionId = sessionId
        alwaysSwitch.isOn = true
        super.init(nibName: nil, bundle: nil)
        
        preferredContentSize = .init(width: 400, height: 290)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = .background4
        
        table.dataSource = self
        table.delegate = self
        table.register(RemoteSignerEventSelectionCell.self, forCellReuseIdentifier: "cell")
        table.backgroundColor = .clear
        table.contentInsetAdjustmentBehavior = .never
        table.contentInset = .init(top: -20, left: 0, bottom: 0, right: 0)
        
        let appIcon = UIImageView().constrainToSize(40)
        let appTitleLabel = UILabel("", color: .foreground, font: .appFont(withSize: 18, weight: .bold))
        let appStack = UIStackView(axis: .vertical, [appIcon, appTitleLabel])
        appStack.spacing = 10
        appStack.alignment = .center
        
        let titleLabel = UILabel("App Requests:", color: .foreground3, font: .appFont(withSize: 16, weight: .regular))
        let selectButton = UIButton(configuration: .accent("Select All", font: .appFont(withSize: 16, weight: .regular)))
        
        let topStack = UIStackView([titleLabel, selectButton])
        topStack.alignment = .center
        topStack.isLayoutMarginsRelativeArrangement = true
        topStack.layoutMargins = .init(top: 16, left: 26, bottom: 0, right: 26)
        
        let rejectButton = UIButton()
        rejectButton.setAttributedTitle(.init(string: "Reject Selected", attributes: [
            .foregroundColor: UIColor.foreground3,
            .font: UIFont.appFont(withSize: 16, weight: .semibold)
        ]), for: .normal)
        rejectButton.layer.cornerRadius = 20
        rejectButton.layer.borderWidth = 1
        rejectButton.layer.borderColor = UIColor.foreground6.cgColor
        let approveButton = UIButton(configuration: .accentPill(text: "Allow Selected", font: .appFont(withSize: 16, weight: .semibold)))
        let buttonStack = UIStackView([rejectButton, approveButton]).constrainToSize(height: 40)
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        
        let switchParent = UIView()
        let switchStack = UIStackView([UILabel("Always handle requests like this", color: .foreground3, font: .appFont(withSize: 16, weight: .regular)), alwaysSwitch])
        switchStack.alignment = .center
        switchParent.addSubview(switchStack)
        switchStack.pinToSuperview(edges: .horizontal, padding: 12).pinToSuperview(edges: .vertical, padding: 9)
        switchParent.backgroundColor = .background5
        switchParent.layer.cornerRadius = 12
        
        let buttonsSuperstack = UIStackView(axis: .vertical, [switchParent, buttonStack])
        buttonsSuperstack.spacing = 40
        
        let buttonsParent = UIView()
        buttonsParent.addSubview(buttonsSuperstack)
        buttonsSuperstack.pinToSuperview(edges: .horizontal, padding: 24).pinToSuperview(edges: .top, padding: 16).pinToSuperview(edges: .bottom, padding: 4, safeArea: true)
        
        let mainStack = UIStackView(axis: .vertical, [appStack, SpacerView(height: 16), SpacerView(height: 1, color: .background3), topStack, table, buttonsParent])
        view.addSubview(mainStack)
        mainStack.pinToSuperview(edges: [.horizontal, .bottom]).pinToSuperview(edges: .top, padding: 32)
        
        RemoteSigningManager.instance.sessionRepo.observeSession(sessionId: sessionId).toPublisher().first()
            .receive(on: DispatchQueue.main)
            .sink { session in
                appIcon.kf.setImage(with: URL(string: session?.image ?? ""), placeholder: session?.defaultImage(size: 40))
                appTitleLabel.text = session?.name
            }
            .store(in: &cancellables)
        
        $allEvents
            .sink { [weak self] events in
                if self?.selectedEvents.contains(where: { id in !events.contains(where: { $0.eventId == id }) }) ?? false {
                    self?.selectedEvents = self?.selectedEvents.filter { id in events.contains(where: { $0.eventId == id }) } ?? []
                }
                
                self?.preferredContentSize = .init(width: 400, height: 350 + 64 * events.count)
                self?.parent?.sheetPresentationController?.invalidateDetents()
                
                if events.isEmpty {
                    self?.dismiss(animated: true)
                }
                
                self?.table.reloadData()
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest($selectedEvents, $allEvents.map { $0.map{ $0.eventId } })
            .debounce(for: 0.1, scheduler: DispatchQueue.main)
            .sink { [weak self] selected, all in
                self?.table.reloadData()
                
                selectButton.configuration = .accent(selected.count == all.count ? "Deselect All" : "Select All", font: .appFont(withSize: 16, weight: .regular))
                
                if selected.isEmpty {
                    approveButton.isEnabled = false
                    approveButton.configuration = .disabled("Allow Selected")
                    
                    rejectButton.layer.borderWidth = 0
                    rejectButton.setAttributedTitle(.init(string: "Reject Selected", attributes: [
                        .foregroundColor: UIColor.foreground5,
                        .font: UIFont.appFont(withSize: 16, weight: .semibold)
                    ]), for: .normal)
                    rejectButton.configuration = .disabled("Reject Selected")
                    rejectButton.isEnabled = false
                } else {
                    approveButton.isEnabled = true
                    approveButton.configuration = .accentPill(text: "Allow Selected", font: .appFont(withSize: 16, weight: .semibold))
                    
                    rejectButton.configuration = .plain()
                    rejectButton.layer.borderWidth = 1
                    rejectButton.isEnabled = true
                    
                    rejectButton.setAttributedTitle(.init(string: "Reject Selected", attributes: [
                        .foregroundColor: UIColor.foreground3,
                        .font: UIFont.appFont(withSize: 16, weight: .semibold)
                    ]), for: .normal)
                }
            }
            .store(in: &cancellables)
        
        selectButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            
            if self.selectedEvents.count == allEvents.count {
                self.selectedEvents = []
            } else {
                self.selectedEvents = Set(allEvents.map(\.eventId))
            }
        }), for: .touchUpInside)
        
        let sessionEventRepo = RemoteSigningManager.instance.sessionEventRepo
        rejectButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            
            let choice = alwaysSwitch.isOn ? UserChoice.alwaysReject : .reject
                
            Task {
                try await sessionEventRepo.respondToEvents(userChoices: self.selectedEvents.map({
                    .init(sessionEventId: $0, userChoice: choice)
                }))
            }
        }), for: .touchUpInside)
        
        approveButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            
            let choice = alwaysSwitch.isOn ? UserChoice.alwaysAllow : .allow
                
            Task {
                try await sessionEventRepo.respondToEvents(userChoices: self.selectedEvents.map({
                    .init(sessionEventId: $0, userChoice: choice)
                }))
            }
        }), for: .touchUpInside)
    }
}

extension RemoteSignerPendingEventsController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { section == 0 ? allEvents.count : 0 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if let event = allEvents[safe: indexPath.row] {
            (cell as? RemoteSignerEventSelectionCell)?.configure(event: event, selected: selectedEvents.contains(event.eventId), delegate: self)
        }
        
        return cell
    }
}

extension RemoteSignerPendingEventsController: RemoteSignerEventSelectionCellDelegate {
    func selectedToggledInCell(_ cell: RemoteSignerEventSelectionCell) {
        guard let index = table.indexPath(for: cell), let event = allEvents[safe: index.row] else { return }
        if selectedEvents.contains(event.eventId) {
            selectedEvents.remove(event.eventId)
        } else {
            selectedEvents.insert(event.eventId)
        }
    }
}

extension RemoteSignerPendingEventsController: UITableViewDelegate {
    
}

protocol RemoteSignerEventSelectionCellDelegate: AnyObject {
    func selectedToggledInCell(_ cell: RemoteSignerEventSelectionCell)
}

class RemoteSignerEventSelectionCell: UITableViewCell {
    let checkButton = CheckboxRadioButton().constrainToSize(40)
    let nameLabel = UILabel("", color: .foreground, font: .appFont(withSize: 16, weight: .regular))
    let dateLabel = UILabel("", color: .foreground4, font: .appFont(withSize: 14, weight: .regular))
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMM d, yyyy h:mm a")
        return formatter
    }()
    
    weak var delegate: RemoteSignerEventSelectionCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        separatorInset = .zero
        accessoryType = .disclosureIndicator
        
        let nameSuperStack = UIStackView(axis: .vertical, [nameLabel, dateLabel])
        nameSuperStack.spacing = 2
        nameSuperStack.alignment = .leading
        
        contentView.addSubview(nameSuperStack)
        nameSuperStack.pinToSuperview(edges: .leading, padding: 48).pinToSuperview(edges: .trailing, padding: 38).pinToSuperview(edges: .vertical, padding: 12)
        
        contentView.addSubview(checkButton)
        checkButton.centerToView(nameLabel, axis: .vertical).pinToSuperview(edges: .leading, padding: 4)
        
        backgroundColor = .background5
        
        checkButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            delegate?.selectedToggledInCell(self)
        }), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func configure(event: SessionEvent, selected: Bool, delegate: RemoteSignerEventSelectionCellDelegate?) {
        self.delegate = delegate
        checkButton.isSelected = selected
        nameLabel.text = RemoteSigningManager.instance.permissionsMap[event.requestTypeId] ?? event.requestTypeId
        dateLabel.text = Self.dateFormatter.string(from: .init(timeIntervalSince1970: TimeInterval(event.requestedAt)))
    }
}
