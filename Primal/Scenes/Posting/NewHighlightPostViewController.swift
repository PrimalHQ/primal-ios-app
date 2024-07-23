//
//  NewHighlightPostViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.7.24..
//

import Combine
import UIKit
import Kingfisher

class NewHighlightPostViewController: UIViewController {
    let postButtonText = "Post"
    
    let textView = SelfSizingTextView()
    let imageView = UIImageView(image: UIImage(named: "Profile"))
    
    let usersTableView = UITableView()
    let imagesCollectionView = PostingImageCollectionView(inset: .init(top: 0, left: 0, bottom: 0, right: 16))
    
    let imageButton = UIButton()
    let cameraButton = UIButton()
    let atButton = UIButton()
    lazy var bottomStack = UIStackView(arrangedSubviews: [imageButton, cameraButton, atButton, UIView()])
    
    lazy var postButton = SmallPostButton(title: postButtonText)
    
    lazy var manager = PostingTextViewManager(textView: textView, usersTable: usersTableView)
    
    private var cancellables: Set<AnyCancellable> = []
    
    var replyToPost: PrimalFeedPost?
    
    var onPost: (() -> Void)?
    
    let article: Article
    let highlight: Highlight
    init(article: Article, highlight: Highlight) {
        self.article = article
        self.highlight = highlight
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textView.becomeFirstResponder()
    }
}

private extension NewHighlightPostViewController {
    @objc func postButtonPressed() {
        if manager.didUploadFail {
            manager.restartFailedUploads()
            return
        }
        
        if manager.isUploadingImages {
            return
        }
        

        let highlightText: String = {
            guard let noteRef = bech32_note_id(highlight.event.id) else { return ""}
            return "\nnostr:\(noteRef)"
        }()
        
        let articleText: String = {
            return ""
        }()
        
        let text = manager.postingText.trimmingCharacters(in: .whitespacesAndNewlines) + highlightText + articleText
        
        postButton.isEnabled = false
        postButton.setTitle(" " + postButtonText + " ", for: .normal)
        
        let callback: (Bool) -> Void = { [weak self] success in
            if success {
                self?.postButton.setTitle("Posted", for: .normal)
                self?.onPost?()
                self?.dismiss(animated: true) {
                    self?.postButton.setTitle(self?.postButtonText, for: .normal)
                    self?.manager.media = []
                    self?.textView.text = ""
                }
            } else {
                self?.postButton.setTitle(self?.postButtonText, for: .normal)
                self?.postButton.isEnabled = true
            }
        }
        
        if let replyToPost {
            PostingManager.instance.sendReplyEvent(text, mentionedPubkeys: manager.mentionedUsersPubkeys, post: replyToPost, callback)
        } else {
            PostingManager.instance.sendPostEvent(text, mentionedPubkeys: manager.mentionedUsersPubkeys, callback)
        }
    }
    
    @objc func galleryButtonPressed() {
        ImagePickerManager(self, mode: .gallery, allowVideo: true) { [weak self] result in
            self?.manager.processSelectedAsset(result)
        }
    }
    
    @objc func cameraButtonPressed() {
        ImagePickerManager(self, mode: .camera) { [weak self] result in
            self?.manager.processSelectedAsset(result)
        }
    }
    
