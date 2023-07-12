//
//  MessagesViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 16.5.23..
//

import UIKit

final class MessagesViewController: UIViewController, Themeable {
    let backgroundView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Messages"
        
        view.addSubview(backgroundView)
        
        backgroundView.pinToSuperview(edges: [.horizontal, .bottom]).pinToSuperview(edges: .top, padding: 7, safeArea: true)
        
        let label = UILabel()
        label.text = "coming soon"
        label.font = .appFont(withSize: 17, weight: .regular)
        label.textColor = .init(rgb: 0x777777)
        
        backgroundView.addSubview(label)
        label.centerToSuperview(axis: .horizontal).pinToSuperview(edges: .top, padding: 32)
        
        updateTheme()
    }
    
    func updateTheme() {
        backgroundView.backgroundColor = .background2
    }
}
