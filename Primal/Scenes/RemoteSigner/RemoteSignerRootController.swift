//
//  RemoteSignerRootController.swift
//  Primal
//
//  Created by Pavle Stevanović on 27. 11. 2025..
//

import UIKit

enum RemoteSignerStartMode {
    case newLogin(String)
    case activeSessions
    case custom(UIViewController)
}

class RemoteSignerNavigationController: UINavigationController {
    override var viewControllers: [UIViewController] {
        didSet {
            preferredContentSize = viewControllers.last?.preferredContentSize ?? preferredContentSize
        }
    }
    
    override var preferredContentSize: CGSize {
        didSet {
            parent?.sheetPresentationController?.invalidateDetents()
        }
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        preferredContentSize = rootViewController.preferredContentSize
        setNavigationBarHidden(true, animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if animated, let sheet = parent?.sheetPresentationController {
            sheet.animateChanges {
                self.preferredContentSize = viewController.preferredContentSize
            }
        } else {
            preferredContentSize = viewController.preferredContentSize
        }
        
        super.pushViewController(viewController, animated: animated)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        if animated, let sheet = parent?.sheetPresentationController {
            sheet.animateChanges {
                preferredContentSize = viewControllers.dropLast().last?.preferredContentSize ?? preferredContentSize
            }
        } else {
            preferredContentSize = viewControllers.dropLast().last?.preferredContentSize ?? preferredContentSize
        }
        
        return super.popViewController(animated: animated)
    }
}

class RemoteSignerRootController: UIViewController {
    
    var child: UIViewController
    init(_ start: RemoteSignerStartMode) {
        switch start {
        case .newLogin(let string):
            if let url = URL(string: string) {
                child = RemoteSignerSignInController(connection: url)
            } else {
                child = UIViewController()
                child.preferredContentSize = .init(width: 200, height: 200)
                child.view.backgroundColor = .red
            }
        case .activeSessions:
            child = RemoteSignerActiveSessionsController()
        case .custom(let vc):
            child = RemoteSignerNavigationController(rootViewController: vc)
        }
        super.init(nibName: nil, bundle: nil)
        
        if let sheet = sheetPresentationController {
            sheet.detents = [.custom(resolver: { [weak self] context in
                return self?.child.preferredContentSize.height ?? 600
            }), .large()]
            sheet.prefersGrabberVisible = true // Add a grabber for resizing
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        child.willMove(toParent: self)
        view.addSubview(child.view)
        addChild(child)
        child.didMove(toParent: self)
        child.view.pinToSuperview()
    }
}
