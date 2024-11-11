//
//  DefaultMainThreadCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 17.4.24..
//

import UIKit

class DefaultMainThreadCell: ThreadCell {
    let selectionTextView = MainThreadCellTextView()
    
//    var zapGalleryHeightConstraint: NSLayoutConstraint?
    
    let repliesLabel = UILabel()
    let zapsLabel = UILabel()
    let likesLabel = UILabel()
    let repostsLabel = UILabel()
    
    let contentBotSpacer = SpacerView(height: 12)
    
    lazy var infoRow = UIStackView([repliesLabel, zapsLabel, likesLabel, repostsLabel, UIView()])
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        zapGallery = SmallZapGalleryView()
        zapGallery?.delegate = self
        
        parentSetup()
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func update(_ parsedContent: ParsedContent, position: ThreadCell.ThreadPosition) {
        self.update(parsedContent, zaps: [])
    }
    
    func update(_ parsedContent: ParsedContent, zaps: [ParsedZap]?) {
        super.update(parsedContent, position: .main)
        
        selectionTextView.attributedText = parsedContent.attributedText
        selectionTextView.superview?.isHidden = selectionTextView.text.isEmpty
        
        timeLabel.text = parsedContent.longDateString()
        
        let post = parsedContent.post
        
        repliesLabel.attributedText = infoString(post.replies, "Reply", "Replies")
        repliesLabel.isHidden = post.replies <= 0
        
        zapsLabel.attributedText = infoString(post.zaps, "Zap", "Zaps")
        zapsLabel.isHidden = post.zaps <= 0
        
        likesLabel.attributedText = infoString(post.likes, "Like", "Likes")
        likesLabel.isHidden = post.likes <= 0
        
        repostsLabel.attributedText = infoString(post.reposts, "Repost", "Reposts")
        repostsLabel.isHidden = post.reposts <= 0
        
        infoRow.isHidden = post.replies + post.zaps + post.likes + post.reposts <= 0
        
        contentBotSpacer.isHidden = !mainLabel.isHidden && mainImages.isHidden && linkPresentation.isHidden && postPreview.isHidden && articleView.isHidden && invoiceView.isHidden && infoView.isHidden
        
        if let zaps {
            if zaps.isEmpty {
                zapGallery?.isHidden = true
            } else {
                zapGallery?.isHidden = false
                zapGallery?.zaps = zaps
                
//                zapGalleryHeightConstraint?.constant = zaps.count < 4 ? 24 : 56
            }
        } else {
            zapGallery?.isHidden = post.zaps == 0
            zapGallery?.zaps = []
            
//            zapGalleryHeightConstraint?.constant = post.zaps < 4 ? 24 : 56
        }
    }
    
    override func updateMenu(_ content: ParsedContent) {
        super.updateMenu(content)
        
        bookmarkUpdater = BookmarkManager.instance.isBookmarkedPublisher(content).receive(on: DispatchQueue.main)
            .sink { [weak self] isBookmarked in
                self?.isShowingBookmarked = isBookmarked
                self?.bookmarkButton.setImage(UIImage(named: isBookmarked ? "feedBookmarksBigFilled" : "feedBookmarksBig"), for: .normal)
            } 
    }
    
    func infoString(_ count: Int, _ singleTitle: String, _ pluralTitle: String) -> NSAttributedString {
        let title = count == 1 ? singleTitle : pluralTitle
        let text = NSMutableAttributedString(string: "\(count) ", attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .semibold),
            .foregroundColor: UIColor.foreground
        ])
        text.append(.init(string: title, attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .foregroundColor: UIColor.foreground4
        ]))
        return text
    }
    
    func setup() {
        parentIndicator
            .pinToSuperview(edges: .top)
            .pinToSuperview(edges: .bottom, padding: -24)
        
        threeDotsButton.constrainToSize(width: 22)
        threeDotsButton.transform = .init(translationX: 0, y: -4)
        
        profileImageView.constrainToSize(42)
        profileImageView.layer.cornerRadius = 21
        
        separatorLabel.text = ""
        separatorLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        mainImages.noDownsampling = true
        postPreview.mainImages.noDownsampling = true
        
        nameStack.removeArrangedSubview(nipLabel)
        let nameVStack = UIStackView(axis: .vertical, [nameStack, nipLabel])
        nameVStack.spacing = 0
        
        let horizontalProfileStack = UIStackView(arrangedSubviews: [profileImageView, nameVStack, threeDotsButton])
        horizontalProfileStack.alignment = .center
        
        let descStack = UIStackView(axis: .vertical, [zapGallery!, timeLabel, infoRow, SpacerView(height: 4), SpacerView(height: 1, color: .background3), bottomButtonStack])
        descStack.spacing = 8
        descStack.setCustomSpacing(20, after: zapGallery!)
        timeLabel.font = .appFont(withSize: 16, weight: .regular)
        infoRow.spacing = 12
        
//        zapGalleryHeightConstraint = zapGallery.heightAnchor.constraint(equalToConstant: 24)
//        zapGalleryHeightConstraint?.isActive = true
        
        let textViewParent = UIView()
        let contentStack = UIStackView(axis: .vertical, [textViewParent, articleView, invoiceView, mainImages, linkPresentation, postPreview, zapPreview, infoView, contentBotSpacer])
        let mainStack = UIStackView(axis: .vertical, [horizontalProfileStack, contentStack, descStack])
        contentView.addSubview(mainStack)
        
        mainStack
            .pinToSuperview(edges: .horizontal, padding: 12)

        topConstraint = mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0)
        topConstraint?.isActive = true
        
        contentBotSpacer.isHidden = true
            
        let bottomC = mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        bottomC.priority = .defaultLow
        bottomC.isActive = true
        bottomConstraint = bottomC
        
        horizontalProfileStack.spacing = 8
        
        contentStack.spacing = 8
        contentStack.setCustomSpacing(0, after: textViewParent)
        
        mainStack.spacing = 12
        mainStack.setCustomSpacing(0, after: contentStack)
        
        textViewParent.addSubview(selectionTextView)
        selectionTextView
            .pinToSuperview(edges: .horizontal, padding: -5)
            .pinToSuperview(edges: .vertical, padding: -5)
        
        selectionTextView.backgroundColor = .background2
        selectionTextView.linkTextAttributes = [:]
        selectionTextView.isEditable = false
        selectionTextView.isScrollEnabled = false
        selectionTextView.delegate = self
        
        [replyButton, zapButton, likeButton, repostButton].forEach {
            $0.titleLabel.removeFromSuperview()
            $0.bigMode = true
        }
        
        bottomButtonStack.addArrangedSubview(bookmarkButton)
        bookmarkButton.constrainToSize(width: 36)
        bookmarkButton.contentHorizontalAlignment = .center
        bottomButtonStack.distribution = .fill
        bottomButtonStack.arrangedSubviews.dropFirst().dropLast().forEach { view in
            view.widthAnchor.constraint(equalTo: replyButton.widthAnchor).isActive = true
        }
        
        zapsLabel.addGestureRecognizer(BindableTapGestureRecognizer(action: { [unowned self] in
            delegate?.postCellDidTap(self, .zapDetails)
        }))
        
        repostsLabel.addGestureRecognizer(BindableTapGestureRecognizer(action: { [unowned self] in
            delegate?.postCellDidTap(self, .repostDetails)
        }))
        
        likesLabel.addGestureRecognizer(BindableTapGestureRecognizer(action: { [unowned self] in
            delegate?.postCellDidTap(self, .likeDetails)
        }))
        
        [zapsLabel, repostsLabel, likesLabel].forEach { $0.isUserInteractionEnabled = true }
    }
}


