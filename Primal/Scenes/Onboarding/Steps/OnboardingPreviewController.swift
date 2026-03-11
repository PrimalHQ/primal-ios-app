//
//  OnboardingPreviewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 20.3.24..
//

import Combine
import UIKit
import SafariServices

final class OnboardingPreviewController: OnboardingBaseViewController {
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
    let infoView = KeyKeychainInfoView()
    
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
    
    init(data: AccountCreationData, session: OnboardingSession, backgroundIndex: Int) {
        self.oldData = data
        self.session = session
        super.init(backgroundIndex: backgroundIndex)
        
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
        let pubkey = session.newUserKeypair.hexVariant.pubkey
        let profileData = self.profile

        RelaysPostbox.instance.connect(session.defaultRelays)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let profile = NostrProfile(
                name: profileData.username,
                display_name: profileData.displayname,
                about: profileData.bio,
                picture: profileData.avatar,
                banner: profileData.banner,
                website: profileData.website,
                lud06: nil,
                lud16: profileData.lightningWallet,
                nip05: profileData.nip05
            )

            var userSet = Set(self.session.usersToFollow)
            userSet.insert(pubkey)

            guard
                let metadata_ev = NostrObject.metadata(profile),
                let contacts_ev = NostrObject.contacts(userSet),
                let relays_ev = NostrObject.relays(self.session.defaultRelays.reduce(into: [:], { $0[$1] = .init(read: true, write: true)}) )
            else {
                print("Unable to create profile and contacts, this shouldn't be possible")
                return
            }

            Task { [self] in
                // Run relay publishing and wallet creation in parallel
                async let lnAddress = WalletManager.instance.createSparkWallet(pubkey)
                async let relaysPublished = self.publishToRelays(metadata: metadata_ev, contacts: contacts_ev, relays: relays_ev)

                let (address, published) = await (lnAddress, relaysPublished)

                guard published == true else {
                    await MainActor.run { self.state = .ready }
                    return
                }
                
                await MainActor.run {
                    guard
                        let nsec = self.session.newUserKeypair.nVariant.nsec,
                        LoginManager.instance.login(nsec)
                    else { return }
                    
                    self.state = .created
                    RootViewController.instance.needsReset = true
                }

                // Republish metadata with lightning address if resolved
                if let address, !address.isEmpty {
                    profile.lud16 = address
                    if let updated_ev = NostrObject.metadata(profile) {
                        RelaysPostbox.instance.request(updated_ev, successHandler: { _ in }, errorHandler: {})
                    }
                }
            }
        }
    }

    private func publishToRelays(metadata: NostrObject, contacts: NostrObject, relays: NostrObject) async -> Bool {
        await withCheckedContinuation { continuation in
            RelaysPostbox.instance.request(metadata, successHandler: { _ in
                RelaysPostbox.instance.request(contacts, successHandler: { _ in
                    RelaysPostbox.instance.request(relays, successHandler: { _ in
                        continuation.resume(returning: true)
                    }, errorHandler: {
                        continuation.resume(returning: false)
                    })
                }, errorHandler: {
                    continuation.resume(returning: false)
                })
            }, errorHandler: { [weak self] in
                continuation.resume(returning: false)
            })
        }
    }
    
    func setup() {
        addBackground()
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
        nameLabel.textColor = UIColor(rgb: 0x111111)
        
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
            let nVariants = session.newUserKeypair.nVariant
            if infoView.onlineSwitch.isOn {
                _ = ICloudKeychainManager.instance.onlineSaveNpub(nVariants.npub, nsec: nVariants.nsec)
            } else {
                ICloudKeychainManager.instance.toggleOnlineSyncForNpub(nVariants.npub, on: infoView.onlineSwitch.isOn)
            }

            RootViewController.instance.reset()
        case .uploading:
            return
        }
    }
}

final class KeyKeychainInfoView: UIView {
    let onlineSwitch = UISwitch()
    
    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setup() {
        let keyIcon = UIImageView(image: .onboardingCheckTransparent)
        let titleLabel = UILabel()
        let vStack = UIStackView(axis: .vertical, [keyIcon, titleLabel])

        let topContent = UIView().constrainToSize(height: 119)
        
        topContent.addSubview(vStack)
        vStack.centerToSuperview()
        vStack.alignment = .center
        vStack.spacing = 12

        titleLabel.text = "Account created!"
        titleLabel.textColor = UIColor(rgb: 0x111111).withAlphaComponent(0.8)
        titleLabel.font = .appFont(withSize: 16, weight: .semibold)
        titleLabel.numberOfLines = 0

        backgroundColor = .black.withAlphaComponent(0.25)
        layer.cornerRadius = 16
        clipsToBounds = true
        
        let botContent = UIView()
        botContent.backgroundColor = .black.withAlphaComponent(0.2)
        
        let descLabel = UILabel("Save account in iCloud Keychain", color: UIColor(rgb: 0x111111), font: .appFont(withSize: 16, weight: .regular))
        descLabel.adjustsFontSizeToFitWidth = true
        
        let botStack = UIStackView([descLabel, onlineSwitch])
        botStack.spacing = 10
        
        botContent.addSubview(botStack)
        botStack.centerToSuperview(axis: .vertical).pinToSuperview(edges: .leading, padding: 18).pinToSuperview(edges: .trailing, padding: 14)
        
        let mainStack = UIStackView(axis: .vertical, [topContent, botContent])
        addSubview(mainStack)
        mainStack.pinToSuperview()
        
        constrainToSize(height: 119 + 47)
        
        onlineSwitch.isOn = true
    }
}
