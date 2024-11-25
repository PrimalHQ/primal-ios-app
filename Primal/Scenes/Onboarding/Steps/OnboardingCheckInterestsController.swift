//
//  OnboardingCheckInterestsController.swift
//  Primal
//
//  Created by Pavle Stevanović on 25.11.24..
//

import Combine
import UIKit
import SafariServices

final class OnboardingCheckInterestsController: UIViewController, OnboardingViewController {
    let oldData: AccountCreationData
    var session: OnboardingSession
    
    let instructionLabel = UILabel()
    let continueButton = OnboardingMainButton("Next")
    let titleLabel: UILabel = .init()
    let backButton = UIButton()
    let progressView = PrimalProgressView(progress: 2, total: 4, markProgress: true)
    
    var editSelected = false
    
    var cancellables: Set<AnyCancellable> = []
    
    init(data: AccountCreationData, session: OnboardingSession) {
        self.oldData = data
        self.session = session
        super.init(nibName: nil, bundle: nil)
        
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension OnboardingCheckInterestsController {
    func setup() {
        addBackground(3)
        addNavigationBar("Your Follows")
        instructionLabel.attributedText = descAttributedString("We followed \(session.usersToFollow.count) Nostr accounts based on the interests you selected.")
        
        let botStack = UIStackView(axis: .vertical, [continueButton, progressView])
        botStack.spacing = 18
        
        
        instructionLabel.numberOfLines = 0
        let keepOption = OnboardingOptionSelectionView(title: "Keep the recommended follows", subtitle: "(you can update this later)", checked: true)
        let changeOption = OnboardingOptionSelectionView(title: "Customize follows now", subtitle: "(edit the recommended follows)", checked: false)
        
        keepOption.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.editSelected = false
            keepOption.isChecked = true
            changeOption.isChecked = false
        }))
        
        changeOption.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.editSelected = true
            keepOption.isChecked = false
            changeOption.isChecked = true
        }))
        
        let midStack = UIStackView(axis: .vertical, [keepOption, changeOption])
        midStack.spacing = 16
        
        let stack = UIStackView(arrangedSubviews: [instructionLabel, midStack, botStack])
        view.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 36).pin(to: titleLabel, edges: .top, padding: 60).pinToSuperview(edges: .bottom, padding: 12, safeArea: true)
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        
        continueButton.addTarget(self, action: #selector(continuePressed), for: .touchUpInside)
    }
    
    @objc func continuePressed() {
        if editSelected {
            onboardingParent?.pushViewController(OnboardingFollowSuggestionsController(data: oldData, session: session), animated: true)
        } else {
            onboardingParent?.pushViewController(OnboardingPreviewController(data: oldData, session: session), animated: true)
        }
    }
}

class OnboardingOptionSelectionView: UIView {
    let checkImageView = UIImageView()
    
    var isChecked: Bool { didSet { updateImage() }}
    
    var didChangeEvent = PassthroughSubject<Void, Never>()
        
    init(title: String, subtitle: String, checked: Bool) {
        isChecked = checked
        super.init(frame: .zero)
        
        layer.cornerRadius = 12
        backgroundColor = .init(rgb: 0x222222).withAlphaComponent(0.4)
        let titleLabel = UILabel(title, color: .white, font: .appFont(withSize: 16, weight: .semibold))
        titleLabel.adjustsFontSizeToFitWidth = true
        let titleStack = UIStackView(axis: .vertical, [titleLabel, UILabel(subtitle, color: .white, font: .appFont(withSize: 16, weight: .regular))])
        let titleStackParent = UIView()
        titleStackParent.addSubview(titleStack)
        titleStack.pinToSuperview(edges: .vertical).pinToSuperview(edges: .horizontal, padding: -7)
        let mainStack = UIStackView(axis: .horizontal, [checkImageView, titleStackParent])
        mainStack.spacing = 16
        mainStack.alignment = .center
        addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .vertical, padding: 10)
        
        checkImageView.setContentHuggingPriority(.required, for: .horizontal)
        
        updateImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func updateImage() {
        checkImageView.image = UIImage(named: isChecked ? "selectionCircleFilled" : "selectionCircle")
    }
}
