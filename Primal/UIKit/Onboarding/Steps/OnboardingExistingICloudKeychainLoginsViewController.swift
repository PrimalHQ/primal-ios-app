//
//  OnboardingExistingICloudKeychainLoginsViewController.swift
//  Primal
//
//  Created by Nikola Lukovic on 27.6.23..
//

import Foundation
import UIKit

final class OnboardingExistingICloudKeychainLoginsViewController : UIViewController, Themeable {
    lazy private var table = UITableView()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension OnboardingExistingICloudKeychainLoginsViewController {
    func updateTheme() {
        view.backgroundColor = .background
        table.backgroundColor = .background
    }
    
    func setup() {
        navigationItem.title = "Already saved keys in ICloud Keychain"
        
    }
}
