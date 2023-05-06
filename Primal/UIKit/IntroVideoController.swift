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
        video.centerToSuperview().constrainToSize(200)
    }
}
