//
//  BackupWalletPhraseController.swift
//  Primal
//
//  Created by Pavle Stevanović on 30. 1. 2026..
//

import UIKit

let seedPhrase = [
    "ocean",
    "hidden",
    "mystery",
    "puzzle",
    "element",
    "supply",
    "window",
    "bamboo",
    "silver",
    "royal",
    "nephew",
    "planet"
]

class BackupWalletPhraseController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        title = "Backup Wallet"
        navigationItem.leftBarButtonItem = customBackButton
        
        var wordStack = Array(seedPhrase.enumerated().map { ($0.0 + 1, $0.1) }.reversed())
        let rectStack = UIStackView(axis: .vertical, spacing: 4, (0...3).map { _ in
            UIStackView(axis: .horizontal, spacing: 4, (0...2).map { _ in
                guard let (index, word) = wordStack.popLast() else { return UIView() }
                return WalletPhrasePreviewView(word: word, index: index)
            })
        })
        
        let firstLabel = UILabel("This is your wallet recovery phrase. To backup your wallet, simply write these words down in the correct order.\n\nThe words are not case sensitive and they are separated by spaces. We will ask you to verify on the next screen.", color: .foreground, font: .appFont(withSize: 18, weight: .regular), multiline: true)
        
        let nextButton = UIButton(configuration: .accentPill(text: "I have written it down", font: .appFont(withSize: 18, weight: .semibold))).constrainToSize(height: 56)
        let cancelButton = UIButton(configuration: .coloredButton("Cancel, I’ll do this later", color: .foreground4, font: .appFont(withSize: 18, weight: .semibold)))
        let buttonStack = UIStackView(axis: .vertical, spacing: 24, [nextButton, cancelButton])
        
        let mainStack = UIStackView(axis: .vertical, [SpacerView(height: 40), rectStack, firstLabel, buttonStack])
        mainStack.distribution = .equalSpacing
        mainStack.alignment = .center
        
        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .top, padding: 24, safeArea: true)
            .pinToSuperview(edges: .bottom, padding: 8, safeArea: true)
            .pinToSuperview(edges: .horizontal)
        buttonStack.pinToSuperview(edges: .horizontal, padding: 35)
        firstLabel.constrainToSize(width: 313)
        
        nextButton.addAction(.init(handler: { [weak self] _ in
            self?.show(BackupWalletPhraseController(), sender: nil)
        }), for: .touchUpInside)
        
        cancelButton.addAction(.init(handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }), for: .touchUpInside)
    }
}

class WalletPhrasePreviewView: UIView {
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(word: String, index: Int) {
        super.init(frame: .zero)
        
        let wordLabel = UILabel(word, color: .foreground, font: .appFont(withSize: 16, weight: .bold))
        let indexLabel = UILabel("\(index)", color: .foreground, font: .appFont(withSize: 12, weight: .regular))
        indexLabel.alpha = 0.5
        
        constrainToSize(width: 112, height: 36)
        layer.cornerRadius = 6
        layer.borderWidth = 1
        layer.borderColor = UIColor.foreground.withAlphaComponent(0.5).cgColor
        
        addSubview(wordLabel)
        wordLabel.pinToSuperview(edges: .leading, padding: 8).centerToSuperview(axis: .vertical)
        
        addSubview(indexLabel)
        indexLabel.pinToSuperview(edges: .top, padding: 3).pinToSuperview(edges: .trailing, padding: 5)
    }
    
    
}
