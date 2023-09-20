//
//  ChatViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 8.9.23..
//

import UIKit
import FLAnimatedImage

final class ChatViewController: UIViewController, Themeable {
    var table = UITableView()
    
    let chatManager = ChatManager()
    
    private var textHeightConstraint: NSLayoutConstraint?
    let textInputView = SelfSizingTextView()
    let textInputLoadingIndicator = LoadingSpinnerView().constrainToSize(30)
    private let placeholderLabel = UILabel()
    private let inputParent = UIView()
    private let inputBackground = UIView()
    private let bottomBarSpacer = UIView()
    
    private lazy var postButton = GradientInGradientButton(title: "Reply")
    private let buttonStack = UIStackView()
    
    private var inputContentMaxHeightConstraint: NSLayoutConstraint?
    
    var messages: [ProcessedMessage] = [] {
        didSet {
            table.reloadData()
        }
    }
    
    let user: ParsedUser
    
    init(user: ParsedUser) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        setup()
        
        navigationItem.rightBarButtonItem = navigationBarButton(for: user)
        
        chatManager.getChatMessages(pubkey: user.data.pubkey) { result in
            print(result)
            self.messages = result
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        navigationItem.leftBarButtonItem = customBackButton
        navigationItem.titleView = navigationBarTitle(for: user)
        
        view.backgroundColor = .background
        
        inputParent.backgroundColor = false ? .background2 : .background
        inputBackground.backgroundColor = false ? .background : .background3
    }
}

private extension ChatViewController {
    func setup() {
        updateTheme()
        
        let stack = UIStackView(axis: .vertical, [table, inputParent, bottomBarSpacer])
        view.addSubview(stack)
        stack.pinToSuperview(edges: [.horizontal, .top], safeArea: true).pinToSuperview(edges: .bottom, padding: 56, safeArea: true)
        table.transform = .init(rotationAngle: .pi)
        table.dataSource = self
        table.separatorStyle = .none
        table.register(ChatMessageCell.self, forCellReuseIdentifier: "cell")
        
        inputBackground.layer.cornerRadius = 6
        
        let inputStack = UIStackView(arrangedSubviews: [inputBackground, buttonStack])
        inputStack.axis = .vertical
        
        inputParent.addSubview(inputStack)
        inputBackground.addSubview(placeholderLabel)
        
        let textParent = UIView()
        let contentStack = UIStackView(axis: .vertical, [textParent])
        contentStack.spacing = 12
        
        inputBackground.addSubview(contentStack)
        textParent.addSubview(textInputView)
        
        textParent.addSubview(textInputLoadingIndicator)
        textInputLoadingIndicator.centerToView(textInputView)
        textInputLoadingIndicator.isHidden = true
        
        contentStack
            .pinToSuperview(edges: [.top, .horizontal])
            .pinToSuperview(edges: .bottom, padding: 5)
        
        placeholderLabel
            .pinToSuperview(edges: .leading, padding: 21)
            .pinToSuperview(edges: .top, padding: 13)
        
        textInputView
            .pinToSuperview(edges: .horizontal, padding: 16)
            .pinToSuperview(edges: .top, padding: 5)
            .pinToSuperview(edges: .bottom)
        
        inputStack
            .pinToSuperview(edges: .horizontal, padding: 20)
            .pinToSuperview(edges: .top, padding: 16)
            .pinToSuperview(edges: .bottom)
        
        let bottomC = bottomBarSpacer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -56)
        bottomC.priority = .defaultLow
        bottomC.isActive = true
        
