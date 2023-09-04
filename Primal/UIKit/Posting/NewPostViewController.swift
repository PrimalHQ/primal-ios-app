//
//  NewPostViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 24.5.23..
//

import Combine
import UIKit
import Kingfisher

class NewPostViewController: UIViewController {
    let postButtonText = "Post"
    
    let textView = UITextView()
    let imageView = UIImageView(image: UIImage(named: "Profile"))
    
    let usersTableView = UITableView()
    let imagesCollectionView = PostingImageCollectionView()
    
    let imageButton = UIButton()
    let cameraButton = UIButton()
    let atButton = UIButton()
    lazy var bottomStack = UIStackView(arrangedSubviews: [imageButton, cameraButton, atButton, UIView()])
    
    lazy var postButton = GradientInGradientButton(title: postButtonText)
    
    lazy var manager = PostingTextViewManager(textView: textView, usersTable: usersTableView)
    
    private var cancellables: Set<AnyCancellable> = []
        
    init() {
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

private extension NewPostViewController {
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
        
        postButton.isEnabled = false
        postButton.titleLabel.text = "Posting..."
        
        PostManager.instance.sendPostEvent(text, mentionedPubkeys: manager.mentionedUsersPubkeys) { [weak self] success in
            if success {
                self?.postButton.titleLabel.text = "Posted"
                self?.dismiss(animated: true)
            } else {
                self?.postButton.titleLabel.text = self?.postButtonText
                self?.postButton.isEnabled = true
            }
        }
    }
    
    @objc func galleryButtonPressed() {
        ImagePickerManager(self, mode: .gallery) { [weak self] image, isPNG in
            self?.manager.processSelectedImage(image, isPNG: isPNG)
        }
    }
    
    @objc func cameraButtonPressed() {
        ImagePickerManager(self, mode: .camera) { [weak self] image, isPNG in
            self?.manager.processSelectedImage(image, isPNG: isPNG)
        }
    }
    
    func setup() {
        view.backgroundColor = .background2
        
        let cancel = CancelButton()
        let topStack = UIStackView(arrangedSubviews: [cancel, UIView(), postButton])
        postButton.constrainToSize(width: 88, height: 32)
        cancel.constrainToSize(width: 88, height: 32)
        
        topStack.isLayoutMarginsRelativeArrangement = true
        topStack.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        let imageParent = UIView()
        imageParent.addSubview(imageView)
        imageView.constrainToSize(52).pinToSuperview(edges: [.horizontal, .top])
                
        let contentStack = UIStackView(arrangedSubviews: [imageParent, textView])
        contentStack.spacing = 10
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        
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
        
        let mainStack = UIStackView(arrangedSubviews: [topStack, contentStack, imagesCollectionView, border, usersTableView, bottomStack])
        mainStack.axis = .vertical
        view.addSubview(mainStack)
        mainStack.pinToSuperview(edges: [.horizontal, .top])
        
        mainStack.setCustomSpacing(16, after: imagesCollectionView)
        
        imagesCollectionView.imageDelegate = manager
        imagesCollectionView.isHidden = true
        imagesCollectionView.backgroundColor = .background2
        
        let keyboardConstraint = mainStack.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        keyboardConstraint.priority = .defaultHigh // Constraint breaks when dismmising the view controller (keyboard is showing)
        
        NSLayoutConstraint.activate([
            keyboardConstraint,
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 90),
        ])
        
        cancel.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        postButton.addTarget(self, action: #selector(postButtonPressed), for: .touchUpInside)
        atButton.addTarget(manager, action: #selector(PostingTextViewManager.atButtonPressed), for: .touchUpInside)
        imageButton.addTarget(self, action: #selector(galleryButtonPressed), for: .touchUpInside)
        cameraButton.addTarget(self, action: #selector(cameraButtonPressed), for: .touchUpInside)
        
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
        
        Publishers.CombineLatest3(manager.$users, manager.$images, manager.$isEmpty).receive(on: DispatchQueue.main).sink { [weak self] users, images, isEmpty in
            guard let self else { return }
            self.postButton.isEnabled = !isEmpty && !self.manager.isUploadingImages
        }
        .store(in: &cancellables)
                
        Publishers.CombineLatest(manager.$users, manager.$images).receive(on: DispatchQueue.main).sink { [weak self] users, images in
            guard let self else { return }
            self.imagesCollectionView.imageResources = images
            
            self.imagesCollectionView.isHidden = images.isEmpty || !users.isEmpty
            
            self.postButton.titleLabel.text = self.manager.isUploadingImages ? "Uploading..." : self.postButtonText
        }
        .store(in: &cancellables)
    }
}
