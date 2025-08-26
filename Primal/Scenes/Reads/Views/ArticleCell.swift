//
//  ArticleCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 28.5.24..
//

import Combine
import UIKit
import FLAnimatedImage
import Kingfisher

protocol ArticleCellDelegate: AnyObject {
    func articleCellDidSelect(_ cell: ArticleCell, action: PostCellEvent)
}

class ArticleCell: UITableViewCell, Themeable {
    let avatar = UserImageView(height: 22)
    let nameLabel = UILabel()
    let dot = UIView().constrainToSize(3)
    let timeLabel = UILabel()
    let titleLabel = UILabel()
    let durationLabel = UILabel()
    let commentIcon = UIImageView(image: UIImage(named: "longFormReplies"))
    let commentLabel = UILabel()
    let zapIcon = UIImageView(image: UIImage(named: "longFormZapIcon"))
    let zapView = UserGalleryView()
    let contentImageView = UIImageView().constrainToSize(width: 100, height: 72)
    let border = UIView().constrainToSize(height: 1)
    let bottomSpacer = SpacerView(height: 12)
    
    let threeDotsButton = UIButton(configuration: .simpleImage(UIImage(named: "threeDots")))
    
    weak var delegate: ArticleCellDelegate?
    
    var bookmarkUpdate: AnyCancellable?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setUp(_ content: Article, delegate: ArticleCellDelegate? = nil) {
        self.delegate = delegate
        updateTheme()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2
        
        let bigWidth = UIScreen.main.bounds.size.width - 40
        let smallWidth = bigWidth - 104

        titleLabel.attributedText = NSAttributedString(string: content.title, attributes: [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.appFont(withSize: 26 / bigWidth * smallWidth, weight: .bold),
            .foregroundColor: UIColor.foreground
        ])
        
        if let words = content.words {
            durationLabel.text = "\(1 + (words / 200)) min read"
            durationLabel.isHidden = false
        } else {
            durationLabel.isHidden = true
        }
        
        let imageURL: URL? = {
            if let image = content.image { return MediaManager.getCachedURL(image, size: .medium) }
            return content.user.profileImage.url(for: .medium)
        }()
        
        if let imageURL {
            contentImageView.kf.setImage(with: imageURL, placeholder: UIImage(named: "longFormPlaceholderImage")) { [weak self] result in
                guard let self, case let .success(image) = result else { return }
                
                let aspect = image.image.size.width / image.image.size.height
                
                let newSize: CGSize
                if aspect > 100 / 72 {
                    newSize = CGSize(width: aspect * 72, height: 72)
                } else {
                    newSize = CGSize(width: 100, height: 100 / aspect)
                }
                
                contentImageView.kf.setImage(with: imageURL, options: [
                    .scaleFactor(UIScreen.main.scale),
                    .cacheOriginalImage,
                    .processor(DownsamplingImageProcessor(size: newSize))
                ])
            }
        } else {
            contentImageView.kf.cancelDownloadTask()
            contentImageView.image = UIImage(named: "longFormPlaceholderImage")
        }
        
        timeLabel.text = Date(timeIntervalSince1970: content.event.created_at).timeAgoDisplayLong()
        avatar.setUserImage(content.user, disableAnimated: true)
        nameLabel.text = content.user.data.firstIdentifier
        commentLabel.text = "\(content.stats.replies ?? 0) comments"
        
        if content.zaps.isEmpty {
            zapIcon.isHidden = true
            zapView.isHidden = true
        } else {
            zapIcon.isHidden = false
            zapView.isHidden = false
            zapView.users = content.zaps.map { $0.user }
        }
        
        bookmarkUpdate = BookmarkManager.instance.isBookmarkedPublisher(content.asParsedContent)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.updateMenu(content: content)
            })
    }
    
    func updateTheme() {
        nameLabel.textColor = .foreground2
        timeLabel.textColor = .foreground2
        dot.backgroundColor = .foreground2
        threeDotsButton.tintColor = .foreground2
        durationLabel.textColor = .foreground2
        commentIcon.tintColor = .foreground2
        commentLabel.textColor = .foreground2
        zapIcon.tintColor = .foreground2
        
        border.backgroundColor = .background3
        
        contentImageView.layer.borderColor = UIColor.background3.cgColor
        
        titleLabel.textColor = .foreground
        
        contentView.backgroundColor = .background
    }
    
    func updateMenu(content: Article) {
        let actionsData: [(String, String, PostCellEvent, UIMenuElement.Attributes)] = [
            ("Share Article", "MenuShare", (.share), []),
            
            BookmarkManager.instance.isBookmarked(content.asParsedContent) ?
                ("Remove Bookmark", "MenuBookmarkFilled", (.unbookmark), []) :
                ("Add Bookmark", "MenuBookmark", (.bookmark), []),
            
            ("Copy Article Link", "MenuCopyLink", (.copy(.link)), []),
            ("Copy Article Text", "MenuCopyText", (.copy(.content)), []),
            ("Copy Raw Data", "MenuCopyData", (.copy(.rawData)), []),
            ("Copy Article ID", "MenuCopyNoteID", (.copy(.noteID)), []),
            ("Copy User Public Key", "MenuCopyUserPubkey", (.copy(.userPubkey)), []),
            ("Mute User", "blockIcon", (.muteUser), .destructive),
            ("Report user", "warningIcon", (.report), .destructive)
        ]
        
        threeDotsButton.menu = .init(children: actionsData.map { (title, imageName, action, attributes) in
            UIAction(title: title, image: UIImage(named: imageName), attributes: attributes) { [weak self] _ in
                guard let self else { return }
                delegate?.articleCellDidSelect(self, action: action)
                updateMenu(content: content)
            }
        })
    }
}

