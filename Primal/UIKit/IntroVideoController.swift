//
//  IntroVideoController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.4.23..
//

import UIKit

class IntroVideoController: UIViewController {
    
    lazy var video = IntroVideoPlayerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(video)
        video
            .centerToSuperview()
            .constrainToSize(width: 1920 / 3, height: 1080 / 3)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        video.play()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.view.window?.rootViewController = OnboardingParentViewController()
        }
    }
}
