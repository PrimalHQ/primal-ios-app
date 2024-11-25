//
//  OnboardingInterestsController.swift
//  Primal
//
//  Created by Pavle Stevanović on 20.3.24..
//

import Combine
import UIKit
import Kingfisher

final class OnboardingInterestsController: UIViewController, OnboardingViewController {
    
    let titleLabel: UILabel = .init()
    let backButton: UIButton = .init()
    lazy var collectionView = UIStackView(axis: .vertical, [])
    let countLabel = UILabel()
    lazy var continueButton = OnboardingMainButton("Next")
    
    var suggestionGroups: [OnboardingSession.Group] = [] {
        didSet {
            selectedToFollow = Set()
            refreshCollection()
            continueButton.isHidden = false
        }
    }
    
    let session: OnboardingSession
    let oldData: AccountCreationData
    
    var selectedToFollow: Set<String> = [] {
        didSet {
            countLabel.text = "\(selectedToFollow.count) interests selected"
            continueButton.isEnabled = !selectedToFollow.isEmpty
        }
    }
    
    var cancellables: Set<AnyCancellable> = []
    
    init(data: AccountCreationData, session: OnboardingSession) {
        oldData = data
        self.session = session
        super.init(nibName: nil, bundle: nil)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension OnboardingInterestsController {
    func setup() {
        addBackground(2)
        addNavigationBar("Your Interests")
        
        let infoLabel = UILabel()
        let progressView = PrimalProgressView(progress: 1, total: 4, markProgress: true)
        let bottomStack = UIStackView(axis: .vertical, [continueButton, SpacerView(height: 18), progressView])
        let mainStack = UIStackView(axis: .vertical, [infoLabel, collectionView, countLabel, bottomStack])
        
        view.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 36).pinToSuperview(edges: .bottom, padding: 12, safeArea: true)
        mainStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32).isActive = true
        
        mainStack.distribution = .equalSpacing
        
        infoLabel.text = "Tells us about your interests and we will create your initial follow list:"
        infoLabel.textAlignment = .center
        infoLabel.font = .appFont(withSize: 16, weight: .regular)
        infoLabel.textColor = .white
        infoLabel.numberOfLines = 0
        
        collectionView.alignment = .center
        collectionView.spacing = 16
        
        countLabel.font = .appFont(withSize: 16, weight: .regular)
        countLabel.textColor = .white.withAlphaComponent(0.75)
        countLabel.textAlignment = .center
        
        continueButton.addTarget(self, action: #selector(continuePressed), for: .touchUpInside)
        continueButton.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.continueButton.isHidden = false
        }
        
        session.$suggestionGroups.assign(to: \.suggestionGroups, onWeak: self).store(in: &cancellables)
    }
    
    func refreshCollection() {
        collectionView.subviews.forEach { $0.removeFromSuperview() }
        
        var currentHStack = UIStackView()
        currentHStack.spacing = 12

        var currentWidth: CGFloat = 0
        
        for interest in suggestionGroups.map({ $0.group }) {
            let view = InterestSelectionView(name: interest.lowercased(), isSelected: selectedToFollow.contains(interest))
            
            view.addAction(.init(handler: { [weak self] _ in
                guard let self else { return }
                if selectedToFollow.contains(interest) {
                    selectedToFollow.remove(interest)
                } else {
                    selectedToFollow.insert(interest)
                }
                view.isSelected = selectedToFollow.contains(interest)
            }), for: .touchUpInside)
            
            view.layoutIfNeeded()
            
            let width = view.frame.width
            
            if width + currentWidth > max(310, collectionView.frame.width) {
                collectionView.addArrangedSubview(currentHStack)
                
                currentHStack = UIStackView()
                currentHStack.spacing = 12
                
                currentWidth = 0
            }
            
            currentHStack.addArrangedSubview(view)
            currentWidth += width + 12
        }
        
        if !currentHStack.arrangedSubviews.isEmpty {
            collectionView.addArrangedSubview(currentHStack)
        }
    }

    @objc func continuePressed() {
        let array = suggestionGroups
            .filter({ selectedToFollow.contains($0.group) })
            .map({ $0.members.map { mem in mem.pubkey } })
            .reduce([], +)
        
        session.usersToFollow = Set(array)
        
        onboardingParent?.pushViewController(OnboardingCheckInterestsController(data: oldData, session: session), animated: true)
    }
}
