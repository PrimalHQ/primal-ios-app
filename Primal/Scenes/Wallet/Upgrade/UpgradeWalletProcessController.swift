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
    let message = UILabel("Please keep Primal open\nuntil the upgrade process is done.", color: .foreground3, font: .appFont(withSize: 18, weight: .regular), multiline: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Upgrading..."
        navigationItem.hidesBackButton = true
        view.backgroundColor = .background
        
        let mainStack = UIStackView(axis: .vertical, [spinner, titleLabel, message, SpacerView(height: 50)])
        mainStack.alignment = .center
        mainStack.distribution = .equalSpacing
        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .horizontal, padding: 28)
            .pinToSuperview(edges: .bottom, padding: 10, safeArea: true)
            .constrainToSize(height: 560)
        
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
