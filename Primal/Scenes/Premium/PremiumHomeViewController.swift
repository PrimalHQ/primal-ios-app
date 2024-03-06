//
//  PremiumHomeViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.2.24..
//

import UIKit

final class PremiumHomeViewController: UIViewController, Themeable {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        mainTabBarController?.setTabBarHidden(true, animated: animated)
    }
    
    func updateTheme() {
        
    }
}

private extension PremiumHomeViewController {
    func setup() {
        title = "Premium"
        view.backgroundColor = .black
        
        let backgroundGraphic = UIImageView(image: UIImage(named: "premiumBackground"))
        view.addSubview(backgroundGraphic)
        backgroundGraphic.pinToSuperview(edges: [.top, .horizontal])
    }
    
    func backButton() {
        
    }
}
