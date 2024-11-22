//
//  PostLoadingCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 21.4.24..
//

import UIKit

class PostLoadingCell: UITableViewCell, Themeable {
    let animationView = GenericLoadingView().constrainToAspect(343 / 128)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        contentView.addSubview(animationView)
        animationView
            .pinToSuperview(edges: .horizontal, padding: 16)
            .pinToSuperview(edges: .vertical, padding: 16)
        
        updateTheme()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        animationView.play()
    }
    
    func updateTheme() {
        contentView.backgroundColor = .background2
    }
}
