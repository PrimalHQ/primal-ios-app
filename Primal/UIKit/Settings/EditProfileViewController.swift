//
//  EditProfileViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 26.7.23..
//

import Combine
import UIKit

final class EditProfileViewController: UIViewController, Themeable {
    let bannerImageView = UIImageView()
    let avatarView = UIImageView(image: UIImage(named: "Profile"))
    let addPhotoButton = GradientUIButton(title: "change photo")
    let addBannerButton = GradientUIButton(title: "change banner")
    let displayNameInput = UITextField()
    let usernameInput = UITextField()
    let websiteInput = UITextField()
    let bioInput = UITextView()
    let bitcoinInput = UITextField()
    let nip05Input = UITextField()
    let scrollView = UIScrollView()
    let nextButton = GradientBackgroundUIButton(title: "Save Profile").constrainToSize(height: 58)
    
    var avatarURL = "" { didSet { updateIsUploading() } }
    var bannerURL = "" { didSet { updateIsUploading() } }
    
    var isUploadingAvatar = false { didSet { updateIsUploading() } }
    var didUploadBanner = false { didSet { updateIsUploading() } }
    
    @Published var isUploading = false
    
    var cancellables: Set<AnyCancellable> = []
    
    var textFields: [UITextField] { [displayNameInput, usernameInput, websiteInput, bitcoinInput, nip05Input] }
    
    var accountData: Profile {
        let name: String = usernameInput.text ?? profile.name
        let displayName: String = displayNameInput.text ?? profile.displayName
        let about: String = bioInput.text ?? profile.about
        let avatar: String = avatarURL.isEmpty ? profile.picture : avatarURL
        let banner: String = bannerURL.isEmpty ? profile.banner : bannerURL
        let website: String = websiteInput.text ?? profile.website
        let lud16: String = bitcoinInput.text ?? profile.lud16
        let nip05: String = nip05Input.text ?? profile.nip05
        
        return Profile(
            name: name,
            display_name: displayName,
            about: about,
            picture: avatar,
            banner: banner,
            website: website,
            lud06: profile.lud06,
            lud16: lud16,
            nip05: nip05
        )
    }
    
    let profile: PrimalUser
    
    init(profile: PrimalUser) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
        
        avatarView.kf.setImage(with: URL(string: profile.picture), placeholder: UIImage(named: "Profile"))
        bannerImageView.kf.setImage(with: URL(string: profile.banner))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        updateTheme()
        
        bioInput.text = profile.about
        usernameInput.text = profile.name
        displayNameInput.text = profile.displayName
        bitcoinInput.text = profile.lud16
        nip05Input.text = profile.nip05
        websiteInput.text = profile.website
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        mainTabBarController?.setTabBarHidden(true, animated: animated)
    }
    
    func updateTheme() {
        view.backgroundColor = .background
        navigationItem.leftBarButtonItem = customBackButton
        
        avatarView.layer.borderColor = UIColor.background.cgColor
        avatarView.backgroundColor = .background
        
        bioInput.backgroundColor = .init(rgb: 0x181818)
        
        let inputParents: [InputParent] = view.findAllSubviews()
        inputParents.forEach { $0.backgroundColor = .background3 }
        
        for view in [displayNameInput, usernameInput, websiteInput, bioInput, bitcoinInput, nip05Input] as [TextRepresenting] {
            view.contentFont = .appFont(withSize: 18, weight: .medium)
            view.contentColor = .foreground
            view.backgroundColor = .background3
            view.superview?.backgroundColor = .background3
        }
    }
}

private extension EditProfileViewController {
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
        title = "Edit Profile"
        
        let spacerParent = UIView()
        let avatarStack = UIStackView(arrangedSubviews: [SpacerView(width: 6), avatarView, UIView(), addPhotoButton, spacerParent, addBannerButton, SpacerView(width: 36)])
        avatarStack.spacing = 10
        avatarStack.alignment = .bottom
        
        let spacer = SpacerView(width: 1, height: 20, color: .init(rgb: 0x444444))
        spacerParent.addSubview(spacer)
        spacer.pinToSuperview(edges: .horizontal).centerToView(addPhotoButton, axis: .vertical)
        
