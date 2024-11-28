//
//  PremiumManageMediaStatsCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 15.11.24..
//

import UIKit

class PremiumManageMediaStatsCell: UITableViewCell {
    let imagesColor = UIColor(rgb: 0xBC1870)
    let videosColor = UIColor(rgb: 0x0090F8)
    let otherColor = UIColor(rgb: 0xFF9F2F)
    
    let usedLabel = UILabel("", color: .foreground3, font: .appFont(withSize: 15, weight: .regular))
    let freeLabel = UILabel("", color: .foreground3, font: .appFont(withSize: 14, weight: .regular))
    
    var graphConstraints: [NSLayoutConstraint] = []
    
    lazy var graphViewImages = SpacerView(color: imagesColor)
    lazy var graphViewVideos = SpacerView(color: videosColor)
    lazy var graphViewOther = SpacerView(color: otherColor)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .background        
        selectionStyle = .none
        
        let graphView = SpacerView(height: 22, color: .foreground6, priority: .required)
        graphView.layer.cornerRadius = 4
        graphView.clipsToBounds = true
        
        let legendStack = UIStackView([
            DotView(color: imagesColor), SpacerView(width: 4), UILabel("Images", color: .foreground3, font: .appFont(withSize: 14, weight: .regular)), SpacerView(width: 16),
            DotView(color: videosColor), SpacerView(width: 4), UILabel("Videos", color: .foreground3, font: .appFont(withSize: 14, weight: .regular)), SpacerView(width: 16),
            DotView(color: otherColor), SpacerView(width: 4), UILabel("Other", color: .foreground3, font: .appFont(withSize: 14, weight: .regular)), UIView()
        ])
        legendStack.alignment = .center
        
        let mainStack = UIStackView(axis: .vertical, [usedLabel, graphView, legendStack])
        mainStack.spacing = 8
        
        contentView.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .vertical, padding: 20)
        
        let stackParent = SpacerView(color: .background)
        let stack = UIStackView([graphViewImages, graphViewVideos, graphViewOther])
        stack.spacing = 1
        stackParent.addSubview(stack)
        stack.pinToSuperview(edges: [.leading, .vertical]).pinToSuperview(edges: .trailing, padding: 1)
        
        graphView.addSubview(stackParent)
        stackParent.pinToSuperview(edges: [.vertical, .leading])
        
        graphView.addSubview(freeLabel)
        freeLabel.pinToSuperview(edges: .trailing, padding: 6).centerToSuperview(axis: .vertical)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateWithStats(_ stats: MediaManagementStatsResponse) {
        for constraint in graphConstraints {
            constraint.isActive = false
            removeConstraint(constraint)
        }
        graphConstraints = []
        
        let GB: Double = 1024 * 1024 * 1024
        let used = stats.image + stats.video + stats.other
        let total = stats.free + used
        
        let imagesRatio = CGFloat(stats.image) / CGFloat(total)
        let videoRatio = CGFloat(stats.video) / CGFloat(total)
        let otherRatio = CGFloat(stats.other) / CGFloat(total)
        
        graphViewImages.isHidden = imagesRatio < 0.005
        graphViewVideos.isHidden = videoRatio < 0.005
        graphViewOther.isHidden = otherRatio < 0.005
        
        graphConstraints = [
            widthAnchor.constraint(equalTo: graphViewImages.widthAnchor, multiplier: 1 / max(0.001, imagesRatio), constant: 3),
            widthAnchor.constraint(equalTo: graphViewVideos.widthAnchor, multiplier: 1 / max(0.001, videoRatio), constant: 3),
            widthAnchor.constraint(equalTo: graphViewOther.widthAnchor, multiplier: 1 / max(0.001, otherRatio), constant: 3),
        ]
        NSLayoutConstraint.activate(graphConstraints)
        
        var usedGB = Double(used) / GB
        let totalGB = Double(total) / GB
        let freeGB = Double(stats.free) / GB
        
        if usedGB < 0.01 && used > 0 {
            usedGB = 0.01
        }
        
        usedLabel.text = "\(usedGB.localized()) GB of \(Int(totalGB.rounded())) GB used"
        freeLabel.text = "\(freeGB.localized()) GB free"
    }
}


class DotView: UIView {
    init(color: UIColor) {
        super.init(frame: .init(origin: .zero, size: .init(width: 10, height: 10)))
        layer.cornerRadius = 5
        backgroundColor = color
        constrainToSize(10)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
