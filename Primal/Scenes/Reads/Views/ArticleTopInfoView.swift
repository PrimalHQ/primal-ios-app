//
//  ArticleTopInfoView.swift
//  Primal
//
//  Created by Pavle Stevanović on 2.8.24..
//

import UIKit

class ArticleTopInfoView: UIView, Themeable {
    let summary = LongFormQuoteView()
    let imageView = UIImageView()
    let zapEmbededController = LongFormEmbeddedPostController<LongFormZapsPostCell>()
    
    lazy var titleLabel = ThemeableLabel().setTheme { [weak self] in
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 32.0 / 32.0
        $0.attributedText = NSAttributedString(string: self?.title ?? "", attributes: [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.appFont(withSize: 32, weight: .heavy),
            .foregroundColor: UIColor.foreground,
//            .kern: -0.58 / 1.4176
        ])
    }
    
    let dateLabel = ThemeableLabel().setTheme {
        $0.textColor = .foreground4
        $0.font = .appFont(withSize: 14, weight: .regular)
    }
    
    var mainImageURL: String?
    var title: String?
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        
    }
    
    func update(_ content: Article) {
        let date = Date(timeIntervalSince1970: content.event.created_at)
        dateLabel.text = date.shortFormatString()
        
        if let image = content.image {
            mainImageURL = image
            imageView.kf.setImage(with: URL(string: image)) { [weak self] res in
                guard let self, case .success(let result) = res else { return }
                
                let s = result.image.size
                imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: s.width / s.height).isActive = true
                imageView.isHidden = false
            }
        } else {
            imageView.isHidden = true
        }
        
        summary.text = (content.summary ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        summary.isHidden = summary.text.isEmpty
        
        titleLabel.text = content.title
        titleLabel.isHidden = content.title.isEmpty
    }
}

private extension ArticleTopInfoView {
    func setup() {
        
        titleLabel.numberOfLines = 0
        titleLabel.font = .appFont(withSize: 32, weight: .heavy)
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.isHidden = true
        
        summary.isHidden = true
        
        let midStack = UIStackView(axis: .vertical, [
            dateLabel,
            titleLabel,
            imageView,
            summary,
            zapEmbededController.view
        ])
        
        midStack.spacing = 14
        midStack.setCustomSpacing(8, after: dateLabel)
        addSubview(midStack)
        
        midStack.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .top).pinToSuperview(edges: .bottom, padding: 8)
    }
}
