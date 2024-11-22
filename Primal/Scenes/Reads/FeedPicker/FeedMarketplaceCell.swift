//
//  FeedMarketplaceCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.8.24..
//

import UIKit
import Kingfisher

class FeedMarketplaceCell: UITableViewCell {
    let feedImageView = UIImageView().constrainToSize(40)
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    
    let freePaidView = FreePaidInfoView().constrainToSize(width: 40)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        let titleStack = UIStackView(axis: .vertical, [titleLabel, subtitleLabel])
        titleStack.distribution = .equalSpacing
        
        let topStack = UIStackView([feedImageView, titleStack])
        topStack.spacing = 16
        
        feedImageView.layer.cornerRadius = 20
        feedImageView.clipsToBounds = true
        
        let botStack = UIStackView([freePaidView, UIView()])
        botStack.spacing = 16
        botStack.alignment  = .center
        
        let mainStack = UIStackView(axis: .vertical, [topStack, botStack])
        mainStack.spacing = 8
        contentView.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .vertical, padding: 16).pinToSuperview(edges: .horizontal, padding: 20)
        
        let border = SpacerView(height: 1, color: .background3)
        contentView.addSubview(border)
        border.pinToSuperview(edges: [.horizontal, .bottom])
        
        titleLabel.textColor = .foreground
        titleLabel.font = .appFont(withSize: 16, weight: .bold)
        
        subtitleLabel.textColor = .foreground2
        subtitleLabel.font = .appFont(withSize: 14, weight: .regular)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setup(_ feed: FeedFromMarket) {
        titleLabel.text = feed.name
        subtitleLabel.text = feed.about
        
        let defaultImage = UIImage(named: "dvmDefault")?.withTintColor(.foreground6).withRenderingMode(.alwaysOriginal)
        
        feedImageView.kf.setImage(with: URL(string: feed.picture ?? feed.image ?? ""), placeholder: defaultImage, options: [
            .scaleFactor(UIScreen.main.scale),
            .cacheOriginalImage,
            .processor(ResizingImageProcessor(referenceSize: .init(width: 40, height: 40)))
        ])
        
        freePaidView.state = feed.subscription == true ? .paid : .free
        
        backgroundColor = .background2
    }
    
    func setupSelected(_ feed: FeedFromMarket) {
        setup(feed)
        backgroundColor = .background3
        subtitleLabel.numberOfLines = 0
    }
}

class FreePaidInfoView: UIView {
    enum State {
        case free, paid, sub
    }
    
    var state = State.free {
        didSet {
            update()
        }
    }
    
    let label = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        addSubview(label)
        label.centerToSuperview()
        
        label.font = .appFont(withSize: 10, weight: .bold)
        
        constrainToSize(height: 18)
        layer.cornerRadius = 9
        
        update()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func update() {
        switch state {
        case .free:
            label.text = "FREE"
            label.textColor = Theme.inverse.foreground2
            backgroundColor = .foreground2
        case .paid:
            label.text = "PAID"
            label.textColor = .white
            backgroundColor = UIColor(rgb: 0xFC6337)
        case .sub:
            label.text = "PAID"
            label.textColor = .white
            backgroundColor = .accent
        }
    }
}
