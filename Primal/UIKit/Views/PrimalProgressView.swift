//
//  PrimalProgressView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.4.23..
//

import UIKit

final class PrimalProgressView: UIView {
    
    var progress: Int {
        didSet {
            updateColors()
        }
    }
    
    var total: Int {
        didSet {
            updateCount()
        }
    }
    
    var primaryColor: UIColor = UIColor(rgb: 0xAAAAAA) { didSet { updateColors() } }
    var secondaryColor: UIColor = UIColor(rgb: 0x444444) { didSet { updateColors() } }
    
    private let stack = UIStackView()
    
    init(progress: Int, total: Int) {
        self.progress = progress
        self.total = total
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension PrimalProgressView {
    func setup() {
        addSubview(stack)
        stack.pinToSuperview()
        
        stack.spacing = 2
        layer.cornerRadius = 2
        layer.masksToBounds = true
        
        updateCount()
    }
    
    func updateColors() {
        for (index, view) in stack.arrangedSubviews.enumerated() {
            view.backgroundColor = index < progress ? primaryColor : secondaryColor
        }
    }
    
    func updateCount() {
        if stack.arrangedSubviews.count > total {
            for (index, view) in stack.arrangedSubviews.enumerated() where index >= total {
                view.removeFromSuperview()
            }
        }
        
        while stack.arrangedSubviews.count < total {
            stack.addArrangedSubview(stackingView())
        }
        updateColors()
    }
    
    func stackingView() -> UIView {
        let view = UIView()
        
        view.backgroundColor = secondaryColor
        view.constrainToSize(width: 32, height: 4)
        
        return view
    }
}
