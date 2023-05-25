//
//  ReadViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 16.5.23..
//

import UIKit

final class ReadViewController: UIViewController, Themeable {
    let image = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Nostr Reads"
        
        let scroll = UIScrollView()
        
        scroll.addSubview(image)
        image.pinToSuperview(edges: [.horizontal, .vertical])
        image.widthAnchor.constraint(equalTo: scroll.widthAnchor).isActive = true
        
        view.addSubview(scroll)
        scroll.pinToSuperview(edges: [.horizontal, .bottom]).pinToSuperview(edges: .top, padding: 7, safeArea: true)
        
        updateTheme()
    }
    
    func updateTheme() {
        image.image = Theme.current.mockupImage
    }
}
