//
//  OnboardingProfileController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 25.4.23..
//

import Combine
import UIKit

protocol SignupProfileProtocol {
    var avatar: String { get }
    var banner: String { get }
    var bio: String { get }
    var username: String { get }
    var displayname: String { get }
    var website: String { get }
    var lightningWallet: String { get }
    var nip05: String { get }
}

extension TwitterUserRequest.Response: SignupProfileProtocol {
    var lightningWallet: String { "" }
    var nip05: String { "" }
    var website: String { "" }
}

final class OnboardingProfileController: UIViewController {
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
    
    let _profile: SignupProfileProtocol
    var profile: SignupProfileProtocol { uploader?.accountData ?? _profile }
    
    lazy var progressView = PrimalProgressView(progress: 3, total: 4)
    let twitterView = LargeProfileView()
    let successLabel = UILabel()
    let instructionLabel = UILabel()
    let continueButton = GradientBackgroundUIButton(title: "Create Nostr account").constrainToSize(height: 58)
    let keychainInfo = KeyKeychainInfoView()
    let loadingSpinner = LoadingSpinnerView().constrainToSize(height: 100)
    
    var isUploading: Bool = false {
        didSet {
            if oldValue, !isUploading, case .uploading = state {
                createAccount()
            }
            updateView()
        }
    }
    
    var cancellables: Set<AnyCancellable> = []
    
    weak var uploader: OnboardingCreateAccountController?
    
    init(profile: SignupProfileProtocol, uploader: OnboardingCreateAccountController?) {
        self._profile = profile
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
            title = "Profile Preview"
            continueButton.setTitle("Create Nostr account", for: .normal)
            keychainInfo.alpha = 0
            keychainInfo.isHidden = true
            instructionLabel.alpha = 1
            instructionLabel.isHidden = false
            loadingSpinner.alpha = 0
            loadingSpinner.isHidden = true
            
            
            successLabel.alpha = 0
            twitterView.layer.borderColor = UIColor.white.cgColor
            progressView.progress = 3
            
            continueButton.isEnabled = true
        case .uploading:
            title = "Creating a Nostr account"
            continueButton.setTitle("Uploading...", for: .disabled)
            keychainInfo.alpha = 0
            keychainInfo.isHidden = true
            instructionLabel.alpha = 0
            instructionLabel.isHidden = true
            successLabel.alpha = 0
            
            loadingSpinner.alpha = 1
            loadingSpinner.isHidden = false
            loadingSpinner.play()
            
            twitterView.layer.borderColor = UIColor.white.cgColor
            progressView.progress = 3
            
            continueButton.isEnabled = false
        case .created:
            title = "Nostr account created"
            continueButton.setTitle("Find people to follow", for: .normal)
            keychainInfo.alpha = 1
            keychainInfo.isHidden = false
            instructionLabel.alpha = 0
            instructionLabel.isHidden = true
            loadingSpinner.alpha = 0
            loadingSpinner.isHidden = true
            
            successLabel.alpha = 1
            twitterView.layer.borderColor = UIColor(rgb: 0x66E205).cgColor
            progressView.progress = 4
            
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
                    RelaysPostbox.instance.disconnect()
                    
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
        navigationItem.title = "Twitter profile found"
        view.backgroundColor = .black
        
        let button = UIButton()
        button.setImage(UIImage(named: "back"), for: .normal)
        button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        
        view.addSubview(progressView)
        progressView.pinToSuperview(edges: .top, safeArea: true).centerToSuperview(axis: .horizontal)
        
        let stack = UIStackView(arrangedSubviews: [twitterView, successLabel, instructionLabel, keychainInfo, loadingSpinner, UIView(), continueButton])
        view.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 36).pinToSuperview(edges: .vertical, padding: 30, safeArea: true)
        
        twitterView.setContentHuggingPriority(.required, for: .vertical)
        twitterView.profile = profile
        
        successLabel.text = "Your Nostr account has been created!"
        successLabel.font = .appFont(withSize: 14, weight: .regular)
        successLabel.textColor = UIColor(rgb: 0x66E205)
        successLabel.textAlignment = .center
        
        instructionLabel.text = "We will use this info to create your Nostr account. If you wish to make any changes, you can always do so in your profile settings."
        instructionLabel.numberOfLines = 0
        instructionLabel.textColor = .init(rgb: 0xAAAAAA)
        instructionLabel.textAlignment = .center
        instructionLabel.font = .appFont(withSize: 20, weight: .regular)
        
        stack.axis = .vertical
        stack.spacing = 6
        stack.setCustomSpacing(20, after: successLabel)
        
        continueButton.addTarget(self, action: #selector(continuePressed), for: .touchUpInside)
        
        updateView()
    }
    
    @objc func continuePressed() {
        switch state {
        case .ready:
            continueButton.isEnabled = false
            if isUploading {
                state = .uploading
            } else {
                createAccount()
            }
        case .created:
            let suggestions = OnboardingFollowSuggestionsController()
            show(suggestions, sender: nil)
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
        let keyIcon = UIImageView(image: UIImage(named: "keyKeychain"))
        let titleLabel = UILabel()
        let subtitleLabel = UILabel()
        let hStack = UIStackView(arrangedSubviews: [keyIcon, titleLabel])
        let vStack = UIStackView(arrangedSubviews: [hStack, subtitleLabel])
        
        addSubview(vStack)
        vStack.pinToSuperview(padding: 20)
        vStack.axis = .vertical
        vStack.spacing = 16
        
        hStack.alignment = .center
        hStack.spacing = 12
        
        titleLabel.text = "Your Nostr key is safely stored on your phone. You can access it in app settings."
        titleLabel.textColor = .white
        titleLabel.font = .appFont(withSize: 16, weight: .semibold)
        titleLabel.numberOfLines = 3
        titleLabel.adjustsFontSizeToFitWidth = true
        
        subtitleLabel.text = "You can access your key in the Primal app settings."
        subtitleLabel.textColor = .init(rgb: 0xAAAAAA)
        subtitleLabel.font = .appFont(withSize: 16, weight: .regular)
        subtitleLabel.numberOfLines = 4
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.isHidden = true
        
        backgroundColor = .init(rgb: 0x181818)
        layer.cornerRadius = 12
    }
}
