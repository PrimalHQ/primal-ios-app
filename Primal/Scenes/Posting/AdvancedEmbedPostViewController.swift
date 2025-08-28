//
//  AdvancedEmbedPostViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.7.24..
//

import Combine
import UIKit
import Kingfisher

enum PostEmbedPreview {
    case highlight(Article, Highlight)
    case post(ParsedContent)
    case article(Article)
    case invoice(Invoice, String)
    case live(ParsedLiveEvent)
}

class AdvancedEmbedPostViewController: UIViewController {
    let postButtonText = "Post"
    
    let textView = SelfSizingTextView()
    let imageView = UIImageView(image: UIImage(named: "Profile"))
    
    let usersTableView = UITableView()
    let imagesCollectionView = PostingImageCollectionView(inset: .init(top: 0, left: 0, bottom: 0, right: 16))
    
    let imageButton = UIButton()
    let cameraButton = UIButton()
    let atButton = UIButton()
    let clearButton = UIButton(configuration: .capsuleBackground3(text: "Clear")).constrainToSize(width: 80, height: 28)
    lazy var bottomStack = UIStackView(arrangedSubviews: [imageButton, cameraButton, atButton, UIView(), clearButton])
    
    lazy var postButton = SmallPostButton(title: postButtonText)
    
    let embeddedPreviewStack = UIStackView(axis: .vertical, [])
    
    let manager: PostingTextViewManager
    
    private var cancellables: Set<AnyCancellable> = []
    
    var onPost: (() -> Void)?
    
    init(including: PostEmbedPreview? = nil, onPost: (() -> Void)? = nil) {
        manager = PostingTextViewManager(textView: textView, usersTable: usersTableView, replyId: nil, replyingTo: nil)
        
        self.onPost = onPost
        super.init(nibName: nil, bundle: nil)
        
        if let including {
            manager.embeddedElements.append(including)
        }
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

private extension AdvancedEmbedPostViewController {
    @objc func postButtonPressed() {
        if manager.didUploadFail {
            manager.restartFailedUploads()
            return
        }
        
        if manager.isUploadingImages {
            return
        }
        
        let text = manager.postingText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !text.isEmpty else {
            showErrorMessage(title: "Please Enter Text", "Text cannot be empty")
            return
        }
        
        let onPost = self.onPost
        manager.post { success, _ in
            if success {
                onPost?()
            }
        }
        dismiss(animated: true)
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
        presentationController?.delegate = self
        view.backgroundColor = .background2
        
        let verticalStack = UIStackView(axis: .vertical, [textView, imagesCollectionView, embeddedPreviewStack])
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
        
        embeddedPreviewStack.spacing = 4
        
        imageView.layer.cornerRadius = 26
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        imageButton.setImage(UIImage(named: "ImageIcon"), for: .normal)
        cameraButton.setImage(UIImage(named: "CameraIcon"), for: .normal)
        atButton.setImage(UIImage(named: "AtIcon"), for: .normal)
        
        [imageButton, cameraButton, atButton].forEach {
            $0.tintColor = .foreground
            $0.constrainToSize(48)
        }
        
        bottomStack.isLayoutMarginsRelativeArrangement = true
        bottomStack.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        bottomStack.spacing = 4
        bottomStack.alignment = .center
        
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
            verticalStack.widthAnchor.constraint(equalTo: contentStack.widthAnchor, constant: -102)
        ])
        
        postButton.addTarget(self, action: #selector(postButtonPressed), for: .touchUpInside)
        atButton.addTarget(manager, action: #selector(PostingTextViewManager.atButtonPressed), for: .touchUpInside)
        imageButton.addTarget(self, action: #selector(galleryButtonPressed), for: .touchUpInside)
        cameraButton.addTarget(self, action: #selector(cameraButtonPressed), for: .touchUpInside)
        
        cancel.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            if manager.isPosting {
                manager.askToDeleteDraft(self) { [weak self] delete in
                    if !delete {
                        self?.dismiss(animated: true)
                    }
                }
                return
            }
            
            manager.askToSaveThenDismiss(self)
        }), for: .touchUpInside)
        
        clearButton.addAction(.init(handler: { [weak self] _ in
            if self?.manager.postingText.isEmpty == true  { return }
            
            let alert = UIAlertController(title: "Are you sure?", message: "Clear everything?", preferredStyle: .alert)
            alert.addAction(.init(title: "Cancel", style: .cancel))
            alert.addAction(.init(title: "Clear", style: .destructive, handler: { _ in
                self?.manager.reset()
            }))
            self?.present(alert, animated: true)
        }), for: .touchUpInside)
        
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
        
        manager.$postButtonEnabledState.assign(to: \.isEnabled, on: postButton).store(in: &cancellables)
        manager.$postButtonTitle.sink { [postButton] title in
            postButton.setTitle(title, for: .normal)
        }
        .store(in: &cancellables)
        
        manager.$isPosting.map({ !$0 }).assign(to: \.isUserInteractionEnabled, on: bottomStack).store(in: &cancellables)
        
        Publishers.CombineLatest(
            manager.$users.map({ $0.isEmpty }).removeDuplicates(),
            manager.$media
        ).receive(on: DispatchQueue.main).sink { [weak self] isUsersEmpty, images in
            guard let self else { return }
            self.imagesCollectionView.imageResources = images
            
            self.imagesCollectionView.isHidden = images.isEmpty || !isUsersEmpty
            self.embeddedPreviewStack.isHidden = !isUsersEmpty
        }
        .store(in: &cancellables)
        
        manager.$embeddedElements.sink { [weak self] elements in
            guard let self else { return }
            
            embeddedPreviewStack.arrangedSubviews.forEach{ $0.removeFromSuperview() }
            
            elements.enumerated().forEach { index, item in
                let view = item.makeView()
                
                if case .highlight = item {
                    self.embeddedPreviewStack.addArrangedSubview(view)
                    return
                }
                
                let myView = UIView()
                
                view.isUserInteractionEnabled = false
                view.layer.borderWidth = 0
                view.backgroundColor = .background3
                myView.addSubview(view)
                view.pinToSuperview()
                
                let xButton = UIButton(configuration: .simpleImage("deleteImageIcon"))
                myView.addSubview(xButton)
                xButton.constrainToSize(24).pinToSuperview(edges: [.top, .trailing], padding: 8)
                xButton.addAction(.init(handler: { [unowned self] _ in
                    self.manager.embeddedElements.remove(at: index)
                }), for: .touchUpInside)
                
                self.embeddedPreviewStack.addArrangedSubview(myView)
            }
        }
        .store(in: &cancellables)
    }
}

extension AdvancedEmbedPostViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        manager.askToSaveThenDismiss(self)
    }
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        false
    }
}

