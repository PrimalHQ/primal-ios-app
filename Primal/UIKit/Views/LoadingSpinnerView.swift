//
//  LoadingSpinnerView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 25.4.23..
//

import Lottie
import UIKit

class LoadingSpinnerView: LottieAnimationView {
    init() {
        super.init(animation: AnimationType.loadingSpinner.animation)
        loopMode = .loop
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
