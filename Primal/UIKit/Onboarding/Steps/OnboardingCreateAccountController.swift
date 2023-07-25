//
//  OnboardingCreateAccountController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 25.4.23..
//

import Combine
import UIKit

struct AccountCreationData: SignupProfileProtocol {    
    var avatar: String = ""
    var banner: String = ""
    var bio: String = ""
    var username: String = ""
    var displayname: String = ""
    var lightningWallet: String = ""
    var nip05: String = ""
    var website: String = ""
}

final class OnboardingCreateAccountController: UIViewController {
    let bannerImageView = UIImageView()
    let avatarView = UIImageView(image: UIImage(named: "Profile"))
    let addPhotoButton = GradientUIButton(title: "add photo")
    let addBannerButton = GradientUIButton(title: "add banner")
    let displayNameInput = UITextField()
    let usernameInput = UITextField()
    let websiteInput = UITextField()
    let bioInput = UITextView()
    let bitcoinInput = UITextField()
    let nip05Input = UITextField()
    let scrollView = UIScrollView()
    let nextButton = GradientBackgroundUIButton(title: "Next").constrainToSize(height: 58)
    
    var avatarURL = "" { didSet { updateIsUploading() } }
    var bannerURL = "" { didSet { updateIsUploading() } }
    
    var isUploadingAvatar = false { didSet { updateIsUploading() } }
    var didUploadBanner = false { didSet { updateIsUploading() } }
    
    @Published var isUploading = false
    
    var cancellables: Set<AnyCancellable> = []
    
    var textFields: [UITextField] { [displayNameInput, usernameInput, websiteInput, bitcoinInput, nip05Input] }
    
    var accountData: AccountCreationData {
        AccountCreationData(
            avatar: avatarURL,
            banner: bannerURL,
            bio: bioInput.text ?? "",
            username: usernameInput.text ?? "",
            displayname: displayNameInput.text ?? "",
            lightningWallet: bitcoinInput.text ?? "",
            nip05: nip05Input.text ?? "",
            website: websiteInput.text ?? ""
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let keypair = NostrKeypair.generate() else {
            fatalError("Unable to generate a new keypair, this shouldn't be possible")
        }
        
        IdentityManager.instance.newUserKeypair = keypair
        
        setup()
    }
}

private extension OnboardingCreateAccountController {
    func updateIsUploading() {
        if  (isUploadingAvatar && avatarURL.isEmpty) ||
            (didUploadBanner && bannerURL.isEmpty)
        {
            isUploading = true
            return
        }
    
        isUploading = false
    }
    