extension PostEmbedPreview {
    func makeView() -> UIView {
        switch self {
        case .highlight(let article, let highlight):
            return HighlightPreviewView(article: article, highlight: highlight)
        case .article(let article):
            let view = CompactArticleView()
            view.setUp(article)
            return view
        case .post(let post):
            let view = PostPreviewView()
            view.update(post)
            view.updateTheme()
            return view
        case .invoice(let invoice, _):
            let view = LightningInvoiceView()
            view.updateForInvoice(invoice)
            view.copyButton.isHidden = true
            return view
        case .live(let live):
            let view = LivePreviewView()
            view.setLive(live: live)
            return view
        }
    }
    
    func embedText() -> String {
        switch self {
        case .highlight(let article, let highlight):
            let highlightText: String = {
                guard let noteRef = highlight.event.getNevent() else { return "" }
                return "nostr:\(noteRef)"
            }()
            
            let articleText: String = {
                return "nostr:\(article.asParsedContent.noteId(extended: true))"
            }()
         
            return highlightText + "\n" + articleText
        case .article(let article):
            return "nostr:" + article.asParsedContent.noteId(extended: true)
        case .post(let post):
            return "nostr:" + post.noteId(extended: true)
        case .live(let live):
            return "nostr:\(live.event.noteId())"
        case .invoice(_, let text):
            return text
        }
    }
}

class HighlightPreviewView: UIStackView {
    init(article: Article, highlight: Highlight) {
        super.init(frame: .zero)
        
        let highlightLabel = UILabel()
        highlightLabel.attributedText = NSAttributedString(string: highlight.content, attributes: [
            .foregroundColor: UIColor.foreground,
            .backgroundColor: UIColor.highlight,
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
        
        addArrangedSubview(highlightLabel)
        addArrangedSubview(articleView)
        axis = .vertical
        spacing = 4
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
