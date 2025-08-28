//
//  AutoHidingView.swift
//  Primal
//
//  Created by Pavle Stevanović on 12. 8. 2025..
//

import UIKit

class AutoHidingView: UIView {
    init() {
        super.init(frame: .zero)
        updateHiddenState()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        updateHiddenState()
    }
    
    override func willRemoveSubview(_ subview: UIView) {
        isHidden = subviews.count <= 1
        
        super.willRemoveSubview(subview)
    }
    
    private func updateHiddenState() {
        isHidden = subviews.isEmpty
    }
}
