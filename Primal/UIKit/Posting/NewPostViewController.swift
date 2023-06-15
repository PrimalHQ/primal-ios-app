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
    let textView = UITextView()
    let imageView = UIImageView(image: UIImage(named: "Profile"))
    
    let usersTableView = UITableView()
    
    let imageButton = UIButton()
    let cameraButton = UIButton()
    lazy var bottomStack = UIStackView(arrangedSubviews: [imageButton, cameraButton, UIView()])
    
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
        let text = manager.postingText
        
        guard !text.isEmpty else {
            showErrorMessage("Text mustn't be empty")
            return
        }
        
        PostManager.instance.sendPostEvent(text, mentionedPubkeys: manager.mentionedUsersPubkeys) { [weak self] in
            self?.dismiss(animated: true)
        }
    }
    
    func setup() {
        view.backgroundColor = .background2
        
        let cancel = CancelButton()
        let post = GradientInGradientButton(title: "Post")
        let topStack = UIStackView(arrangedSubviews: [cancel, UIView(), post])
        post.constrainToSize(width: 88, height: 32)
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
        
        imageButton.setImage(UIImage(named: "ImageIcon"), for: .normal)
        imageButton.constrainToSize(48)
        cameraButton.setImage(UIImage(named: "CameraIcon"), for: .normal)
        cameraButton.constrainToSize(48)
        
        bottomStack.isLayoutMarginsRelativeArrangement = true
        bottomStack.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        bottomStack.spacing = 4
        
        let border = SpacerView(height: 1, priority: .required)
        border.backgroundColor = .background3
        
        let mainStack = UIStackView(arrangedSubviews: [topStack, contentStack, border, usersTableView, bottomStack])
        mainStack.axis = .vertical
        view.addSubview(mainStack)
        mainStack.pinToSuperview(edges: [.horizontal, .top])
        
        NSLayoutConstraint.activate([
            mainStack.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 90),
        ])
        
        cancel.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        post.addTarget(self, action: #selector(postButtonPressed), for: .touchUpInside)
        
        setupBindings()
    }
    
    func setupBindings() {
        IdentityManager.instance.$user.receive(on: DispatchQueue.main).sink { [weak self] user in
            guard let self, let user else { return }
            
            self.imageView.kf.setImage(with: URL(string: user.picture), options: [
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
    }
}
