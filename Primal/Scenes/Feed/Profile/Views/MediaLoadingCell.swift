//
//  MediaLoadingCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 16.9.24..
//

import UIKit

class MediaLoadingCell: UITableViewCell {
    let views: [UIView]
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        let vStack = UIStackView(axis: .vertical, [])
        vStack.spacing = 1
        var views: [UIView] = []
        
        for _ in 0...4 {
            let oneRow = [UIView(), UIView(), UIView()]
            views.append(contentsOf: oneRow)
            let hStack = UIStackView(oneRow)
            hStack.spacing = 1
            hStack.distribution = .fillEqually
            
            vStack.addArrangedSubview(hStack)
        }
        
        views.forEach { $0.constrainToAspect(1) }
        self.views = views
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(vStack)
        vStack.pinToSuperview()
        
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateTheme()
    }
    
    func updateTheme() {
        views.forEach { $0.backgroundColor = .background4 }
    }
}
