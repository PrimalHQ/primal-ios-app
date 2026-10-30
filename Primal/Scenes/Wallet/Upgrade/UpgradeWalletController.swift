






import UIKit

class UpgradeWalletController: MainNavigationController {
    @MainActor required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init() {
        super.init(rootViewController: UpgradeWalletStartController())
        
        modalPresentationStyle = .fullScreen
    }
}
