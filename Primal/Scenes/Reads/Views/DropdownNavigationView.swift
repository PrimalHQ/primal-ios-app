//
//  DropdownNavigationView.swift
//  Primal
//
//  Created by Pavle Stevanović on 29.8.24..
//

import UIKit

class DropdownNavigationView: UIView, Themeable {
    var title: String {
        didSet {
            updateTheme()
        }
    }
    
    let button = UIButton()
    
    weak var transitionView: UIView?
    var transitionConstraint: NSLayoutConstraint?
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        updateTheme()
        
        addSubview(button)
        button.pinToSuperview(edges: .vertical).centerToSuperview()
        let leadingC = button.leadingAnchor.constraint(equalTo: leadingAnchor)
        leadingC.priority = .defaultLow
        leadingC.isActive = true
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        button.configuration = .navChevronButton(title: title)
    }
    
    func startTransition(left: Bool, newTitle: String) {
        transitionView?.removeFromSuperview()
        
        let view = UIView()
        view.backgroundColor = .background
        view.clipsToBounds = true
        addSubview(view)
        view.pinToSuperview(edges: .vertical).pinToSuperview(/*to: button, */edges: left ? .leading : .trailing)
        transitionView = view
        transitionConstraint = view.widthAnchor.constraint(equalToConstant: 0)
        transitionConstraint?.isActive = true
        
        let transButton = UIButton(configuration: .navChevronButton(title: newTitle))
        view.addSubview(transButton)
        transButton.pinToSuperview(edges: .vertical).centerToView(button)
        if newTitle.count > title.count {
            let leadingC = transButton.leadingAnchor.constraint(equalTo: leadingAnchor)
            leadingC.priority = .defaultHigh
            leadingC.isActive = true
        }
        
        let border = UIView()
        border.backgroundColor = .background
        view.addSubview(border)
        border
            .pinToSuperview(edges: .vertical).constrainToSize(width: 12)
            .pinToSuperview(edges: left ? .trailing : .leading)
    }
    
    func updateTransition(percent: CGFloat) {
        transitionConstraint?.constant = (frame.width + 12) * percent.clamped(to: 0...1)
    }
    
    func cancelTransition() {
        transitionConstraint?.constant = 0
        UIView.animate(withDuration: 0.1) {
            self.layoutIfNeeded()
        }
    }
    
    func completeTransitionAnimated(newTitle: String) {
        transitionConstraint?.constant = (frame.width + 12)
        UIView.animate(withDuration: 0.1) {
            self.layoutIfNeeded()
        } completion: { _ in
            self.transitionView?.removeFromSuperview()
            self.title = newTitle
        }
    }
    
    func completeTransition(newTitle: String) {
        transitionView?.removeFromSuperview()
        title = newTitle
    }
}
