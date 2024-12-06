//
//  LargeZapPillViews.swift
//  Primal
//
//  Created by Pavle Stevanović on 21.6.24..
//

import UIKit
import FLAnimatedImage

class LargeZapGalleryChildView: UIView {
    let zap: ParsedZap
    init(zap: ParsedZap) {
        self.zap = zap
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class LargeZapPillView: LargeZapGalleryChildView {
    let image = UserImageView(height: 26, showLegendGlow: false)
    let amountLabel = UILabel()
    let endSpacer = SpacerView(width: 2)
    
    lazy var stack = UIStackView(arrangedSubviews: [image, amountLabel, endSpacer])
    
    override init(zap: ParsedZap) {
        super.init(zap: zap)
        
        amountLabel.font = .appFont(withSize: 14, weight: .regular)
        amountLabel.textColor = .foreground3
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        image.setUserImage(zap.user)
        amountLabel.text = zap.amountSats.localized()
        
        addSubview(stack)
        stack.pinToSuperview(padding: 1)
        stack.alignment = .center
        stack.spacing = 8
        
        backgroundColor = .background3
        layer.cornerRadius = 14
        clipsToBounds = true
    }
    
    func width() -> CGFloat {
        45 + amountLabel.sizeThatFits(CGSize(width: 50, height: 30)).width
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LargeZapPillTextView: LargeZapPillView {
    let label = UILabel()
    let zapIcon = UIImageView(image: UIImage(named: "topZapGalleryIcon"))
    
    override init(zap: ParsedZap) {
        super.init(zap: zap)
        
        stack.insertArrangedSubview(label, at: 2)
        stack.insertArrangedSubview(zapIcon, at: 1)
        stack.setCustomSpacing(4, after: zapIcon)
        
        zapIcon.tintColor = .foreground
        
        amountLabel.font = .appFont(withSize: 14, weight: .bold)
        amountLabel.textColor = .foreground
        
        label.font = .appFont(withSize: 14, weight: .regular)
        label.textColor = .foreground3
        label.text = zap.message
        label.isHidden = zap.message.isEmpty
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
