//
//  ChatLoadingCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 25.9.23..
//

import UIKit

class ChatLoadingCell: UITableViewCell, Themeable {
    let loadingView = LoadingSpinnerView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        contentView.addSubview(loadingView)
        loadingView.pinToSuperview(edges: .vertical).centerToSuperview(axis: .horizontal).constrainToSize(70)
        loadingView.play()
        
        [self, contentView, loadingView].forEach { $0.backgroundColor = .clear }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        loadingView.updateTheme()
        loadingView.play()
    }
}