extension DefaultMainThreadCell: UITextViewDelegate {
    @available(iOS 17.0, *)
    func textView(_ textView: UITextView, primaryActionFor textItem: UITextItem, defaultAction: UIAction) -> UIAction? {
        guard case .link(let url) = textItem.content else { return nil }
        return .init { [weak self] _ in
            self?.delegate?.postCellDidTap(self!, .url(url))
        }
    }
    
    @available(iOS 17.0, *)
    func textView(_ textView: UITextView, menuConfigurationFor textItem: UITextItem, defaultMenu: UIMenu) -> UITextItem.MenuConfiguration? {
        guard case .link(let url) = textItem.content else { return .init(menu: defaultMenu) }
        
        if url.scheme == "hashtag" {
            let hashtag = url.absoluteString.replacing("hashtag://", with: "")
            return UITextItem.MenuConfiguration(preview: .view(HashtagPreviewView(hashtag: hashtag)), menu: .init(children: [
                UIAction(title: "Open \(hashtag) feed", image: UIImage(systemName: "square.stack.fill"), handler: { [weak self] _ in
                    self?.delegate?.postCellDidTap(self!, .url(url))
                }),
                UIAction(title: "Copy hashtag", image: UIImage(named: "MenuCopyText"), handler: { _ in
                    UIPasteboard.general.string = hashtag
                    RootViewController.instance.view?.showToast("Copied!", extraPadding: 0)
                })
            ]))
        }
        
        if url.scheme == "mention" {
            let mention = url.absoluteString.replacing("mention://", with: "")
            
            return UITextItem.MenuConfiguration(preview: .view(ProfilePreviewView(pubkey: mention)), menu: .init(children: [
                UIAction(title: "Open profile", image: UIImage(systemName: "person.crop.circle.fill"), handler: { [weak self] _ in
                    self?.delegate?.postCellDidTap(self!, .url(url))
                }),
                UIAction(title: "Copy pubkey", image: UIImage(named: "MenuCopyText"), handler: { _ in
                    UIPasteboard.general.string = bech32_pubkey(mention) ?? mention
                    RootViewController.instance.view?.showToast("Copied!", extraPadding: 0)
                })
            ]))
        }
        
        if url.scheme == "highlight" {
            let highlight = url.absoluteString.replacingOccurrences(of: "highlight://", with: "")
            
//            return UITextItem.MenuConfiguration(preview: .view(ProfilePreviewView(pubkey: mention)), menu: .init(children: [
//                UIAction(title: "Open Article", image: UIImage(systemName: "person.crop.circle.fill"), handler: { [weak self] _ in
//                    self?.delegate?.postCellDidTap(self!, .url(url))
//                })
//            ]))
            return nil
        }
        
        return .init(preview: .default, menu: defaultMenu)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        delegate?.postCellDidTap(self, .url(URL))
        return false
    }
}

private extension ParsedContent {
    func longDateString() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(post.created_at))
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy • hh:mm a"
        return dateFormatter.string(from: date)
    }
}

class MainThreadCellTextView: UITextView {
    let maxWidth: CGFloat = UIScreen.main.bounds.width - 24
    
    override var attributedText: NSAttributedString! {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        var size = attributedText.boundingRect(
            with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).size
        
        size.height += 20
        return size
    }
}