        bottomBarSpacer.topAnchor.constraint(lessThanOrEqualTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        
        inputStack.spacing = 4
        
        textInputView.backgroundColor = .clear
        textInputView.font = .appFont(withSize: 16, weight: .regular)
        textInputView.textColor = .foreground2
//        textInputView.delegate = inputManager
        textInputView.returnKeyType = .send
        
        let imageButton = UIButton()
        imageButton.setImage(UIImage(named: "ImageIcon"), for: .normal)
        imageButton.constrainToSize(48)
        imageButton.addAction(.init(handler: { [unowned self] _ in
            ImagePickerManager(self, mode: .gallery) { [weak self] image, isPNG in
//                self?.inputManager.processSelectedImage(image, isPNG: isPNG)
            }
        }), for: .touchUpInside)
        
        let cameraButton = UIButton()
        cameraButton.setImage(UIImage(named: "CameraIcon"), for: .normal)
        cameraButton.constrainToSize(48)
        cameraButton.addAction(.init(handler: { [unowned self] _ in
            ImagePickerManager(self, mode: .camera) { [weak self] image, isPNG in
//                self?.inputManager.processSelectedImage(image, isPNG: isPNG)
            }
        }), for: .touchUpInside)
        
        postButton.titleLabel.font = .appFont(withSize: 14, weight: .medium)
        postButton.constrainToSize(width: 80, height: 28)
//        postButton.addTarget(self, action: #selector(postButtonPressed), for: .touchUpInside)
        
        let atButton = UIButton()
        atButton.setImage(UIImage(named: "AtIcon"), for: .normal)
//        atButton.addTarget(inputManager, action: #selector(PostingTextViewManager.atButtonPressed), for: .touchUpInside)
        
        [imageButton, cameraButton, atButton, UIView(), postButton].forEach {
            buttonStack.addArrangedSubview($0)
        }
        atButton.widthAnchor.constraint(equalTo: imageButton.widthAnchor).isActive = true
        
        buttonStack.alignment = .center
        
        placeholderLabel.font = .appFont(withSize: 16, weight: .regular)
        placeholderLabel.textColor = .foreground4
        
        buttonStack.isHidden = true
        buttonStack.alpha = 0
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(inputSwippedDown))
        swipe.direction = .down
        inputParent.addGestureRecognizer(swipe)
        
        textInputView.heightAnchor.constraint(greaterThanOrEqualToConstant: 35).isActive = true
        textHeightConstraint = textInputView.heightAnchor.constraint(equalToConstant: 35)
        inputContentMaxHeightConstraint = contentStack.heightAnchor.constraint(equalToConstant: 600)
        
        inputContentMaxHeightConstraint?.priority = .defaultHigh
    }
    
    func navigationBarTitle(for user: ParsedUser) -> UIView {
        let first = UILabel()
        let second = UILabel()
        
        first.text = user.data.firstIdentifier
        second.text = user.data.secondIdentifier
        
        first.font = .appFont(withSize: 18, weight: .bold)
        first.textColor = .foreground
        
        second.font = .appFont(withSize: 14, weight: .regular)
        second.textColor = .foreground4
        second.isHidden = second.text?.isEmpty != false
        
        let stack = UIStackView(axis: .vertical, [first, second])
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }
    
    func navigationBarButton(for user: ParsedUser) -> UIBarButtonItem {
        let button = UIButton()
        button.addAction(.init(handler: { [weak self] _ in
            self?.show(ProfileViewController(profile: user), sender: nil)
        }), for: .touchUpInside)
        let imageView = FLAnimatedImageView(frame: .init(origin: .zero, size: .init(width: 36, height: 36))).constrainToSize(36)
        imageView.layer.cornerRadius = 18
        imageView.layer.masksToBounds = true
        imageView.setUserImage(user)
        let parent = UIView()
        parent.addSubview(imageView)
        imageView.centerToSuperview()
        parent.addSubview(button)
        button.pinToSuperview()
        return .init(customView: parent)
    }
    
    @objc func inputSwippedDown() {
        textInputView.resignFirstResponder()
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let row = indexPath.row
        let userId = messages[row].user.data.npub
        cell.transform = tableView.transform
        (cell as? ChatMessageCell)?.setupWith(message: messages[row], isFirstInSeries: row == 0 || messages[row - 1].user.data.npub != userId)
        return cell
    }
}