    func setup() {
        view.backgroundColor = .background2
        
        let highlightLabel = UILabel()
        highlightLabel.attributedText = NSAttributedString(string: highlight.content, attributes: [
            .foregroundColor: UIColor.foreground,
            .backgroundColor: UIColor.init(rgb: 0x3D4933),
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .paragraphStyle: {
                let newParagraph = NSMutableParagraphStyle()
                newParagraph.lineSpacing = 0
                newParagraph.minimumLineHeight = 28
                newParagraph.maximumLineHeight = 28
                return newParagraph
            }()
        ])
        highlightLabel.numberOfLines = 4
        highlightLabel.lineBreakMode = .byTruncatingTail
        
        let articleView = CompactArticleView()
        articleView.setUp(article)
        
        let verticalStack = UIStackView(axis: .vertical, [textView, imagesCollectionView, highlightLabel, articleView])
        verticalStack.spacing = 12
        let scrollView = UIScrollView()
        scrollView.addSubview(verticalStack)
        verticalStack.pinToSuperview()
        
        let imageParent = UIView()
        imageParent.addSubview(imageView)
        imageView.constrainToSize(52).pinToSuperview(edges: [.horizontal, .top])
                
        let contentStack = UIStackView(arrangedSubviews: [imageParent, scrollView])
        contentStack.spacing = 10
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        
        verticalStack.widthAnchor.constraint(equalTo: contentStack.widthAnchor, constant: -102).isActive = true
        
        imageView.layer.cornerRadius = 26
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        imageButton.setImage(UIImage(named: "ImageIcon"), for: .normal)
        imageButton.constrainToSize(48)
        cameraButton.setImage(UIImage(named: "CameraIcon"), for: .normal)
        cameraButton.constrainToSize(48)
        atButton.setImage(UIImage(named: "AtIcon"), for: .normal)
        atButton.constrainToSize(48)
        
        bottomStack.isLayoutMarginsRelativeArrangement = true
        bottomStack.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        bottomStack.spacing = 4
        
        let border = SpacerView(height: 1, priority: .required)
        border.backgroundColor = .background3
        
        let cancel = CancelButton()
        let topStack = UIStackView(arrangedSubviews: [cancel, UIView(), postButton])
        postButton.constrainToSize(width: 88)
        cancel.constrainToSize(width: 88, height: 32)
        
        topStack.alignment = .center
        topStack.isLayoutMarginsRelativeArrangement = true
        topStack.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        let mainStack = UIStackView(arrangedSubviews: [topStack, contentStack, border, usersTableView, bottomStack])
        mainStack.axis = .vertical
        view.addSubview(mainStack)
        mainStack.pinToSuperview(edges: [.horizontal, .top])
        
        mainStack.setCustomSpacing(16, after: imagesCollectionView)
        
        imagesCollectionView.imageDelegate = manager
        imagesCollectionView.isHidden = true
        imagesCollectionView.backgroundColor = .background2
        
        let keyboardConstraint = mainStack.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        keyboardConstraint.priority = .defaultHigh // Constraint breaks when dismissing the view controller (keyboard is showing)
        
        NSLayoutConstraint.activate([
            keyboardConstraint,
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            contentStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 90),
        ])
        
        cancel.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        postButton.addTarget(self, action: #selector(postButtonPressed), for: .touchUpInside)
        atButton.addTarget(manager, action: #selector(PostingTextViewManager.atButtonPressed), for: .touchUpInside)
        imageButton.addTarget(self, action: #selector(galleryButtonPressed), for: .touchUpInside)
        cameraButton.addTarget(self, action: #selector(cameraButtonPressed), for: .touchUpInside)
        
        textView.tintColor = .accent
        
        setupBindings()
    }
    
    func setupBindings() {
        IdentityManager.instance.$user.receive(on: DispatchQueue.main).sink { [weak self] user in
            guard let self, let user else { return }
            
            self.imageView.kf.setImage(with: URL(string: user.picture), placeholder: UIImage(named: "Profile"), options: [
                .processor(DownsamplingImageProcessor(size: CGSize(width: 52, height: 52))),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ])
        }
        .store(in: &cancellables)
        
        manager.$users.receive(on: DispatchQueue.main).sink { [weak self] users in
            guard let self else { return }
            self.bottomStack.isHidden = !users.isEmpty
            self.usersTableView.isHidden = users.isEmpty
            self.manager.usersHeightConstraint.constant = CGFloat(users.count) * 60
            UIView.animate(withDuration: 0.3) {
                self.view.layoutSubviews()
                self.textView.scrollToCursorPosition()
            } completion: { _ in
                self.usersTableView.reloadData()
                self.textView.scrollToCursorPosition()
            }
            self.usersTableView.reloadData()
        }
        .store(in: &cancellables)
        
        manager.$media
            .debounce(for: 0.1, scheduler: RunLoop.main).sink { [weak self] images in
                guard let self else { return }
                let isUploadingImages: Bool = {
                    for image in images {
                        if case .uploading = image.state {
                            return true
                        }
                    }
                    return false
                }()
                
                self.postButton.setTitle(isUploadingImages ? "Uploading..." : self.postButtonText, for: .normal)
                self.postButton.isEnabled = (images.isEmpty || !isUploadingImages) && self.postButton.title(for: .normal) == self.postButtonText
            }
            .store(in: &cancellables)
                
        manager.$media.receive(on: DispatchQueue.main).sink { [weak self] images in
            guard let self else { return }
            
            self.imagesCollectionView.imageResources = images
            self.imagesCollectionView.isHidden = images.isEmpty
        }
        .store(in: &cancellables)
    }
}