    func setup() {
        title = "New Account"
        view.backgroundColor = .black
        navigationItem.leftBarButtonItem = customBackButton
        
        lazy var progressView = PrimalProgressView(progress: 1, total: 3)
        let progressParent = UIView()
        progressParent.addSubview(progressView)
        progressView.pinToSuperview(edges: .top, padding: 5).pinToSuperview(edges: .bottom, padding: 22).centerToSuperview(axis: .horizontal)
        
        let spacerParent = UIView()
        let avatarStack = UIStackView(arrangedSubviews: [SpacerView(width: 6), avatarView, UIView(), addPhotoButton, spacerParent, addBannerButton, SpacerView(width: 36)])
        avatarStack.spacing = 10
        avatarStack.alignment = .bottom
        
        let spacer = SpacerView(width: 1, height: 20, color: .init(rgb: 0x444444))
        spacerParent.addSubview(spacer)
        spacer.pinToSuperview(edges: .horizontal).centerToView(addPhotoButton, axis: .vertical)
        
        let formParent = UIView()
        let atLabel = UILabel()
        atLabel.text = "@"
        let formStack = UIStackView(axis: .vertical, [
            FormHeaderView(title: "DISPLAY NAME", required: true),
            InputParent(input: displayNameInput).constrainToSize(height: 48), SpacerView(height: 12),
            FormHeaderView(title: "HANDLE", required: true),
            InputParent(input: UIStackView([atLabel, usernameInput])).constrainToSize(height: 48), SpacerView(height: 12),
            FormHeaderView(title: "WEBSITE", required: false),
            InputParent(input: websiteInput).constrainToSize(height: 48), SpacerView(height: 12),
            FormHeaderView(title: "SHORT BIO", required: false),
            InputParent(input: bioInput).constrainToSize(height: 130), SpacerView(height: 12),
            FormHeaderView(title: "BITCOIN LIGHTNING ADDRESS", required: false),
            InputParent(input: bitcoinInput).constrainToSize(height: 48), SpacerView(height: 12),
            FormHeaderView(title: "NOSTR VERIFICATION (NIP-05)", required: false),
            InputParent(input: nip05Input).constrainToSize(height: 48), SpacerView(height: 12),
        ])
        formParent.addSubview(formStack)
        formStack.pinToSuperview(edges: .horizontal, padding: 35).pinToSuperview(edges: .vertical)
        let contentStack = UIStackView(axis: .vertical, [bannerImageView, avatarStack, formParent])
        contentStack.setCustomSpacing(45, after: avatarStack)
        contentStack.setCustomSpacing(-70, after: bannerImageView)
        avatarView.transform = .init(translationX: 0, y: 15)
        
        scrollView.addSubview(contentStack)
        contentStack.pinToSuperview()
        contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        let nextParent = UIView()
        nextParent.addSubview(nextButton)
        nextButton.pinToSuperview(edges: .horizontal, padding: 35).pinToSuperview(edges: .top, padding: 20).pinToSuperview(edges: .bottom, padding: 30, safeArea: true)
        
        let keyboardSpacer = SpacerView(height: 0, priority: .defaultLow)
        let mainStack = UIStackView(axis: .vertical, [progressParent, scrollView, keyboardSpacer, nextParent])
        view.addSubview(mainStack)
        mainStack.pinToSuperview(safeArea: true)
        keyboardSpacer.topAnchor.constraint(lessThanOrEqualTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        
        scrollView.keyboardDismissMode = .onDrag
        
        bannerImageView.constrainToSize(height: 124)
        bannerImageView.backgroundColor = .init(rgb: 0x181818)
        bannerImageView.layer.masksToBounds = true
        
        avatarView.constrainToSize(108)
        avatarView.backgroundColor = .black
        avatarView.layer.cornerRadius = 54
        avatarView.layer.masksToBounds = true
        avatarView.layer.borderWidth = 4
        avatarView.layer.borderColor = UIColor.black.cgColor
        
        formStack.spacing = 2
        
        bioInput.constrainToSize(height: 120)
        bioInput.backgroundColor = .init(rgb: 0x181818)
        bioInput.delegate = self
        
        for view in [atLabel, displayNameInput, usernameInput, websiteInput, bioInput] as [TextRepresenting] {
            view.contentFont = .appFont(withSize: 18, weight: .medium)
            view.contentColor = .init(rgb: 0xAAAAAA)
        }
        atLabel.contentColor = .init(rgb: 0x666666)
        
        textFields.forEach {
            $0.delegate = self
            $0.returnKeyType = .done
        }
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
        addPhotoButton.addAction(.init(handler: { [weak self] _ in
            guard let self = self else { return }
            ImagePickerManager(self) { [weak self] image, isPNG in
                guard let self = self else { return }
                self.avatarView.image = image
                self.avatarView.contentMode = .scaleAspectFill
                self.isUploadingAvatar = true
                
                UploadPhotoRequest(image: image, isPNG: isPNG).publisher().receive(on: DispatchQueue.main).sink(receiveCompletion: { [weak self] in
                    switch $0 {
                    case .failure(let error):
                        self?.avatarView.image = UIImage(named: "Profile")
                        print(error)
                    case .finished:
                        break
                    }
                }) { [weak self] urlString in
                    self?.avatarURL = urlString
                }
                .store(in: &self.cancellables)
            }
        }), for: .touchUpInside)
        
        displayNameInput.keyboardType = .namePhonePad
        usernameInput.keyboardType = .namePhonePad
        websiteInput.keyboardType = .webSearch
        bitcoinInput.keyboardType = .webSearch
        nip05Input.keyboardType = .webSearch
        
        addBannerButton.addAction(.init(handler: { [weak self] _ in
            guard let self = self else { return }
            ImagePickerManager(self) { [weak self] image, isPNG in
                guard let self = self else { return }
                self.bannerImageView.image = image
                self.bannerImageView.contentMode = .scaleAspectFill
                self.didUploadBanner = true
                
                UploadPhotoRequest(image: image, isPNG: isPNG).publisher().receive(on: DispatchQueue.main).sink(receiveCompletion: { [weak self] in
                    switch $0 {
                    case .failure(let error):
                        self?.bannerImageView.image = nil
                        print(error)
                    case .finished:
                        break
                    }
                }) { [weak self] urlString in
                    self?.bannerURL = urlString
                }
                .store(in: &cancellables)
            }
        }), for: .touchUpInside)
        
        nextButton.addAction(.init(handler: { [weak self] _ in
            guard let self = self else { return }
            
            guard let name = self.displayNameInput.text, !name.isEmpty else {
                self.displayNameInput.becomeFirstResponder()
                return
            }
            
            guard let username = self.usernameInput.text, !username.isEmpty else {
                self.usernameInput.becomeFirstResponder()
                return
            }
            
            let data = self.accountData
            
            let profileVC = OnboardingProfileController(profile: data, uploader: self)
            profileVC.twitterView.profileImageView.image = avatarView.image
            profileVC.twitterView.coverImageView.image = bannerImageView.image
            self.show(profileVC, sender: nil)
        }), for: .touchUpInside)
    }
    
    @objc func viewTapped() {
        textFields.forEach { $0.resignFirstResponder() }
        bioInput.resignFirstResponder()
    }
}

extension OnboardingCreateAccountController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

extension OnboardingCreateAccountController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.scrollView.scrollRectToVisible(textView.convert(textView.bounds, to: self.scrollView), animated: true)
        }
    }
}

private final class InputParent: UIView {
    init(input: UIView) {
        super.init(frame: .zero)
        
        addSubview(input)
        input.pinToSuperview(edges: .horizontal, padding: 15).centerToSuperview(axis: .vertical)
        
        backgroundColor = .init(rgb: 0x181818)
        layer.cornerRadius = 12
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
    }
    
    @objc func tapped() {
        guard let textInput: UITextField = findAllSubviews().first else { return }
        textInput.becomeFirstResponder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
