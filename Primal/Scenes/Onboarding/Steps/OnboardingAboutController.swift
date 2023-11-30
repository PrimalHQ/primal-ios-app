//
//  OnboardingAboutController.swift
//  Primal
//
//  Created by Pavle Stevanović on 17.11.23..
//

import Combine
import UIKit


final class OnboardingAboutController: UIViewController, OnboardingViewController {
    let titleLabel = UILabel()
    let backButton = UIButton()
    
    let avatarView = UIImageView(image: UIImage(named: "onboardingDefaultAvatar"))
    let addPhotoButton = SolidColorUIButton(title: "add photo", color: .white)
    
    let websiteInput = UITextField()
    let aboutInput = PlaceholderTextView()
    
    let nextButton = OnboardingMainButton("Next")
    let skipButton = SolidColorUIButton(title: "Skip", color: .white)
    
    let progressView = PrimalProgressView(progress: 1, total: 4)
    let descLabel = UILabel()
    
    var cancellables: Set<AnyCancellable> = []
    
    @Published var editingViews: Set<UIView> = []
    
    let uploader: OnboardingImageUploader
    let oldData: AccountCreationData
    
    var accountData: AccountCreationData {
        AccountCreationData(
            avatar: uploader.avatarURL,
            banner: uploader.bannerURL,
            bio: aboutInput.text ?? "",
            username: oldData.username,
            displayname: oldData.displayname,
            lightningWallet: "",
            nip05: "",
            website: websiteInput.text ?? ""
        )
    }
    
    init(data: AccountCreationData, uploader: OnboardingImageUploader) {
        oldData = data
        self.uploader = uploader
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let keypair = NostrKeypair.generate() else {
            fatalError("Unable to generate a new keypair, this shouldn't be possible")
        }
        
        IdentityManager.instance.newUserKeypair = keypair
        
        setup()
    }
    
    var lastRemoveTime: Date?
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let lastRemoveTime, lastRemoveTime.timeIntervalSinceNow > -0.5 { return }
        
        lastRemoveTime = .now
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
            self.onboardingParent?.removeFuture(self)
        }
    }
}

