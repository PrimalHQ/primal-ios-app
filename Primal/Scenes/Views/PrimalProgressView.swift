//
//  PrimalProgressView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.4.23..
//

import UIKit

final class PrimalProgressView: UIView {
    var currentPage: Int {
        didSet {
            updateColors()
        }
    }
    
    var numberOfPages: Int {
        didSet {
            updateCount()
        }
    }
    
    var primaryColor: UIColor = .white { didSet { updateColors() } }
    var secondaryColor: UIColor = .white.withAlphaComponent(0.4) { didSet { updateColors() } }
    
    private let stack = UIStackView()
    private let bottomPadding: CGFloat
    private let markProgress: Bool
    
    init(progress: Int = 0, total: Int = 4, bottomPadding: CGFloat = 12, markProgress: Bool = false) {
        self.currentPage = progress
        self.numberOfPages = total
        self.bottomPadding = bottomPadding
        self.markProgress = markProgress
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
        stack.pinToSuperview(edges: .top).centerToSuperview(axis: .horizontal).pinToSuperview(edges: .bottom, padding: bottomPadding)
        
        stack.spacing = 12
        
        updateCount()
    }
    
    func updateColors() {
        for (index, view) in stack.arrangedSubviews.enumerated() {
            if markProgress {
                view.backgroundColor = index <= currentPage ? primaryColor : secondaryColor
            } else {
                view.backgroundColor = index == currentPage ? primaryColor : secondaryColor
            }
        }
    }
    
    func updateCount() {
        if stack.arrangedSubviews.count > numberOfPages {
            for (index, view) in stack.arrangedSubviews.enumerated() where index >= numberOfPages {
                view.removeFromSuperview()
            }
        }
        
        while stack.arrangedSubviews.count < numberOfPages {
            stack.addArrangedSubview(stackingView())
        }
        updateColors()
    }
    
    func stackingView() -> UIView {
        let view = UIView().constrainToSize(8)
        view.layer.cornerRadius = 4
        return view
    }
}
