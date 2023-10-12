//
//  ChatLoadingCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 25.9.23..
//

import UIKit

class ChatLoadingCell: UITableViewCell {
    let loadingView = LoadingSpinnerView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        contentView.addSubview(loadingView)
        loadingView.pinToSuperview(edges: .vertical).centerToSuperview().constrainToSize(70)
        loadingView.play()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