        let formParent = UIView()
        let atLabel = UILabel()
        atLabel.textColor = .init(rgb: 0x666666)
        atLabel.text = "@"
        atLabel.font = .appFont(withSize: 18, weight: .medium)
        let formStack = UIStackView(axis: .vertical, [
            FormHeaderView(title: "USERNAME", required: true),
            InputParent(input: UIStackView([atLabel, usernameInput])).constrainToSize(height: 48), SpacerView(height: 12),
            FormHeaderView(title: "DISPLAY NAME", required: false),
            InputParent(input: displayNameInput).constrainToSize(height: 48), SpacerView(height: 12),
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
        let mainStack = UIStackView(axis: .vertical, [scrollView, keyboardSpacer, nextParent])
        view.addSubview(mainStack)
        mainStack.pinToSuperview(safeArea: true)
        keyboardSpacer.topAnchor.constraint(lessThanOrEqualTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        
        scrollView.keyboardDismissMode = .onDrag
        
        bannerImageView.constrainToSize(height: 124)
        bannerImageView.backgroundColor = .init(rgb: 0x181818)
        bannerImageView.layer.masksToBounds = true
        bannerImageView.contentMode = .scaleAspectFill
        
        avatarView.constrainToSize(108)
        avatarView.layer.cornerRadius = 54
        avatarView.layer.masksToBounds = true
        avatarView.layer.borderWidth = 4
        avatarView.contentMode = .scaleAspectFill
        
        formStack.spacing = 2
        
        bioInput.constrainToSize(height: 120)
        bioInput.delegate = self
        
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
            
//            guard let name = self.displayNameInput.text, !name.isEmpty else {
//                self.displayNameInput.becomeFirstResponder()
//                return
//            }
            
            guard let username = self.usernameInput.text, !username.isEmpty else {
                self.usernameInput.becomeFirstResponder()
                return
            }
            
            self.updateAccount()
        }), for: .touchUpInside)
        
        $isUploading.sink { [unowned self] isUploading in
            self.nextButton.setTitle(isUploading ? "Uploading..." : "Save Profile", for: .normal)
        }
        .store(in: &cancellables)
    }
    
    @objc func viewTapped() {
        textFields.forEach { $0.resignFirstResponder() }
        bioInput.resignFirstResponder()
    }
    
    func updateAccount() {
        nextButton.isEnabled = false
        nextButton.setTitle("Updating", for: .normal)
        
        if isUploading {
            $isUploading.filter { !$0 }.first().receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] _ in
                self?.updateAccount()
            })
            .store(in: &cancellables)
            return
        }
        
        let profile = self.profile
        let data: Profile = accountData
        
        guard let metadata_ev = NostrObject.metadata(data) else {
            self.showErrorMessage("Unable to create a new nostr metadata object")
            return
        }
        
        RelaysPostbox.instance.connect(bootstrap_relays)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            RelaysPostbox.instance.request(metadata_ev, specificRelay: nil, successHandler: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
                if let profileVC = self?.navigationController?.viewControllers.first(where: { ($0 as? ProfileViewController)?.profile.data.pubkey == self?.profile.pubkey }) as? ProfileViewController {
                    
                    let newProfile = PrimalUser(
                        id: profile.id,
                        pubkey: profile.pubkey,
                        npub: profile.npub,
                        name: data.name ?? profile.name,
                        about: data.about ?? profile.about,
                        picture: data.picture ?? profile.picture,
                        nip05: data.nip05 ?? profile.nip05,
                        banner: data.banner ?? profile.banner,
                        displayName: data.display_name ?? profile.displayName,
                        location: profile.location,
                        lud06: data.lud06 ?? profile.lud06,
                        lud16: data.lud16 ?? profile.lud16,
                        website: data.website ?? profile.website,
                        tags: metadata_ev.tags,
                        created_at: Double(metadata_ev.created_at),
                        sig: metadata_ev.sig,
                        deleted: profile.deleted ?? false
                    )
                    
                    profileVC.profile = .init(data: newProfile)
                }
            }, errorHandler: { [weak self] in
                self?.nextButton.isEnabled = true
                self?.nextButton.setTitle("Save Profile", for: .normal)
            })
        }
    }
}

extension EditProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == usernameInput else { return true }
        
        let blockedChars = NSCharacterSet.alphanumerics.inverted
        return string.rangeOfCharacter(from: blockedChars) == nil
    }
}

extension EditProfileViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.scrollView.scrollRectToVisible(textView.convert(textView.bounds, to: self.scrollView), animated: true)
        }
    }
}
