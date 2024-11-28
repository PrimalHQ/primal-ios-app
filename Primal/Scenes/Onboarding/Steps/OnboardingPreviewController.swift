//
//  OnboardingPreviewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 20.3.24..
//

import Combine
import UIKit
import SafariServices

final class OnboardingPreviewController: UIViewController, OnboardingViewController {
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
        old.avatar = session.avatarURL
        old.banner = session.bannerURL
        return old
    }
    
    let profileView = LargeProfileView()
    let instructionLabel = UILabel()
    let progressView = PrimalProgressView(progress: 2, total: 4, markProgress: true)
    let continueButton = OnboardingMainButton("Create Account Now")
    let secondScreen = UIStackView(axis: .vertical, [])
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
    
    var session: OnboardingSession
    
    init(data: AccountCreationData, session: OnboardingSession) {
        self.oldData = data
        self.session = session
        super.init(nibName: nil, bundle: nil)
        
        setup()
        
        session.$isUploading.sink(receiveValue: { [weak self] in
            self?.isUploading = $0
        })
        .store(in: &cancellables)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension OnboardingPreviewController {
    func updateView() {
        switch state {
        case .ready:
            titleLabel.text = "Account Preview"
            continueButton.setTitle("Create Account Now", for: .normal)
            secondScreen.alpha = 0
            secondScreen.isHidden = true
            instructionLabel.alpha = 1
            instructionLabel.isHidden = false
            
            loadingSpinner.alpha = 0
            loadingSpinner.isHidden = true
            
            instructionLabel.attributedText = descAttributedString("We will use this info to create your Nostr account. If you wish to make any changes, you can always do so in your profile settings.")
            
            progressView.currentPage = 2
            
            continueButton.isEnabled = true
        case .uploading:
            profileView.changeBannerButton.isHidden = true
            backButton.isHidden = true
            titleLabel.text = "Creating an Account"
            continueButton.setTitle("Uploading...", for: .disabled)
            secondScreen.alpha = 0
            secondScreen.isHidden = true
            instructionLabel.alpha = 0
            instructionLabel.isHidden = true
            
            loadingSpinner.alpha = 1
            loadingSpinner.isHidden = false
            loadingSpinner.play()
            
            progressView.currentPage = 2
            
            continueButton.isEnabled = false
        case .created:
            profileView.isHidden = true
            profileView.alpha = 0
            
            backButton.isHidden = true
            titleLabel.text = "Success!"
            continueButton.setTitle("Continue", for: .normal)
            secondScreen.alpha = 1
            secondScreen.isHidden = false
            loadingSpinner.alpha = 0
            loadingSpinner.isHidden = true
            
            progressView.isHidden = true
            progressView.alpha = 0
            
            instructionLabel.alpha = 1
            instructionLabel.isHidden = false
            
            instructionLabel.attributedText = descAttributedString("Your Nostr key is available in your\nAccount Settings.")
            
            continueButton.isEnabled = true
        }
    }
    
    func createAccount() {
        RelaysPostbox.instance.connect(session.defaultRelays)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let profile = NostrProfile(
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
            
            var userSet = Set(self.session.usersToFollow)
            userSet.insert(self.session.newUserKeypair.hexVariant.pubkey)

            guard
                let metadata_ev = NostrObject.metadata(profile),
                let contacts_ev = NostrObject.contacts(userSet),
                let relays_ev = NostrObject.relays(self.session.defaultRelays.reduce(into: [:], { $0[$1] = .init(read: true, write: true)}) )
            else {
                print("Unable to create profile and contacts, this shouldn't be possible")
                return
            }
            
            RelaysPostbox.instance.request(metadata_ev, successHandler: { [weak self] _ in
                RelaysPostbox.instance.request(contacts_ev, successHandler: { _ in
                    RelaysPostbox.instance.request(relays_ev, successHandler: { _ in
                        guard
                            let nsec = self?.session.newUserKeypair.nVariant.nsec,
                            LoginManager.instance.login(nsec)
                        else {
                            print("Unable to save keypair to the keychain, this shouldn't be possible")
                            return
                        }
                        
                        RootViewController.instance.needsReset = true
                        self?.state = .created
                    }, errorHandler: {
                        self?.state = .ready
                    })
                }, errorHandler: {
                    self?.state = .ready
                })
            }, errorHandler: { [weak self] in
                self?.state = .ready
            })
        }
    }
    
    func setup() {
        addBackground(4)
        addNavigationBar("Create Account")
        
        let botStack = UIStackView(axis: .vertical, [continueButton, progressView])
        botStack.spacing = 18
        
        let avatarView = UIImageView().constrainToSize(108)
        avatarView.layer.cornerRadius = 54
        avatarView.layer.borderWidth = 3
        avatarView.layer.borderColor = UIColor.white.cgColor
        avatarView.contentMode = .scaleAspectFill
        avatarView.clipsToBounds = true
        avatarView.image = session.image ?? UIImage(named: "onboardingDefaultAvatar")?.withAlpha(alpha: 0.5)
        
        let nameLabel = UILabel()
        nameLabel.font = .appFont(withSize: 24, weight: .bold)
        nameLabel.text = profile.displayname
        nameLabel.textColor = .white
        
        let infoView = KeyKeychainInfoView()
        [avatarView, SpacerView(height: 12), nameLabel, SpacerView(height: 36), infoView].forEach { secondScreen.addArrangedSubview($0) }
        secondScreen.alignment = .center
        infoView.pinToSuperview(edges: .horizontal)
        
        let instructionStack = UIStackView(axis: .vertical, [secondScreen, instructionLabel])
        instructionStack.spacing = 20
        
        let stack = UIStackView(arrangedSubviews: [UIView(), profileView, instructionStack, loadingSpinner, botStack])
        view.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 36).pin(to: titleLabel, edges: .top, padding: 30).pinToSuperview(edges: .bottom, padding: 12, safeArea: true)
        
        profileView.setContentHuggingPriority(.required, for: .vertical)
        profileView.profile = profile
        profileView.didTapUrl = { [weak self] url in
            self?.present(SFSafariViewController(url: url), animated: true)
        }
        
        session.$image.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] image in
            self?.profileView.profileImageView.image = image ?? self?.profileView.profileImageView.image
        })
        .store(in: &cancellables)
        
        session.$bannerImage.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] image in
            self?.profileView.coverImageView.image = image ?? self?.profileView.coverImageView.image
        })
        .store(in: &cancellables)
        
        instructionLabel.numberOfLines = 0
        
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        
        continueButton.addTarget(self, action: #selector(continuePressed), for: .touchUpInside)
        
        profileView.changeBannerButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            self.session.addBanner(controller: self)
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
            onboardingParent?.reset(OnboardingReviewController(session: session), animated: true)
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
        let keyIcon = UIImageView(image: UIImage(named: "onboardingCheckTransparent"))
        let titleLabel = UILabel()
        let vStack = UIStackView(axis: .vertical, [keyIcon, titleLabel])

        addSubview(vStack)
        vStack.centerToSuperview()
        vStack.alignment = .center
        vStack.spacing = 12

        titleLabel.text = "Account created!"
        titleLabel.textColor = .white.withAlphaComponent(0.8)
        titleLabel.font = .appFont(withSize: 16, weight: .semibold)
        titleLabel.numberOfLines = 0

        backgroundColor = .black.withAlphaComponent(0.25)
        layer.cornerRadius = 16
        
        constrainToSize(height: 116)
    }
}
