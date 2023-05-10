//
//  IntroVideoController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.4.23..
//

import UIKit
import SwiftUI
import Lottie

class IntroVideoController: UIViewController {
    lazy var video = UIImageView(image: UIImage(named: "LogoSplash"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        view.addSubview(video)
        video.centerToSuperview(axis: .horizontal).constrainToSize(100)
        
        video.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -70).isActive = true
    }
}
