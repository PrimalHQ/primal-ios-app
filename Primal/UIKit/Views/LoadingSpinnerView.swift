//
//  LoadingSpinnerView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 25.4.23..
//

import UIKit

class LoadingSpinnerView: UIImageView {
    init() {
        super.init(image: UIImage(named: "loadingSpinner"))
        
        contentMode = .center
        
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = .greatestFiniteMagnitude
        layer.add(rotation, forKey: "rotationAnimation")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
