//
//  VerifiedView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 17.8.23..
//

import UIKit

final class VerifiedView: UIView, Themeable {
    public enum CheckState {
        case color(() -> UIColor)
        case transparent
    }
    
    var regularCheckState: CheckState = .transparent
    var extraCheckState: CheckState = .color({ .white })
    
    var regularColor: UIColor? { didSet { updateImages() } }
    
    var isExtraVerified = false {
        didSet {
            updateImages()
        }
    }
    
    private let checkboxImage = UIImageView()
    private let checkImage = UIImageView(image: UIImage(named: "verifiedCheck"))
    
    init(regularColor: UIColor? = nil) {
        self.regularColor = regularColor
        super.init(frame: .zero)
        
        addSubview(checkboxImage)
        addSubview(checkImage)
        checkboxImage.pinToSuperview()
        checkImage.pinToSuperview()
        
        updateImages()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateImages() {
        let checkState = isExtraVerified ? extraCheckState : regularCheckState
        
        switch checkState {
        case .color(let color):
            checkboxImage.image = UIImage(named: "verifiedBackground")
            checkImage.isHidden = false
            checkImage.tintColor = color()
        case .transparent:
            checkboxImage.image = UIImage(named: "purpleVerified")
            checkImage.isHidden = true
        }
        
        checkboxImage.tintColor = isExtraVerified ? .accent : regularColor ?? .foreground3
    }
    
    func updateTheme() {
        updateImages()
    }
}
