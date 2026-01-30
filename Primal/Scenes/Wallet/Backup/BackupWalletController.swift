//
//  BackupWalletController.swift
//  Primal
//
//  Created by Pavle Stevanović on 29. 1. 2026..
//

import UIKit

protocol BackupWalletChildController: UIViewController { }

extension BackupWalletChildController {
    var backupParent: BackupWalletController? { parent as? BackupWalletController }
}

class BackupWalletController: MainNavigationController {
    
    let backupPreview = BackupWalletIntroController()
    
    init() {
        super.init(rootViewController: backupPreview)
        
        modalPresentationStyle = .fullScreen
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}
