//
//  ZapPillView.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.4.24..
//

import UIKit
import FLAnimatedImage

class ZapPillView: UIView {
    let image = FLAnimatedImageView().constrainToSize(22)
    let amountLabel = UILabel()
    
    lazy var stack = UIStackView(arrangedSubviews: [image, amountLabel])
    
    let zap: ParsedZap
    init(zap: ParsedZap) {
        self.zap = zap
        super.init(frame: .zero)
        
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 11
        image.layer.masksToBounds = true
        
        amountLabel.font = .appFont(withSize: 14, weight: .semibold)
        amountLabel.textColor = .foreground
        
        image.setUserImage(zap.user, size: .init(width: 22, height: 22))
        amountLabel.text = zap.amountSats.localized()
        
        addSubview(stack)
        stack.pinToSuperview(edges: [.leading, .vertical], padding: 1).pinToSuperview(edges: .trailing, padding: 10)
        stack.alignment = .center
        stack.spacing = 8
        
        backgroundColor = .background3
        layer.cornerRadius = 11
        clipsToBounds = true
    }
    
    func width() -> CGFloat {
        41 + amountLabel.sizeThatFits(CGSize(width: 50, height: 30)).width
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class ZapPillTextView: ZapPillView {
    let label = UILabel()
    
    override init(zap: ParsedZap) {
        super.init(zap: zap)
        
        stack.addArrangedSubview(label)
        
        label.font = .appFont(withSize: 14, weight: .regular)
        label.textColor = .foreground3
        label.text = zap.message
        label.isHidden = zap.message.isEmpty
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
