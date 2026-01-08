//
//  SettingsRemoteEventController.swift
//  Primal
//
//  Created by Pavle Stevanović on 29. 12. 2025..
//

import PrimalShared
import UIKit
import GenericJSON

class SettingsRemoteEventController: UIViewController {
    
    var event: SessionEvent
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(event: SessionEvent) {
        self.event = event
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Event Details"
        
        let title = RemoteSignerManager.instance.permissionsMap[event.requestTypeId] ?? event.requestTypeId
        let titleLabel = UILabel("\(title) - Event Details:", color: .foreground3, font: .appFont(withSize: 16, weight: .regular))
        let statusLabel = UILabel("", color: .foreground, font: .appFont(withSize: 14, weight: .regular))
        
        let date = Date(timeIntervalSince1970: Double(event.requestedAt))
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("MMM d, yyyy h:mm a")
        let subtitleLabel = UILabel(dateFormatter.string(from: date), color: .foreground3, font: .appFont(withSize: 14, weight: .regular))
        
        switch event.requestState {
        case .pending:
            statusLabel.text = "Pending"
            statusLabel.textColor = .foreground3
        case .approved:
            statusLabel.text = "Signed"
            statusLabel.textColor = .receiveMoney
        case .rejected:
            statusLabel.text = "Rejected by user"
            statusLabel.textColor = .gold
        }
        
        let topStack = UIStackView(axis: .vertical, [titleLabel, subtitleLabel, statusLabel])
        topStack.isLayoutMarginsRelativeArrangement = true
        topStack.layoutMargins = .init(top: 16, left: 24, bottom: 0, right: 24)
        
        let contentScroll = EventDetailsView(event: event)
        
        let approveButton = UIButton(configuration: .accentPill(text: "Copy Raw JSON", font: .appFont(withSize: 16, weight: .semibold))).constrainToSize(height: 40)
        let buttonsParent = UIView()
        buttonsParent.addSubview(approveButton)
        approveButton.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .top, padding: 16).pinToSuperview(edges: .bottom, padding: 64, safeArea: true)
        buttonsParent.isHidden = true
        
        // MARK: - Main Stack
        let mainStack = UIStackView(axis: .vertical, [topStack, contentScroll, buttonsParent])
        view.addSubview(mainStack)
        mainStack.pinToSuperview(edges: [.horizontal, .bottom]).pinToSuperview(edges: .top, padding: 32)
        
        updateTheme()
        
        if let json = (event as? SessionEvent.SignEvent)?.signedNostrEventJson, let actualJSON: JSON = json.decode() {
            buttonsParent.isHidden = false
            
            approveButton.addAction(.init(handler: { _ in
                RootViewController.instance.showToast("Copied!")
                UIPasteboard.general.string = json
            }), for: .touchUpInside)
        }
    }
}


// MARK: - Theme
extension SettingsRemoteEventController: Themeable {
    func updateTheme() {
        navigationItem.leftBarButtonItem = customBackButton
        view.backgroundColor = .background
    }
}
