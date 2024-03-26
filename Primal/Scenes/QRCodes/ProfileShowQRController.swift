//
//  ProfileShowQRController.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.11.23..
//

import Combine
import Kingfisher
import UIKit

final class QRCodeActionButton: UIButton {
    init(_ title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font  = .appFont(withSize: 18, weight: .semibold)
        backgroundColor = .init(rgb: 0x4B002D)
        layer.cornerRadius = 29
        constrainToSize(height: 58)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class ProfileShowQRController: UIViewController, OnboardingViewController {
    var titleLabel: UILabel = .init()
    var backButton: UIButton = .init()
    
    let userInfo = OnboardingProfileInfoView()
    let qrCodeView = UIImageView()
    let npubLabel = UILabel()
    let action = QRCodeActionButton("Scan QR Code")
    
    lazy var scanController = ProfileScanQRController()
    
    private var cancellables: Set<AnyCancellable> = []
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
}

private extension ProfileShowQRController {
    func setup() {
        addBackground(1, clipToLeft: false)
        backButton.addAction(.init(handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }), for: .touchUpInside)
               
        let qrParent = UIView()
        qrParent.layer.cornerRadius = 16
        qrParent.layer.borderWidth = 4
        qrParent.layer.borderColor = UIColor.white.cgColor
        qrParent.addSubview(qrCodeView)
        qrCodeView.pinToSuperview(padding: 4)
        NSLayoutConstraint.activate([
            qrCodeView.heightAnchor.constraint(equalTo: qrCodeView.widthAnchor),
            qrCodeView.heightAnchor.constraint(lessThanOrEqualToConstant: 280)
        ])
        
        let stack = UIStackView(axis: .vertical, [
            SpacerView(height: 70, priority: .init(1)),
            userInfo,   SpacerView(height: 12),
            qrParent,   SpacerView(height: 4),
            npubLabel,  SpacerView(height: 12),
            UIView(),
            action
        ])
        stack.alignment = .center
        stack.isHidden = true
        
        action.pinToSuperview(edges: .horizontal)
        
        npubLabel.pin(to: qrParent, edges: .horizontal, padding: 20)
        npubLabel.lineBreakMode = .byTruncatingMiddle
        npubLabel.textColor = .white
        npubLabel.font = .appFont(withSize: 16, weight: .regular)
        
        view.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 35).pinToSuperview(edges: .top, padding: 34).pinToSuperview(edges: .bottom, padding: 60, safeArea: true)
        
        addNavigationBar("")
        backButton.isHidden = false
        
        action.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            let scan = (self.onboardingParent as? ProfileQRController)?.scanController ?? self.scanController
            self.onboardingParent?.pushViewController(scan, animated: true)
        }), for: .touchUpInside)
        
        IdentityManager.instance.$user.receive(on: DispatchQueue.main).sink { [weak self] user in
            guard let user else { return }
            self?.update(user)
            stack.isHidden = false
        }
        .store(in: &cancellables)
    }
    
    func update(_ user: PrimalUser) {
        userInfo.image.kf.setImage(with: URL(string: user.picture), placeholder: UIImage(named: "onboardingDefaultAvatar")?.withAlpha(alpha: 0.5), options: [
            .processor(DownsamplingImageProcessor(size: CGSize(width: 108, height: 108))),
            .scaleFactor(UIScreen.main.scale),
            .cacheOriginalImage
        ])
        userInfo.name.text = user.firstIdentifier
        userInfo.address.text = user.lud16
        
        npubLabel.text = user.npub
        
        let normalImage = UIImage.createQRCode("nostr:\(user.npub)", dimension: 280)
        qrCodeView.image = normalImage
        
        guard let alteredImage = normalImage?.maskWhiteColor(color: .clear) else { return }
        
        qrCodeView.image = alteredImage.withRenderingMode(.alwaysTemplate)
        qrCodeView.tintColor = .white
    }
}
