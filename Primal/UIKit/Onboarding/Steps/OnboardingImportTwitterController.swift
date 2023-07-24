//
//  OnboardingImportTwitterController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 24.4.23..
//

import Combine
import UIKit

final class OnboardingImportTwitterController: UIViewController {
    enum State {
        case ready
        case searching
        case notFound
    }
    
    var state: State = .ready {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.updateView()
            }
        }
    }
    
    private lazy var progressView = PrimalProgressView(progress: 2, total: 4)
    private lazy var input = BorderedTextField(showAtSymbol: true)
    private lazy var infoLabel = UILabel()
    private lazy var spinner = LoadingSpinnerView()
    private lazy var confirmButton = FancyButton(title: "Find Twitter profile")
    private lazy var instruction = UILabel()
    private lazy var textStack = UIStackView(arrangedSubviews: [instruction, input, infoLabel])
    private let spinnerParent = UIView()
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
}

private extension OnboardingImportTwitterController {
    func search() {
        guard let username = input.input.text, !username.isEmpty else {
            state = .notFound
            return
        }
        UserDefaults.standard.setValue(username, forKey: "username")
        
        state = .searching
        input.input.resignFirstResponder()
        
        TwitterUserRequest(username: username).publisher()
            .retry(2)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.state = .ready
                case .failure:
                    self?.state = .notFound
                    self?.showErrorMessage(title: "Can’t Show Profile", "We couldn't fetch that profile at this time. Please try again.")
                }
            }, receiveValue: { [weak self] profile in
                let twitter = OnboardingProfileController(profile: profile, uploader: nil)
                self?.show(twitter, sender: nil)
            })
            .store(in: &cancellables)
    }
    
    func updateView() {
        switch state {
        case .ready:
            title = "Import from Twitter"
            textStack.alpha = 1
            textStack.isHidden = false
            spinnerParent.alpha = 0
            spinnerParent.isHidden = true
            infoLabel.alpha = 0
            confirmButton.isEnabled = input.input.text?.isEmpty != true
        case .searching:
            title = "Searching..."
            textStack.alpha = 0
            textStack.isHidden = true
            spinnerParent.alpha = 1
            spinnerParent.isHidden = false
            spinner.play()
            confirmButton.isEnabled = false
        case .notFound:
            title = "Import from Twitter"
            textStack.alpha = 1
            textStack.isHidden = false
            spinner.alpha = 0
            spinner.isHidden = true
            infoLabel.alpha = 1
            confirmButton.isEnabled = true
        }
    }
    
    func setup() {
        view.backgroundColor = .black
        
        let button = UIButton()
        button.setImage(UIImage(named: "back"), for: .normal)
        button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        
        let progressParent = UIView()
        let mainStack = UIStackView(arrangedSubviews: [progressParent, textStack, spinnerParent, confirmButton])
        
        progressParent.addSubview(progressView)
        progressView.pinToSuperview(edges: .vertical).centerToSuperview()
        
        spinnerParent.addSubview(spinner)
        spinner.pinToSuperview(edges: .vertical).centerToSuperview().constrainToSize(100)
        
        instruction.font = .appFont(withSize: 20, weight: .regular)
        instruction.textColor = .init(rgb: 0xAAAAAA)
        instruction.textAlignment = .center
        instruction.adjustsFontSizeToFitWidth = true
        instruction.text = "Your Twitter username:"
        
        input.input.font = .appFont(withSize: 18, weight: .medium)
        input.input.textColor = .init(rgb: 0xCCCCCC)
        input.input.delegate = self
        input.input.addTarget(self, action: #selector(inputChanged), for: .editingChanged)
        
        infoLabel.font = .appFont(withSize: 14, weight: .regular)
        infoLabel.textAlignment = .center
        infoLabel.textColor = .init(rgb: 0xE20505)
        infoLabel.text = "Twitter account not found"
        
        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .top, safeArea: true)
            .pinToSuperview(edges: .horizontal, padding: 36)
            .bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -20).isActive = true
        
        mainStack.axis = .vertical
        textStack.axis = .vertical
        
        mainStack.distribution = .equalSpacing
        
        textStack.spacing = 10
        textStack.setCustomSpacing(24, after: instruction)
        
        confirmButton.addTarget(self, action: #selector(confirmButtonPressed), for: .touchUpInside)
        
        updateView()
    }
    
    @objc func inputChanged() {
        confirmButton.isEnabled = input.input.text?.isEmpty != true
    }
    
    @objc func confirmButtonPressed() {
        switch state {
        case .ready, .notFound:
            search()
        case .searching: break // No Action
        }
    }
}

extension OnboardingImportTwitterController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        search()
        return true
    }
}
