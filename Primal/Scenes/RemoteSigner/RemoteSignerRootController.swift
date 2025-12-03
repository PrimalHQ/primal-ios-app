//
//  RemoteSignerRootController.swift
//  Primal
//
//  Created by Pavle Stevanović on 27. 11. 2025..
//

import UIKit

enum RemoteSignerStartMode {
    case newLogin(String)
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
