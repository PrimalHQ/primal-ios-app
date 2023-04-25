//
//  OnboardingImportTwitterController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 24.4.23..
//

import UIKit

class OnboardingImportTwitterController: UIViewController {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
}

private extension OnboardingImportTwitterController {
    func updateView() {
        switch state {
        case .ready:
            title = "Import from Twitter"
            textStack.alpha = 1
            textStack.isHidden = false
            spinner.alpha = 0
            spinner.isHidden = true
            infoLabel.alpha = 0
            confirmButton.isEnabled = input.input.text?.isEmpty != true
        case .searching:
            title = "Searching..."
            textStack.alpha = 0
            textStack.isHidden = true
            spinner.alpha = 1
            spinner.isHidden = false
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
        let mainStack = UIStackView(arrangedSubviews: [progressParent, textStack, spinner, confirmButton])
        
        progressParent.addSubview(progressView)
        progressView.pinToSuperview(edges: .vertical).centerToSuperview()
        
        instruction.font = .appFont(withSize: 20, weight: .regular)
        instruction.textColor = .init(rgb: 0xAAAAAA)
        instruction.textAlignment = .center
        instruction.adjustsFontSizeToFitWidth = true
        instruction.text = "Your Twitter username:"
        
        input.input.font = .appFont(withSize: 18, weight: .medium)
        input.input.textColor = .init(rgb: 0xCCCCCC)
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
        case .ready:
            if infoLabel.text?.isEmpty == true {
                let twitter = OnboardingTwitterController()
                show(twitter, sender: nil)
                return
            }
            
            state = .searching
            input.input.resignFirstResponder()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                self.state = .notFound
            }
        case .searching:
            state = .notFound
        case .notFound:
            state = .ready
            infoLabel.text = ""
        }
    }
}