private extension ArticleCell {
    func setup() {
        selectionStyle = .none
        
        let firstRow = UIStackView([avatar, nameLabel, dot, timeLabel, UIView(), threeDotsButton])
        nameLabel.setContentHuggingPriority(.required, for: .horizontal)
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        timeLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        firstRow.alignment = .center
        firstRow.spacing = 4
        firstRow.setCustomSpacing(8, after: avatar)
        dot.layer.cornerRadius = 1.5
        threeDotsButton.showsMenuAsPrimaryAction = true
        threeDotsButton.transform = .init(translationX: 12, y: 0)
        
        let contentStack = UIStackView([titleLabel, contentImageView])
        contentStack.spacing = 12
        contentStack.alignment = .top
        
        let botStack = UIStackView([durationLabel, commentIcon, commentLabel, UIView(), zapIcon, zapView])
        botStack.setCustomSpacing(16, after: durationLabel)
        botStack.setCustomSpacing(4, after: commentIcon)
        botStack.setCustomSpacing(9, after: zapIcon)
        botStack.alignment = .center
        
        let mainStack = UIStackView(axis: .vertical, [firstRow, contentStack, botStack])
        mainStack.spacing = 8
        
        nameLabel.font = .appFont(withSize: 15, weight: .regular)
        timeLabel.font = .appFont(withSize: 15, weight: .regular)
        
        titleLabel.font = .appFont(withSize: 16, weight: .heavy)
        durationLabel.font = .appFont(withSize: 15, weight: .regular)
        commentLabel.font = .appFont(withSize: 15, weight: .regular)
        
        titleLabel.numberOfLines = 5
        
        contentImageView.layer.borderWidth = 1
        contentImageView.layer.cornerRadius = 8
        contentImageView.contentMode = .scaleAspectFill
        contentImageView.clipsToBounds = true
        
        let mainParent = UIView()
        mainParent.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .vertical, padding: 12)
        
        let finalStack = UIStackView(axis: .vertical, [mainParent, border, bottomSpacer])
        contentView.addSubview(finalStack)
        finalStack.pinToSuperview()
        bottomSpacer.isHidden = true
    }
}
