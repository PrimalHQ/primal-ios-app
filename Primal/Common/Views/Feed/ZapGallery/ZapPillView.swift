//
//  ZapPillView.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.4.24..
//

import UIKit
import FLAnimatedImage

class ZapGalleryChildView: UIView {
    let zap: ParsedZap
    init(zap: ParsedZap) {
        self.zap = zap
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func width() -> CGFloat { 0 }
}

class ZapAvatarView: ZapGalleryChildView {
    let image = UserImageView(height: 22)
    
    override init(zap: ParsedZap) {
        super.init(zap: zap)
        
        image.setUserImage(zap.user, disableAnimated: true)
        
        let imageBackground = UIView().constrainToSize(24)
        imageBackground.layer.cornerRadius = 12
        imageBackground.backgroundColor = UIColor.background
        imageBackground.addSubview(image)
        image.pinToSuperview(padding: 1)
        
        addSubview(imageBackground)
        imageBackground.pinToSuperview(edges: [.vertical, .trailing]).pinToSuperview(edges: .leading, padding: -6)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func width() -> CGFloat { 22 }
}

class ZapPillView: ZapGalleryChildView {
    let image = UserImageView(height: 22)
    let amountLabel = UILabel()
    let endSpacer = SpacerView(width: 2)
    
    lazy var stack = UIStackView(arrangedSubviews: [image, amountLabel, endSpacer])
    
    override init(zap: ParsedZap) {
        super.init(zap: zap)
        
        amountLabel.font = .appFont(withSize: 14, weight: .semibold)
        amountLabel.textColor = .foreground
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        image.setUserImage(zap.user)
        amountLabel.text = zap.amountSats.localized()
        
        addSubview(stack)
        stack.pinToSuperview(padding: 1)
        stack.alignment = .center
        stack.spacing = 8
        
        backgroundColor = .background3
        layer.cornerRadius = 11
    }
    
    override func width() -> CGFloat {
        41 + amountLabel.sizeThatFits(CGSize(width: 50, height: 30)).width
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class ZapPillTextView: ZapPillView {
    let label = UILabel()
    let zapIcon = UIImageView(image: UIImage(named: "topZapGalleryIcon"))
    
    override init(zap: ParsedZap) {
        super.init(zap: zap)
        
        stack.insertArrangedSubview(label, at: 2)
        stack.insertArrangedSubview(zapIcon, at: 1)
        stack.setCustomSpacing(4, after: zapIcon)
        
        zapIcon.tintColor = .foreground
        
        label.font = .appFont(withSize: 14, weight: .regular)
        label.textColor = .foreground3
        label.text = zap.message
        label.isHidden = zap.message.isEmpty
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
