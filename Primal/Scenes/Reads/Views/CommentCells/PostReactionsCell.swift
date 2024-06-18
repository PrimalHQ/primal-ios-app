//
//  PostReactionsCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 3.6.24..
//

import UIKit

// This is a cell that only contains the reactions bar
class PostReactionsCell: DefaultMainThreadCell {
    let zapInfoView = SatoshiInfoView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let descStack = UIStackView(axis: .vertical, [infoRow, SpacerView(height: 1, color: .background3), bottomButtonStack])
        descStack.spacing = 8
        descStack.setCustomSpacing(16, after: infoRow)
        
        let mainStack = UIStackView(axis: .vertical, [zapInfoView, descStack])
        mainStack.spacing = 12
        
        contentView.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .top, padding: 20)
            .pinToSuperview(edges: .bottom, padding: 16)
            .pinToSuperview(edges: .horizontal, padding: 20)
    }
    
    override func update(_ parsedContent: ParsedContent) {
        parsedContent.post.zaps = 1389
        parsedContent.post.likes = 7
        parsedContent.post.reposts = 3
        super.update(parsedContent, zaps: [])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SatoshiInfoView: UIView {
    var sats: Int = 0 {
        didSet {
            updateInfo()
        }
    }
    
    let satLabel = UILabel()
    let dollarLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        let image = UIImageView(image: UIImage(named: "zapSatInfo"))
        image.transform = .init(translationX: 0, y: -2)
        
        let stack = UIStackView([
            image,                                                  SpacerView(width: 4),
            satLabel,                                               SpacerView(width: 6),
            SpacerView(width: 1, height: 20, color: .foreground6),  SpacerView(width: 6),
            dollarLabel,                                            UIView()
        ])
        
        addSubview(stack)
        stack.pinToSuperview()
        stack.alignment = .center
        
        updateInfo()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateInfo() {
        let satString = NSMutableAttributedString(string: "\(sats.localized()) ", attributes: [
            .font: UIFont.appFont(withSize: 20, weight: .bold),
            .foregroundColor: UIColor.foreground
        ])
        satString.append(.init(string: "sats", attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .foregroundColor: UIColor.foreground
        ]))
        satLabel.attributedText = satString
        
        let dollarString = NSMutableAttributedString(string: "$\(sats.satsToUsdAmountString(.twoDecimals)) ", attributes: [
            .font: UIFont.appFont(withSize: 15, weight: .regular),
            .foregroundColor: UIColor.foreground4
        ])
        dollarString.append(.init(string: "USD", attributes: [
            .font: UIFont.appFont(withSize: 12, weight: .regular),
            .foregroundColor: UIColor.foreground4
        ]))
        dollarLabel.attributedText = dollarString
    }
}
