//
//  MessagesViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 16.5.23..
//

import UIKit

final class MessagesViewController: UIViewController, Themeable {
    
    let manager = MessagingManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Messages"
        
        updateTheme()
    }
    
    func updateTheme() {
        
    }
}
