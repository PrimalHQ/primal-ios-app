//
//  WalletSpinnerViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.10.23..
//

import UIKit

final class WalletSpinnerViewController: UIViewController {
    init(sats: Int, address: String) {
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        
        view.backgroundColor = .background
        
        let navTitle = UILabel()
        navTitle.font = .appFont(withSize: 20, weight: .semibold)
        navTitle.textColor = .foreground
        navTitle.text = "Sending..."
        
        let spinner = LoadingSpinnerView().constrainToSize(160)
        
        let title = UILabel()
        title.font = .appFont(withSize: 24, weight: .semibold)
        title.textColor = .foreground
        title.text = "Sending"
        
        let message = UILabel()
        message.font = .appFont(withSize: 18, weight: .regular)
        message.numberOfLines = 0
        message.textAlignment = .center
        message.text = "\(sats.localized()) sats to \(address)."
        
        let stack = UIStackView(axis: .vertical, [
            spinner, SpacerView(height: 60),
            title, SpacerView(height: 28),
            message
        ])
        stack.alignment = .center
        view.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 60).centerToSuperview(axis: .vertical)
        
        view.addSubview(navTitle)
        navTitle.pinToSuperview(edges: .top, safeArea: true).centerToSuperview(axis: .horizontal)
        
        spinner.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
