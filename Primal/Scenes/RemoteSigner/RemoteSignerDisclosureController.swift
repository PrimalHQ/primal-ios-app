//
//  RemoteSignerDisclosureController.swift
//  Primal
//
//  Created by Pavle Stevanović on 18. 12. 2025..
//

import UIKit
import Combine
import PrimalShared
import Kingfisher

protocol RemoteSignerDisclosureApp {
    var name: String? { get }
    var image: String? { get }
}

extension RemoteSignerDisclosureApp {
    func defaultImage(size: CGFloat, color: UIColor = .foreground3, background: UIColor = .foreground.withAlphaComponent(0.1)) -> UIImage? {
        return UIImage.create(letter: String(self.name?.first ?? "?"), size: size, color: color, backgroundColor: background)
    }
}

extension RemoteAppConnection: RemoteSignerDisclosureApp { }
extension RemoteAppSession: RemoteSignerDisclosureApp { }
struct CustomRemoteSignerDisclosureApp: RemoteSignerDisclosureApp {
    var name: String?
    var image: String?
}

@available(iOS 16.1, *)
class RemoteSignerDisclosureController: UIViewController {

    var cancellables: Set<AnyCancellable> = []
    
    let designHeight: CGFloat = 556
    
    let connection: RemoteSignerDisclosureApp
    let callback: () -> Void
    var didCallCallback = false
    init(connection: RemoteSignerDisclosureApp, callback: @escaping () -> Void) {
        self.connection = connection
        self.callback = callback
        super.init(nibName: nil, bundle: nil)
        
        let realWidth = RootViewController.instance.view.frame.size.width
        preferredContentSize = .init(width: realWidth, height: (designHeight * (realWidth / 375)) - 35)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if !didCallCallback {
            callback()
            didCallCallback = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background3
        
        let name = connection.name ?? "Application"
        let titleLabel = UILabel(name, color: .foreground, font: .appFont(withSize: 18, weight: .bold))
        let activeLabel = UILabel("Session active with \(name)", color: .init(rgb: 0x52CE0A), font: .appFont(withSize: 16, weight: .regular))
        
        let iconView = UIImageView().constrainToSize(48)
        iconView.kf.setImage(
            with: URL(string: connection.image ?? ""),
            placeholder: connection.defaultImage(size: 48),
            options: [.processor(RoundCornerImageProcessor(radius: .heightFraction(0.5)))]
        )
        
        let topStack = UIStackView(axis: .vertical, [SpacerView(height: 32), iconView, titleLabel, activeLabel, SpacerView(height: 20)])
        topStack.alignment = .center
        topStack.setCustomSpacing(8, after: iconView)
        
        let topStackParent = UIView()
        topStackParent.backgroundColor = .background4
        topStackParent.addSubview(topStack)
        topStack.pinToSuperview()
        
//        let contentScroll = UIScrollView()
//        contentScroll.showsVerticalScrollIndicator = false
        
        let switchView = SettingsSwitchView("Enable Ambient Sound")
        switchView.backgroundColor = .background5
        switchView.label.textColor = .foreground3
        switchView.switchView.isOn = true
        
        let doneButton = UIButton(configuration: .accentPill(text: "Let's Go", font: .appFont(withSize: 16, weight: .semibold))).constrainToSize(height: 40)
        
        let botStack = UIStackView(axis: .vertical, [switchView, doneButton])
        botStack.isLayoutMarginsRelativeArrangement = true
        botStack.layoutMargins = .init(top: 16, left: 24, bottom: 0, right: 24)
        botStack.spacing = 20
        
        let dynamicImage = UIImageView(image: .Signer.dynamicIslandVisual).constrainToAspect(5.31667)
        let contentStack = UIStackView(axis: .vertical, [
            SpacerView(height: 8),
            SpacerView(height: 8),
            UILabel("To keep running while Primal is in the background, we need to play ambient sound when you lock your phone or switch apps.", color: .foreground3, font: .appFont(withSize: 16, weight: .regular), multiline: true),
            SpacerView(height: 20),
            dynamicImage,
            SpacerView(height: 20),
            UILabel("Sound settings are adjustable in the dynamic island and on the lock screen.", color: .foreground3, font: .appFont(withSize: 16, weight: .regular), multiline: true),
            SpacerView(height: 6),
            SpacerView(height: 6)
        ])
        contentStack.distribution = .equalSpacing
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = .init(top: 0, left: 28, bottom: 0, right: 28)
        
        let mainStack = UIStackView(axis: .vertical, [topStackParent, SpacerView(height: 1, color: .foreground6), contentStack, botStack])
        
        let contentView = UIView().constrainToSize(width: 375, height: designHeight)
        contentView.addSubview(mainStack)
        mainStack.pinToSuperview()
        
        let realWidth = RootViewController.instance.view.frame.size.width
        contentView.transform = .init(scaleX: realWidth / 375, y: realWidth / 375)
        
        view.addSubview(contentView)
        contentView.centerToSuperview()
        contentView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 375 / realWidth).isActive = true
        
        switchView.switchView.addAction(.init(handler: { [weak switchView, weak self] _ in
            if switchView?.switchView.isOn == false {
                let alert = UIAlertController(title: "Are you sure?", message: "If you disable ambient sound, you will need to keep Primal open during your remote session.", preferredStyle: .alert)
                alert.addAction(.init(title: "Cancel", style: .cancel, handler: { _ in
                    switchView?.switchView.isOn = true
                }))
                alert.addAction(.init(title: "Disable", style: .destructive))
                self?.present(alert, animated: true)
            }
        }), for: .valueChanged)
        
        doneButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            
            if switchView.switchView.isOn {
                RemoteSignerActivityManager.instance.isAudioAllowed = true
                RemoteSignerActivityManager.instance.playSong()
            }
            dismiss(animated: true)
        }), for: .touchUpInside)
    }
}
