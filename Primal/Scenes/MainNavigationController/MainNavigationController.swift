//
//  FeedNavigationController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 2.5.23..
//

import UIKit

extension UINavigationController {
    func fadeTo(_ viewController: UIViewController) {
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.fade
        view.layer.add(transition, forKey: nil)
        pushViewController(viewController, animated: false)
    }
}

final class FeedNavigationController: MainNavigationController {
    init() {
        super.init(rootViewController: MenuContainerController(child: HomeFeedViewController()))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MainNavigationController: UINavigationController, Themeable, UIGestureRecognizerDelegate {
    var isTransparent: Bool = false {
        didSet {
            updateAppearance()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        viewControllers.last?.preferredStatusBarStyle ?? super.preferredStatusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
            
        interactivePopGestureRecognizer?.delegate = self
        
        delegate = self
        
        updateTheme()
    }
    
    func updateTheme() {
        updateAppearance()
        
        viewControllers.forEach { $0.updateThemeIfThemeable() }
    }
    
    func updateAppearance() {
        let appearance = UINavigationBarAppearance()
        if isTransparent {
            appearance.configureWithTransparentBackground()
            appearance.titleTextAttributes = [
                .font: UIFont.appFont(withSize: 20, weight: .bold),
                .foregroundColor: UIColor.white
            ]
        } else {
            appearance.backgroundColor = .background
            appearance.shadowColor = .clear
            appearance.titleTextAttributes = [
                .font: UIFont.appFont(withSize: 20, weight: .bold),
                .foregroundColor: UIColor.foreground
            ]
        }
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.standardAppearance = appearance
        navigationBar.compactScrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

extension MainNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if fromVC as? WalletTransferSummaryController != nil {
            return SlideDownAnimator(presenting: false)
        }
        
        if let home: WalletHomeViewController = fromVC.findInChildren() ?? toVC.findInChildren() {
            let isPresenting = fromVC.children.contains(where: { $0 == home })
            
            if let qrCode: WalletQRCodeViewController = fromVC.findInChildren() ?? toVC.findInChildren() {
                if isPresenting {
                    return WalletQRTransitionAnimator(home: home, qrController: qrCode, presenting: isPresenting)
                }
            }
            
            if let user: WalletPickUserController = fromVC.findInChildren() ?? toVC.findInChildren() {
                if isPresenting {
                    return WalletSendTransitionAnimator(home: home, userController: user, presenting: isPresenting)
                }
            }
            
            if let receive = toVC as? WalletReceiveViewController {
                return WalletReceiveTransitionAnimator(home: home, receive: receive, presenting: isPresenting)
            }
            
            if let transaction = toVC as? TransactionViewController ?? fromVC as? TransactionViewController {
                return WalletHomeToTransactionAnimator(home: home, transactionController: transaction, isPresenting: isPresenting)
            }
            
            return nil
        }
        
        if let amount = fromVC as? WalletSendAmountController ?? toVC as? WalletSendAmountController {
            if let userList: WalletPickUserController = fromVC.findInChildren() ?? toVC.findInChildren() {
                let isPresenting = amount == toVC
                return UserListToSendAnimator(userListController: userList, sendController: amount, isPresenting: isPresenting)
            }
            
            if let send = fromVC as? WalletSendViewController ?? toVC as? WalletSendViewController {
                return WalletSendAmountSendAnimator(sendAmount: amount, send: send, presenting: amount == fromVC)
            }
            
            return nil
        }
        
        if let send = fromVC as? WalletSendViewController ?? toVC as? WalletSendViewController {
            if let spinner = toVC as? WalletSpinnerViewController {
                return WalletSendSpinnerAnimator(sendController: send, spinner: spinner)
            }
        }
        
        if let result = toVC as? WalletTransferSummaryController {
            if let spinner = fromVC as? WalletSpinnerViewController {
                return WalletSpinnerToResultAnimator(spinner: spinner, result: result)
            }
        }
        
        if let longForm = toVC as? ArticleViewController {
            if operation == .pop { return nil }
            if let listVC = fromVC as? ArticleCellController {
                return ArticleTransition(listVCs: [listVC], longFormController: longForm, presenting: true)
            }
            return ArticleTransition(listVCs: fromVC.findAllChildren(), longFormController: longForm, presenting: true)
        }
        
        if let article = fromVC as? ArticleViewController {
            if operation == .push { return nil }
            if let listVC = toVC as? ArticleCellController {
                return ArticleTransition(listVCs: [listVC], longFormController: article, presenting: false)
            }
            return ArticleTransition(listVCs: toVC.findAllChildren(), longFormController: article, presenting: false)
        }
        
        return nil
    }
}
