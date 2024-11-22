//
//  PremiumManageMediaDataCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 15.11.24..
//

import UIKit
import Kingfisher

extension UITableViewCell {
    var mainView: UIView {
        contentView.subviews.first ?? contentView
    }
    
    func updateBackground(isLast: Bool) {
        mainView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        mainView.layer.cornerRadius = isLast ? 12 : 0
    }
}

protocol PremiumManageMediaDataCellDelegate: AnyObject {
    func copyButtonPressedInCell(_ cell: PremiumManageMediaDataCell)
    func deleteButtonPressedInCell(_ cell: PremiumManageMediaDataCell)
}

class PremiumManageMediaDataCell: UITableViewCell {
    let mediaImageView = UIImageView()
    
    let sizeLabel = UILabel("", color: .foreground, font: .appFont(withSize: 15, weight: .regular))
    let dateLabel = UILabel("", color: .foreground3, font: .appFont(withSize: 15, weight: .regular))
    
    private let dateFormatter = DateFormatter()
    
    weak var delegate: PremiumManageMediaDataCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .background
        
        let mainView = SpacerView(color: .background5)
        contentView.addSubview(mainView)
        mainView.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .vertical)
        
        let imageParent = UIView().constrainToSize(width: 84)
        imageParent.addSubview(mediaImageView)
        mediaImageView
            .pinToSuperview(edges: [.leading, .vertical], padding: 12)
            .pinToSuperview(edges: .trailing, padding: 8)
            .constrainToSize(width: 64, height: 44)
        
        mediaImageView.layer.cornerRadius = 2
        mediaImageView.contentMode = .scaleAspectFill
        mediaImageView.clipsToBounds = true
        
        let infoStack = UIStackView(axis: .vertical, [sizeLabel, dateLabel])
        infoStack.spacing = 8
        infoStack.isLayoutMarginsRelativeArrangement = true
        infoStack.insetsLayoutMarginsFromSafeArea = false
        infoStack.layoutMargins = .init(top: 0, left: 8, bottom: 0, right: 8)
        
        let copyButton = UIButton().constrainToSize(width: 62, height: 68)
        copyButton.setImage(UIImage(named: "MenuImageCopy")?.withRenderingMode(.alwaysTemplate), for: .normal)
        copyButton.tintColor = .foreground
        
        let deleteButton = UIButton(configuration: .simpleImage("trash")).constrainToSize(width: 67, height: 68)
        deleteButton.tintColor = UIColor(rgb: 0xFA3C3C)
        
        let stack = UIStackView([imageParent, infoStack, copyButton, deleteButton])
        stack.alignment = .center
        mainView.addSubview(stack)
        stack.pinToSuperview()
        
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        
        let border = SpacerView(height: 1, color: .foreground6)
        contentView.addSubview(border)
        border.pinToSuperview(edges: .top).pinToSuperview(edges: .horizontal, padding: 20)
        
        copyButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            delegate?.copyButtonPressedInCell(self)
        }), for: .touchUpInside)
        deleteButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            delegate?.deleteButtonPressedInCell(self)
        }), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setData(imageURL: String, isVideo: Bool, size: Int, date: Date) {
        mediaImageView.kf.setImage(with: URL(string: imageURL), placeholder: UIImage(named: "mediaManagmentPlaceholder"), options: [
            .scaleFactor(3),
            .cacheOriginalImage,
            .processor(DownsamplingImageProcessor(size: CGSize(width: 64, height: 44)))
        ])
        
        let mb: Double = 1024 * 1024
        var sizeD = Double(size) / mb
        
        if sizeD > 0.001 {
            sizeD += 0.01
        }
        
        sizeLabel.text = "\(sizeD.localized()) MB \(isVideo ? "Video" : "Image")"
        dateLabel.text = dateFormatter.string(from: date)
    }
}
