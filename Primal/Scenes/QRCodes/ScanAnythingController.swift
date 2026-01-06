//
//  ScanAnythingController.swift
//  Primal
//
//  Created by Pavle Stevanović on 30. 12. 2025..
//

import AVKit
import Combine
import UIKit

final class ScanAnythingController: UIPageViewController {
    
    enum LabelStyle {
        case enterAnything
        case remoteLogin
    }
    
    let qrController = ScanAnythingQRController()
    
    lazy var keyboardController: ScanAnythingKeyboardController = {
        let vc = ScanAnythingKeyboardController()
        vc.backButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            setViewControllers([qrController], direction: .reverse, animated: true)
        }), for: .touchUpInside)
        switch labelStyle {
        case .enterAnything:
            vc.titleLabel.text = "Enter Anything"
            vc.descLabel.text = "Invite code, payment invoice, login string,\nuser link, content link, primal gift card code"
            vc.placeholderLabel.text = "Enter code..."
        case .remoteLogin:
            vc.titleLabel.text = "Remote Login"
            vc.descLabel.text = "Use your Primal account to login to any Nostr app that supports remote sign in. Paste the connection string below:"
            vc.placeholderLabel.text = "nostrconnect://"
        }
        return vc
    }()
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    let labelStyle: LabelStyle
    init(style: LabelStyle = .enterAnything) {
        self.labelStyle = style
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
        setViewControllers([qrController], direction: .forward, animated: false)
        
        qrController.enterCodeButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            setViewControllers([keyboardController], direction: .forward, animated: true)
        }), for: .touchUpInside)
        
        switch labelStyle {
        case .enterAnything:
            qrController.titleLabel.text = "Scan Code"
            qrController.descTitleLabel.text = "Scan Anything:"
            qrController.descLabel.text = "Invite code, payment invoice, login string,\nuser link, content link, primal gift card"
        case .remoteLogin:
            qrController.titleLabel.text = "Remote Login"
            qrController.descTitleLabel.text = "Login to Any Nostr App"
            qrController.descLabel.text = "Use your Primal account to login to any\nNostr app that supports remote sign in. "
        }
        
        dataSource = self
    }
}

extension ScanAnythingController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        viewController == qrController ? nil : qrController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        viewController == qrController ? keyboardController : nil
    }
}
