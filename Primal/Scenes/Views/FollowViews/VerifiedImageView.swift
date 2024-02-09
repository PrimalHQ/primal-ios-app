//
//  VerifiedImageView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 29.4.23..
//

import UIKit

final class VerifiedImageView: UIView {
    let imageView = UIImageView()
    let verifiedBadge = VerifiedView()
    
    init() {
        super.init(frame: .zero)
        setup()
        verifiedBadge.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        addSubview(imageView)
        imageView.pinToSuperview()
        
        addSubview(verifiedBadge)
        
        verifiedBadge.pinToSuperview(edges: [.bottom, .trailing])
        verifiedBadge.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 14 / 48).isActive = true
        verifiedBadge.heightAnchor.constraint(equalTo: verifiedBadge.widthAnchor).isActive = true
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
    }
}
