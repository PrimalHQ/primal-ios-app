//
//  OnboardingDisplayNameController.swift
//  Primal
//
//  Created by Pavle Stevanović on 20.3.24..
//

import Combine
import UIKit
import Kingfisher

final class OnboardingDisplayNameController: UIViewController, OnboardingViewController {
    let titleLabel = UILabel()
    let backButton: UIButton = .init()
    
    let avatarView = UIImageView(image: UIImage(named: "onboardingDefaultAvatar"))
    let addPhotoButton = SolidColorUIButton(title: "add photo", color: .white)
    
    let aboutInput = UITextField()
    let displayNameInput = UITextField()
    
    let nextButton = OnboardingMainButton("Next")
    
    let progressView = PrimalProgressView(progress: 0, total: 4, markProgress: true)
    let descLabel = UILabel()
    
    let session = OnboardingSession()
    
    var cancellables: Set<AnyCancellable> = []
    
    var textFields: [UITextField] { [displayNameInput, aboutInput] }
    
    @Published var editingViews: Set<UIView> = []
    
    var accountData: AccountCreationData {
        AccountCreationData(
            avatar: session.avatarURL,
            banner: session.bannerURL,
            bio: aboutInput.text ?? "",
            username: "",
            displayname: displayNameInput.text ?? "",
            lightningWallet: "",
            nip05: "",
            website: ""
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

private extension OnboardingDisplayNameController {
    func setup() {
        addBackground(1)
        addNavigationBar("Create Account")
        
        let avatarStack = UIStackView(axis: .vertical, [avatarView, SpacerView(height: 8), addPhotoButton])
        avatarStack.alignment = .center
        addPhotoButton.setContentCompressionResistancePriority(.required, for: .vertical)
        
        descLabel.numberOfLines = 0
        descLabel.setContentCompressionResistancePriority(.init(1), for: .vertical)
        descLabel.attributedText = descAttributedString("Create a public profile on Nostr. Choose any Display Name and say something about yourself. You can easily change these things later.")
        
        let descParent = UIView()
        descParent.addSubview(descLabel)
        descLabel.pinToSuperview(edges: .vertical).pinToSuperview(edges: .horizontal, padding: 10)
        
        let atLabel = UILabel()
        atLabel.text = "@"
        atLabel.font = .appFont(withSize: 18, weight: .medium)
        atLabel.setContentHuggingPriority(.required, for: .horizontal)
        let formStack = UIStackView(axis: .vertical, [
            OnboardingInputParent(input: displayNameInput).constrainToSize(height: 48), SpacerView(height: 12),
            OnboardingInputParent(input: aboutInput).constrainToSize(height: 48), SpacerView(height: 12),
            descParent
        ])
        formStack.spacing = 3
        
        let keyboardSpacer = UIView()
        let bottomStack = UIStackView(axis: .vertical, [nextButton, SpacerView(height: 18), progressView, keyboardSpacer])
        let mainStack = UIStackView(axis: .vertical, [UIView(), avatarStack, formStack, bottomStack])
        view.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 35).pinToSuperview(edges: .bottom, padding: 12, safeArea: true)
        let topC = mainStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12)
        topC.priority = .init(999)
        topC.isActive = true
        
        keyboardSpacer.topAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -12).isActive = true
        
        mainStack.distribution = .equalSpacing
        
        avatarView.constrainToSize(108)
        avatarView.alpha = 0.5
        avatarView.contentMode = .scaleAspectFill
        avatarView.layer.cornerRadius = 54
        avatarView.layer.masksToBounds = true
        avatarView.layer.borderWidth = 3
        avatarView.layer.borderColor = UIColor.white.cgColor
        
        for view in textFields {
            view.font = .appFont(withSize: 16, weight: .semibold)
            view.textColor = .black
        }
        atLabel.font = .appFont(withSize: 18, weight: .semibold)
        atLabel.contentColor = .init(rgb: 0x666666)
        
        aboutInput.attributedPlaceholder = NSAttributedString(string: "About You", attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .semibold),
            .foregroundColor: UIColor.black.withAlphaComponent(0.5),
        ])
        displayNameInput.attributedPlaceholder = NSAttributedString(string: "Display Name", attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .semibold),
            .foregroundColor: UIColor.black.withAlphaComponent(0.5),
        ])
        
        textFields.forEach {
            $0.delegate = self
            $0.returnKeyType = .done
        }
        
        session.$image.receive(on: DispatchQueue.main).sink { [weak self] image in
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
        
        $editingViews.map { !$0.isEmpty }
            .removeDuplicates()
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEditing in
                guard let self else { return }
                if isEditing {
                    UIView.animate(withDuration: 0.3) {
                        self.progressView.isHidden = true
                        self.descLabel.isHidden = true
                        
                        self.progressView.alpha = 0
                        self.descLabel.alpha = 0
                    }
                } else {
                    self.showDescription()
                }
            }
            .store(in: &cancellables)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
        addPhotoButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            self.session.addPhoto(controller: self)
        }), for: .touchUpInside)
        
        avatarView.isUserInteractionEnabled = true
        avatarView.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            guard let self else { return }
            self.session.addPhoto(controller: self)
        }))
        
        nextButton.isEnabled = false
        nextButton.addAction(.init(handler: { [weak self] _ in
            guard let self = self, !self.accountData.displayname.isEmpty else { return }
            
            self.onboardingParent?.pushViewController(OnboardingInterestsController(data: self.accountData, session: self.session), animated: true)
        }), for: .touchUpInside)
        
        displayNameInput.addAction(.init(handler: { [weak self] _ in
            self?.nextButton.isEnabled = self?.displayNameInput.text?.isEmpty == false
        }), for: .editingChanged)
    }
    
    @objc func viewTapped() {
        textFields.forEach { $0.resignFirstResponder() }
    }
    
    func showDescription() {
        UIView.animate(withDuration: 0.3, delay: 0.1) {
            self.progressView.isHidden = false
            self.descLabel.isHidden = false
            
            self.progressView.alpha = 1
            self.descLabel.alpha = 1
        } completion: { _ in
            self.progressView.isHidden = false
            self.descLabel.isHidden = false
            
            self.progressView.alpha = 1
            self.descLabel.alpha = 1
        }
    }
}

extension OnboardingDisplayNameController: UITextFieldDelegate {
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