private extension OnboardingAboutController {
    func setup() {
        addBackground(2)
        addNavigationBar("Create Account")
        
        let avatarStack = UIStackView(axis: .vertical, [avatarView, SpacerView(height: 12, priority: .defaultLow), addPhotoButton])
        avatarStack.alignment = .center
        
        descLabel.numberOfLines = 0
        descLabel.setContentCompressionResistancePriority(.init(1), for: .vertical)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 8
        paragraph.alignment = .center
        descLabel.attributedText = .init(string: "Enter your website if you have one and tell us something about yourself.", attributes: [
            .foregroundColor:   UIColor.white,
            .font:              UIFont.appFont(withSize: 16, weight: .semibold),
            .paragraphStyle:    paragraph
        ])
        
        let formStack = UIStackView(axis: .vertical, [
            OnboardingInputParent(input: websiteInput).constrainToSize(height: 48), SpacerView(height: 12),
            OnboardingInputParent(input: aboutInput).constrainToSize(height: 128), SpacerView(height: 12),
            descLabel
        ])
        formStack.spacing = 3
        aboutInput.pinToSuperview(edges: .vertical, padding: 10)
        
        let keyboardSpacer = UIView()
        let bottomStack = UIStackView(axis: .vertical, [progressView, nextButton, skipButton, keyboardSpacer])
        let mainStack = UIStackView(axis: .vertical, [UIView(), avatarStack, formStack, bottomStack])
        view.insertSubview(mainStack, at: 1)
        mainStack.pinToSuperview(edges: .horizontal, padding: 35).pinToSuperview(edges: .bottom, padding: 12, safeArea: true)
        let topC = mainStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12)
        topC.priority = .init(999)
        topC.isActive = true
        keyboardSpacer.topAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -12).isActive = true
        
        bottomStack.setCustomSpacing(12, after: nextButton)
        
        mainStack.distribution = .equalSpacing
        
        avatarView.constrainToSize(108)
        avatarView.alpha = 0.5
        avatarView.contentMode = .scaleAspectFill
        avatarView.layer.cornerRadius = 54
        avatarView.layer.masksToBounds = true
        avatarView.layer.borderWidth = 3
        avatarView.layer.borderColor = UIColor.white.cgColor
        
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        addPhotoButton.setContentCompressionResistancePriority(.required, for: .vertical)
        
        websiteInput.delegate = self
        websiteInput.returnKeyType = .done
        websiteInput.keyboardType = .URL
        websiteInput.autocapitalizationType = .none
        websiteInput.font = .appFont(withSize: 16, weight: .semibold)
        websiteInput.textColor = .black
        websiteInput.attributedPlaceholder = NSAttributedString(string: "website", attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .semibold),
            .foregroundColor: UIColor.black.withAlphaComponent(0.5),
        ])
        
        aboutInput.didBeginEditing = { [weak self] view in
            self?.editingViews.insert(view)
        }
        aboutInput.didEndEditing = { [weak self] view in
            self?.editingViews.remove(view)
        }
        aboutInput.font = .appFont(withSize: 16, weight: .semibold)
        aboutInput.mainTextColor = .black
        aboutInput.placeholderTextColor = .black.withAlphaComponent(0.5)
        aboutInput.placeholderText = "about me"
        aboutInput.backgroundColor = .clear
        
        uploader.$image.receive(on: DispatchQueue.main).sink { [weak self] image in
            if let image {
                self?.avatarView.image = image
                self?.avatarView.alpha = 1
                self?.addPhotoButton.setTitle("change photo", for: .normal)
            } else {
                self?.avatarView.image =  UIImage(named: "onboardingDefaultAvatar")
                self?.avatarView.alpha = 0.5
                self?.addPhotoButton.setTitle("add photo", for: .normal)
            }
        }
        .store(in: &cancellables)
        
        $editingViews.dropFirst().map { !$0.isEmpty }
            .removeDuplicates()
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEditing in
                guard let self else { return }
                if isEditing {
                    UIView.animate(withDuration: 0.3) {
                        self.progressView.isHidden = true
                        self.descLabel.isHidden = true
                        self.nextButton.isHidden = true
                        self.skipButton.isHidden = true
                        
                        self.progressView.alpha = 0
                        self.descLabel.alpha = 0
                        self.nextButton.alpha = 0
                        self.skipButton.alpha = 0
                    }
                } else {
                    self.showDescription()
                }
            }
            .store(in: &cancellables)
        
        avatarView.isUserInteractionEnabled = true
        avatarView.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            guard let self = self else { return }
            self.uploader.addPhoto(controller: self)
        }))
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
        addPhotoButton.addAction(.init(handler: { [weak self] _ in
            guard let self = self else { return }
            self.uploader.addPhoto(controller: self)
        }), for: .touchUpInside)
        
        nextButton.isEnabled = false
        nextButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            
            self.onboardingParent?.pushViewController(OnboardingProfileController(data: self.accountData, uploader: self.uploader), animated: true)
        }), for: .touchUpInside)
        
        skipButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            
            self.onboardingParent?.pushViewController(OnboardingProfileController(data: self.oldData, uploader: self.uploader), animated: true)
        }), for: .touchUpInside)
    }
    
    @objc func viewTapped() {
        websiteInput.resignFirstResponder()
        aboutInput.resignFirstResponder()
    }
    
    func showDescription() {
        UIView.animate(withDuration: 0.3, delay: 0.1) {
            self.progressView.isHidden = false
            self.descLabel.isHidden = false
            self.nextButton.isHidden = false
            
            self.progressView.alpha = 1
            self.descLabel.alpha = 1
            self.nextButton.alpha = 1
        } completion: { _ in
            self.progressView.isHidden = false
            self.descLabel.isHidden = false
            self.nextButton.isHidden = false
            self.nextButton.isEnabled = true
            
            self.progressView.alpha = 1
            self.descLabel.alpha = 1
            self.nextButton.alpha = 1
        }
    }
}

extension OnboardingAboutController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        editingViews.insert(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        editingViews.remove(textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}
