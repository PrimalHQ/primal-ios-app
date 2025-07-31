//
//  QRCopyView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 8.6.23..
//

import UIKit

class QRCopyView: MyButton {
    var text = "" {
        didSet {
            if text.count > 30 {
                label.text = "\(String(text.prefix(14)))...\(String(text.suffix(10)))"
            } else {
                label.text = text
            }
        }
    }
    
    override var isPressed: Bool {
        didSet {
            alpha = isPressed ? 0.5 : 1
        }
    }
    
    private let copy = UIImageView(image: UIImage(named: "whiteCopy"))
    private let label = UILabel()
    
    weak var dimmingView: UIView?
    
    init() {
        super.init(frame: .zero)
        
        let stack = UIStackView(arrangedSubviews: [label, copy])
        stack.spacing = 8
        stack.alignment = .center
        
        label.font = .appFont(withSize: 16, weight: .regular)
        label.textColor = .white
        
        addSubview(stack)
        stack.pinToSuperview()
        
        addAction(.init(handler: { [weak self] _ in
            guard let text = self?.text, !text.isEmpty else { return }
            UIPasteboard.general.string = text
            
            if let dimmingView = self?.dimmingView {
                dimmingView.showDimmedToastCentered("Copied!")
            } else {
                RootViewController.instance.view.showToast("Copied!", extraPadding: 0)
            }
        }), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
