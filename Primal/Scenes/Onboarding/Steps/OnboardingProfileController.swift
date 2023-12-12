//
//  OnboardingProfileController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 25.4.23..
//

import Combine
import UIKit
import SafariServices

final class OnboardingProfileController: UIViewController, OnboardingViewController {
    enum State {
        case ready
        case created
        case uploading
    }
    
    private var state = State.ready {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.updateView()
            }
        }
    }
    
    let oldData: AccountCreationData
    var profile: AccountCreationData {
        var old = oldData
        old.avatar = uploader?.avatarURL ?? old.avatar
        old.banner = uploader?.bannerURL ?? old.banner
        return old
    }
    
    let profileView = LargeProfileView()
    let instructionLabel = UILabel()
    let progressView = PrimalProgressView(progress: 2, total: 4)
    let continueButton = OnboardingMainButton("Create Account Now")
    let keychainInfo = KeyKeychainInfoView()
    let loadingSpinner = LoadingSpinnerView().constrainToSize(height: 70)
    
    let titleLabel: UILabel = .init()
    let backButton = UIButton()
    
    var isUploading: Bool = false {
        didSet {
            if oldValue, !isUploading, case .uploading = state {
                createAccount()
            }
            updateView()
        }
    }
    
    var cancellables: Set<AnyCancellable> = []
    
    var uploader: OnboardingImageUploader?
    
    init(data: AccountCreationData, uploader: OnboardingImageUploader?) {
        self.oldData = data
        self.uploader = uploader
        super.init(nibName: nil, bundle: nil)
        
        setup()
        
        uploader?.$isUploading.sink(receiveValue: { [weak self] in
            self?.isUploading = $0
        })
        .store(in: &cancellables)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension OnboardingProfileController {
    func updateView() {
        switch state {
        case .ready:
            titleLabel.text = "Create Account"
            continueButton.setTitle("Create Account Now", for: .normal)
            keychainInfo.alpha = 0
            keychainInfo.isHidden = true
            instructionLabel.alpha = 1
            instructionLabel.isHidden = false
            loadingSpinner.alpha = 0
            loadingSpinner.isHidden = true
            
            progressView.currentPage = 2
            
            continueButton.isEnabled = true
        case .uploading:
            profileView.changeBannerButton.isHidden = true
            backButton.isHidden = true
            titleLabel.text = "Creating an Account"
            continueButton.setTitle("Uploading...", for: .disabled)
            keychainInfo.alpha = 0
            keychainInfo.isHidden = true
            instructionLabel.alpha = 0
            instructionLabel.isHidden = true
            
            loadingSpinner.alpha = 1
            loadingSpinner.isHidden = false
            loadingSpinner.play()
            
            progressView.currentPage = 2
            
            continueButton.isEnabled = false
        case .created:
            profileView.changeBannerButton.isHidden = true
            backButton.isHidden = true
            titleLabel.text = "Success!"
            continueButton.setTitle("Find people to follow", for: .normal)
            keychainInfo.alpha = 1
            keychainInfo.isHidden = false
            instructionLabel.alpha = 0
            instructionLabel.isHidden = true
            loadingSpinner.alpha = 0
            loadingSpinner.isHidden = true
            
            progressView.currentPage = 3
            
            continueButton.isEnabled = true
        }
    }
    
    func createAccount() {        
        RelaysPostbox.instance.connect(bootstrap_relays)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let profile = Profile(
                name: self.profile.username,
                display_name: self.profile.displayname,
                about: self.profile.bio,
                picture: self.profile.avatar,
                banner: self.profile.banner,
                website: self.profile.website,
                lud06: nil,
                lud16: self.profile.lightningWallet,
                nip05: self.profile.nip05
            )
            
            // yucky
            IdentityManager.instance.isNewUser = true

            guard let metadata_ev = NostrObject.metadata(profile) else {
                fatalError("Unable to create metadata, this shouldn't be possible")
            }
            guard let contacts_ev = NostrObject.firstContact() else {
                fatalError("Unable to create contacts, this shouldn't be possible")
            }
            
            RelaysPostbox.instance.request(metadata_ev, specificRelay: nil, successHandler: { _ in
                RelaysPostbox.instance.request(contacts_ev, specificRelay: nil, successHandler: { _ in
                    guard
                        let keypair = IdentityManager.instance.newUserKeypair,
                        let nsec = keypair.nVariant.nsec,
                        LoginManager.instance.login(nsec)
                    else {
                        fatalError("Unable to save keypair to the keychain, this shouldn't be possible")
                    }
                    
                    self.state = .created
                }, errorHandler: {
                    self.state = .ready
                })
            }, errorHandler: {
                self.state = .ready
            })
        }
    }
    
    func setup() {
        addBackground(3)
        addNavigationBar("Create Account")
                
        let botStack = UIStackView(axis: .vertical, [progressView, continueButton])
        botStack.spacing = 12
        
        let stack = UIStackView(arrangedSubviews: [UIView(), profileView, instructionLabel, keychainInfo, loadingSpinner, botStack])
        view.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 36).pin(to: titleLabel, edges: .top, padding: 30).pinToSuperview(edges: .bottom, padding: 12, safeArea: true)
        
        profileView.setContentHuggingPriority(.required, for: .vertical)
        profileView.profile = profile
        profileView.didTapUrl = { [weak self] url in
            self?.present(SFSafariViewController(url: url), animated: true)
        }
        
        uploader?.$image.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] image in
            self?.profileView.profileImageView.image = image ?? self?.profileView.profileImageView.image
        })
        .store(in: &cancellables)
        
        uploader?.$bannerImage.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] image in
            self?.profileView.coverImageView.image = image ?? self?.profileView.coverImageView.image
        })
        .store(in: &cancellables)
        
        instructionLabel.numberOfLines = 0
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 8
        paragraph.alignment = .center
        instructionLabel.attributedText = .init(string: "We will use this info to create your Nostr account. If you wish to make any changes, you can always do so in your profile settings.", attributes: [
            .foregroundColor:   UIColor.white,
            .font:              UIFont.appFont(withSize: 16, weight: .semibold),
            .paragraphStyle:    paragraph
        ])
        
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        
        continueButton.addTarget(self, action: #selector(continuePressed), for: .touchUpInside)
        
        profileView.changeBannerButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            self.uploader?.addBanner(controller: self)
        }), for: .touchUpInside)
        
        updateView()
    }
    
    @objc func continuePressed() {
        switch state {
        case .ready:
            onboardingParent?.reset(self, animated: false)
            continueButton.isEnabled = false
            if isUploading {
                state = .uploading
            } else {
                createAccount()
            }
        case .created:
            onboardingParent?.reset(OnboardingFollowSuggestionsController(), animated: true)
        case .uploading:
            return
        }
    }
}

final class KeyKeychainInfoView: UIView {
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        let keyIcon = UIImageView(image: UIImage(named: "onboardingCheck"))
        let titleLabel = UILabel()
        let hStack = UIStackView(arrangedSubviews: [keyIcon, titleLabel])
        
        addSubview(hStack)
        hStack.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .vertical, padding: 16)
        
        hStack.alignment = .center
        hStack.spacing = 20
        
        titleLabel.text = "Account created!\nYour Nostr key is available in your Account Settings."
        titleLabel.textColor = .white.withAlphaComponent(0.8)
        titleLabel.font = .appFont(withSize: 16, weight: .semibold)
        titleLabel.numberOfLines = 0
        
        backgroundColor = .black.withAlphaComponent(0.25)
        layer.cornerRadius = 16
    }
}
