//
//  File.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.11.23..
//

import UIKit

final class ProfileQRController: OnboardingParentViewController {
    let profile: ProfileShowQRController
    lazy var scanController = ProfileScanQRController()
    
    init(user: ParsedUser? = IdentityManager.instance.parsedUser) {
        profile = ProfileShowQRController(user: user)
        super.init()
        viewControllerStack = [profile]
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isOpeningProfileScreen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blocker = UIView()
        view.addSubview(blocker)
        blocker.pinToSuperview(edges: [.vertical, .leading]).constrainToSize(width: 30)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        mainTabBarController?.setTabBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !isOpeningProfileScreen {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
        mainTabBarController?.setTabBarHidden(false, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        navigationController?.viewControllers.remove(object: self)
    }
    
    override func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        viewController == scanController ? profile : nil
    }
    
    override func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        viewController == profile ? scanController : nil
    }
}
