//
//  RemoteSignerEventDetailsController.swift
//  Primal
//
//  Created by Pavle Stevanović on 25. 12. 2025..
//

import Combine
import UIKit
import PrimalShared

class RemoteSignerEventDetailsController: UIViewController {
    
    var cancellables: Set<AnyCancellable> = []
    
    let event: SessionEvent
    var sessionId: String { event.sessionId }
    
    let descTextView = UITextView()
    
    init(event: SessionEvent) {
        self.event = event
        super.init(nibName: nil, bundle: nil)
        
        preferredContentSize = .init(width: 400, height: 500)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = .background4
        
        
        
        let appIcon = UIImageView().constrainToSize(40)
        let appTitleLabel = UILabel("", color: .foreground, font: .appFont(withSize: 18, weight: .bold))
        let appStack = UIStackView(axis: .vertical, [appIcon, appTitleLabel])
        appStack.spacing = 10
        appStack.alignment = .center
        
        let title = RemoteSignerManager.instance.permissionsMap[event.requestTypeId] ?? event.requestTypeId
        let titleLabel = UILabel("Publish Note - \(title):", color: .foreground3, font: .appFont(withSize: 16, weight: .regular))
        let subtitleLabel = UILabel(event.requestedAt.localized(), color: .foreground3, font: .appFont(withSize: 14, weight: .regular))
        
        let topStack = UIStackView([titleLabel, subtitleLabel])
        topStack.alignment = .center
        topStack.isLayoutMarginsRelativeArrangement = true
        topStack.layoutMargins = .init(top: 16, left: 24, bottom: 0, right: 24)
        
        descTextView.backgroundColor = .background5
        descTextView.text = event.description
        
        let approveButton = UIButton(configuration: .accentPill(text: "Back", font: .appFont(withSize: 16, weight: .semibold)))
        let buttonsParent = UIView()
        buttonsParent.addSubview(approveButton)
        approveButton.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .top, padding: 16).pinToSuperview(edges: .bottom, padding: 4, safeArea: true)
        
        let mainStack = UIStackView(axis: .vertical, [appStack, SpacerView(height: 16), SpacerView(height: 1, color: .background3), topStack, descTextView, buttonsParent])
        view.addSubview(mainStack)
        mainStack.pinToSuperview(edges: [.horizontal, .bottom]).pinToSuperview(edges: .top, padding: 32)
        
        RemoteSignerManager.instance.sessionRepo.observeSession(sessionId: sessionId).toPublisher().first()
            .receive(on: DispatchQueue.main)
            .sink { session in
                appIcon.kf.setImage(with: URL(string: session?.image ?? ""), placeholder: session?.defaultImage(size: 40))
                appTitleLabel.text = session?.name
            }
            .store(in: &cancellables)
        
        approveButton.addAction(.init(handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }), for: .touchUpInside)
    }
}
