//
//  RemoteSignerDisclosureController.swift
//  Primal
//
//  Created by Pavle Stevanović on 18. 12. 2025..
//

import UIKit
import Combine
import PrimalShared

@available(iOS 16.1, *)
class RemoteSignerDisclosureController: UIViewController {

    var cancellables: Set<AnyCancellable> = []
    
    let session: AppSession
    init(session: AppSession) {
        self.session = session
        super.init(nibName: nil, bundle: nil)
        
        preferredContentSize = .init(width: 400, height: 580)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = .background4
        
        let name = session.name ?? "Application"
        let titleLabel = UILabel(name, color: .foreground, font: .appFont(withSize: 18, weight: .bold))
        let activeLabel = UILabel("Session active with \(name)", color: .init(rgb: 0x52CE0A), font: .appFont(withSize: 14, weight: .regular))
        
        let iconView = UIImageView().constrainToSize(48)
        iconView.kf.setImage(with: URL(string: session.image ?? ""), placeholder: session.defaultImage(size: 48))
        
        let topStack = UIStackView(axis: .vertical, [SpacerView(height: 32), iconView, titleLabel, activeLabel, SpacerView(height: 20)])
        topStack.alignment = .center
        topStack.setCustomSpacing(8, after: iconView)
        
        let contentScroll = UIScrollView()
        
        let switchView = SettingsSwitchView("Enable Ambient Sound")
        switchView.label.textColor = .foreground3
        switchView.switchView.isOn = true
        
        let doneButton = UIButton(configuration: .accentPill(text: "Let's Go", font: .appFont(withSize: 16, weight: .semibold))).constrainToSize(height: 40)
        
        let botStack = UIStackView(axis: .vertical, [switchView, doneButton])
        botStack.isLayoutMarginsRelativeArrangement = true
        botStack.layoutMargins = .init(top: 16, left: 24, bottom: 4, right: 24)
        botStack.spacing = 32
        
        let mainStack = UIStackView(axis: .vertical, [topStack, SpacerView(height: 1, color: .foreground6), contentScroll, botStack])
        view.addSubview(mainStack)
        mainStack.pinToSuperview()
        
        let dynamicImage = UIImageView(image: .Signer.dynamicIslandVisual).constrainToAspect(6.7872340426)
//        let lockScreenImage = UIImageView(image: .Signer.lockScreenVisual).constrainToAspect(2.6363636364)
        
        let leftContentStack = UIStackView(axis: .vertical, [
            UILabel("To keep running while Primal is in the background, we need to play ambient sound when you lock your phone or switch apps.", color: .foreground3, font: .appFont(withSize: 16, weight: .regular), multiline: true),
            SpacerView(height: 28),
            dynamicImage,
//            SpacerView(height: 16),
//            lockScreenImage,
            SpacerView(height: 28),
            UILabel("Settings are adjustable in the dynamic island and on the lock screen.", color: .foreground3, font: .appFont(withSize: 16, weight: .regular), multiline: true),
        ])
        contentScroll.addSubview(leftContentStack)
        leftContentStack.pinToSuperview(padding: 24)
        
        leftContentStack.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -48).isActive = true
        
        doneButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            
            if switchView.switchView.isOn {
                RemoteSessionActivityManager.instance.isAudioAllowed = true
            }
            dismiss(animated: true)
        }), for: .touchUpInside)
    }
}
