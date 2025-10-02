//
//  PopupInfoBubbleView.swift
//  Primal
//
//  Created by Pavle Stevanović on 1. 10. 2025..
//

import UIKit

class PopupInfoBubbleView: UIStackView, Themeable {
    let triangleView = UIImageView(image: .bubbleTriangle)
    
    var title: String {
        didSet {
            updateLabel()
        }
    }
    
    private let label = UILabel()
    private let bubbleBackground = UIView()
    private let xButton = UIButton(configuration: .simpleImage(.xIcon12))
    
    let onClose: () -> Void
    
    init(title: String, onClose: @escaping () -> Void) {
        self.title = title
        self.onClose = onClose
        super.init(frame: .zero)
        
        let triangleParent = UIView()
        triangleParent.addSubview(triangleView)
        triangleView.pinToSuperview(edges: .vertical)
        let centerXConstraint = triangleParent.centerXAnchor.constraint(equalTo: triangleView.centerXAnchor)
        centerXConstraint.priority = .defaultLow
        centerXConstraint.isActive = true
        
        addArrangedSubview(triangleParent)
        addArrangedSubview(bubbleBackground)
        axis = .vertical
        
        bubbleBackground.layer.cornerRadius = 8
        
        let contentStack = UIStackView([label, xButton])
        contentStack.spacing = 8
        contentStack.alignment = .top
        bubbleBackground.addSubview(contentStack)
        contentStack.pinToSuperview(edges: .vertical, padding: 8).pinToSuperview(edges: .horizontal, padding: 12)
        
        label.numberOfLines = 0
        
        updateTheme()
        
        xButton.addAction(.init(handler: { [weak self] _ in
            self?.animateRemove()
        }), for: .touchUpInside)
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func animateRemove() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
//            self.onClose()
        }
    }
    
    func updateLabel() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        label.attributedText = .init(string: title, attributes: [
            .foregroundColor: UIColor.background,
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .paragraphStyle: paragraphStyle
        ])
    }
    
    func updateTheme() {
        updateLabel()
        
        triangleView.tintColor = .foreground
        bubbleBackground.backgroundColor = .foreground
        xButton.tintColor = .background
    }
}
