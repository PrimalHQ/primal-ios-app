//
//  UpgradeWalletProcessController.swift
//  Primal
//
//  Created by Pavle Stevanović on 11. 2. 2026..
//

import UIKit

class UpgradeWalletProcessController: UIViewController {
    let spinner = LoadingSpinnerView().constrainToSize(160)
    
    let titleLabel = UILabel("", color: .foreground3, font: .appFont(withSize: 18, weight: .regular), multiline: true)
    let message = UILabel("Please keep Primal open\nuntil the upgrade process is done.", color: .foreground, font: .appFont(withSize: 16, weight: .regular), multiline: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Upgrading..."
        navigationItem.hidesBackButton = true
        view.backgroundColor = .background
        
        let mainStack = UIStackView(axis: .vertical, [spinner, SpacerView(height: 60), titleLabel, SpacerView(height: 90), message])
        mainStack.alignment = .center
        mainStack.distribution = .equalSpacing
        view.addSubview(mainStack)
        mainStack.centerToSuperview().constrainToSize(width: 275)
        
        let aspect = RootViewController.instance.view.frame.width / 375
        mainStack.transform = .init(scaleX: aspect, y: aspect)
        
        WalletManager.instance.migrateToSpark { [weak self] step in
            switch step {
            case .inProgress(let message):
                self?.titleLabel.text = message
            case .failed(let logs):
                self?.navigationController?.setViewControllers([UpgradeWalletFailedController(logs: logs)], animated: true)
            case .completed:
                self?.navigationController?.setViewControllers([UpgradeWalletCompleteController()], animated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        spinner.play()
    }
}
