//
//  LiveVideoConfigController.swift
//  Primal
//
//  Created by Pavle Stevanović on 25. 8. 2025..
//

import UIKit
import Nantes
import SafariServices

class LiveVideoConfigController: UIViewController, Themeable {
    let live: ParsedLiveEvent
    weak var chatVC: LiveVideoChatController?
    init(live: ParsedLiveEvent, chatVC: LiveVideoChatController?) {
        self.live = live
        self.chatVC = chatVC
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    var userForDetails: ParsedUser { live.user }
    
    private let pullbar = PullBarView(color: .foreground5.withAlphaComponent(0.8))
    private lazy var notifView = SimpleInfoSwitch(title: "Stream Notifications", subtitle: "Notify me about live streams from this account")
    private lazy var filterView = SimpleInfoSwitch(title: "Chat Filtering", subtitle: "Exclude messages from accounts muted by the stream host, and potential spam")
    
    private let border = SpacerView(height: 1, color: .foreground6)
    
    private let backgroundExtender = SpacerView(height: 200, priority: .required)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 16
        
        let mainStack = UIStackView(axis: .vertical, [
            pullbar,
            notifView,
            border,
            filterView
        ])
        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .top, padding: 12)
            .pinToSuperview(edges: .horizontal, padding: 20)
        
        mainStack.setCustomSpacing(8, after: pullbar)
        
        if let chatVC {
            filterView.switchView.isOn = chatVC.isFilteringOn
            filterView.switchView.addAction(.init(handler: { [weak self] _ in
                guard let self else { return }
                self.chatVC?.isFilteringOn = self.filterView.switchView.isOn
            }), for: .valueChanged)
        } else {
            filterView.isHidden = true
        }
        
        notifView.switchView.isOn = !LiveMuteManager.instance.isMuted(live.user.data.pubkey)
        notifView.switchView.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            LiveMuteManager.instance.toggleMuted(self.live.user.data.pubkey)
        }), for: .valueChanged)
        
        view.addSubview(backgroundExtender)
        backgroundExtender.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .bottom, padding: -200)
        
        updateTheme()
        
        view.addGestureRecognizer(LivePopupDismissGesture(vc: self))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func updateTheme() {
        view.backgroundColor = .background4
        backgroundExtender.backgroundColor = .background4
        
        pullbar.pullBar.backgroundColor = .foreground5.withAlphaComponent(0.8)
        
    }
}

class SimpleInfoSwitch: UIStackView, Themeable {
    private lazy var titleLabel = UILabel("", color: .foreground, font: .appFont(withSize: 18, weight: .semibold))
    private lazy var infoLabel = UILabel("Exclude messages from accounts muted by the stream host, and potential spam", color: .foreground3, font: .appFont(withSize: 15, weight: .regular))
    
    let switchView = UISwitch()

    init(title: String, subtitle: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        infoLabel.text = subtitle
        infoLabel.numberOfLines = 0
        
        switchView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        let stack = UIStackView([infoLabel, switchView])
        stack.spacing = 24
        stack.alignment = .center
        
        addArrangedSubview(titleLabel)
        addArrangedSubview(stack)
        spacing = 8
        axis = .vertical
        
        isLayoutMarginsRelativeArrangement = true
        insetsLayoutMarginsFromSafeArea = false
        layoutMargins = .init(top: 24, left: 12, bottom: 24, right: 12)
        
        updateTheme()
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        titleLabel.textColor = .foreground
        infoLabel.textColor = .foreground3
        switchView.onTintColor = .accent
    }
}
