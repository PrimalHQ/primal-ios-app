//
//  BackupWalletInputPhraseController.swift
//  Primal
//
//  Created by Pavle Stevanović on 30. 1. 2026..
//

import Combine
import UIKit

class BackupWalletInputPhraseController: UIViewController {
    
    var cancellables: Set<AnyCancellable> = []
    
    @Published var correctCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        title = "Verify Recovery Phrase"
        navigationItem.leftBarButtonItem = customBackButton
        
        Task { @MainActor in
            let seedPhrase = try await WalletManager.instance.seedPhrase()
            self.setup(seedPhrase)
        }
    }
    
    func setup(_ seedPhrase: [String]) {
        let wordViews = seedPhrase.enumerated()
            .shuffled()
            .prefix(3)
            .sorted(by: { $0.offset < $1.offset })
            .map({ ($0.0 + 1, $0.1) }).map { WalletInputPhraseView(word: $0.1, index: $0.0) }
        let wordStack = UIStackView(axis: .vertical, spacing: 24, wordViews)
        
        let scrollView = UIScrollView()
        scrollView.addSubview(wordStack)
        wordStack.pinToSuperview(edges: .top, padding: 10).pinToSuperview(edges: .bottom, padding: 40).pinToSuperview(edges: .horizontal)
        
        let nextButton = UIButton(configuration: .pill(text: "Verify", foregroundColor: .foreground5, backgroundColor: .background3, font: .appFont(withSize: 18, weight: .semibold))).constrainToSize(height: 56)
        nextButton.isEnabled = false
        
        let keyboardView = KeyboardSizingView()
        
        let mainStack = UIStackView(axis: .vertical, [scrollView, SpacerView(height: 30), nextButton, SpacerView(height: 20), keyboardView])
        
        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .top, padding: 10, safeArea: true)
            .pinToSuperview(edges: .bottom)
            .pinToSuperview(edges: .horizontal, padding: 24)
        
        keyboardView.topAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8).isActive = true
        wordStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        zip(wordViews, wordViews.dropFirst()).forEach { (current, next) in
            current.nextView = next
        }
        
        for view in wordViews {
            view.$isCorrect.map({ $0 ?? false }).removeDuplicates().dropFirst().sink { [weak self] new in
                self?.correctCount += new ? 1 : -1
            }
            .store(in: &cancellables)
        }
        
        $correctCount.map { $0 >= 12 }
            .sink { isAllCorrect in
                nextButton.configuration = isAllCorrect ?
                    .accentPill(text: "Verify", font: .appFont(withSize: 18, weight: .semibold)) :
                    .pill(text: "Verify", foregroundColor: .foreground5, backgroundColor: .background3, font: .appFont(withSize: 18, weight: .semibold))
                nextButton.isEnabled = isAllCorrect
            }
            .store(in: &cancellables)
        
        keyboardView.updateHeightCancellable().store(in: &cancellables)
        
        nextButton.addAction(.init(handler: { [weak self] _ in
            self?.show(BackupWalletConfirmController(), sender: nil)
        }), for: .touchUpInside)
    }
}

extension UIColor {
    static let failureRed = UIColor(rgb: 0xFE3D2F)
    static let inputSuccess = UIColor(rgb: 0x2FD058)
}

class WalletInputPhraseView: UIStackView {
    let input = UITextField()
    @Published var isCorrect: Bool?
    
    weak var nextView: WalletInputPhraseView?
    
    private let inputParentView = UIView().constrainToSize(height: 40)
    private let checkLabel = UILabel("Incorrect", color: .failureRed, font: .appFont(withSize: 13, weight: .regular))
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(word: String, index: Int) {
        super.init(frame: .zero)
        
        let wordLabel = UILabel("Type word #\(index):", color: .foreground, font: .appFont(withSize: 16, weight: .bold))
        
        inputParentView.layer.cornerRadius = 20
        inputParentView.layer.borderWidth = 1
        inputParentView.layer.borderColor = UIColor.foreground6.cgColor
        
        input.font = .appFont(withSize: 16, weight: .semibold)
        input.textColor = .foreground
        input.returnKeyType = .next
        input.autocapitalizationType = .none
        input.keyboardType = .alphabet
        input.delegate = self
        
        inputParentView.addSubview(input)
        input
            .pinToSuperview(edges: .horizontal, padding: 12)
            .pinToSuperview(edges: .vertical, padding: 4)
        
        inputParentView.addSubview(checkLabel)
        checkLabel.pinToSuperview(edges: .trailing, padding: 18).centerToSuperview(axis: .vertical)
        checkLabel.isHidden = true
        
        input.addAction(.init(handler: { [weak input, weak self] _ in
            guard let input, let self else { return }
            
            let inputText = input.text?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let newValue = inputText == word
            if !newValue, word.hasPrefix(inputText) {
                isCorrect = nil
                checkLabel.isHidden = true
                inputParentView.layer.borderColor = UIColor.foreground6.cgColor
                return
            }
            isCorrect = newValue
            inputParentView.layer.borderColor = (newValue ? UIColor.inputSuccess : .failureRed).withAlphaComponent(0.5).cgColor
            checkLabel.textColor = newValue ? UIColor.inputSuccess : .failureRed
            checkLabel.text = newValue ? "Correct" : "Incorrect"
            checkLabel.isHidden = false
        }), for: .editingChanged)
        
        addArrangedSubview(wordLabel)
        addArrangedSubview(inputParentView)
        spacing = 10
        axis = .vertical
    }
}

extension WalletInputPhraseView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let nextView else {
            textField.resignFirstResponder()
            return true
        }
        nextView.input.becomeFirstResponder()
        return true
    }
}
