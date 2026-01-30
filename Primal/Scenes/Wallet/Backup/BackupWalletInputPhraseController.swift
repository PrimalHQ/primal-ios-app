//
//  BackupWalletInputPhraseController.swift
//  Primal
//
//  Created by Pavle Stevanović on 30. 1. 2026..
//

import UIKit

class BackupWalletInputPhraseController: UIViewController {
    
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

class WalletInputPhraseView: UIStackView {
    
    let inputParentView = UIView().constrainToSize(height: 40)
    let checkLabel = UILabel("Incorrect", color: .init(rgb: 0xFE3D2F), font: .appFont(withSize: 13, weight: .regular))
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(word: String, index: Int) {
        super.init(frame: .zero)
        
        let wordLabel = UILabel("Type word #\(index):", color: .foreground, font: .appFont(withSize: 16, weight: .bold))
        
        inputParentView.layer.cornerRadius = 20
        inputParentView.layer.borderWidth = 1
        inputParentView.layer.borderColor = UIColor.foreground6.cgColor
        
        let input = UITextField()
        input.font = .appFont(withSize: 16, weight: .semibold)
        input.textColor = .foreground
        
        inputParentView.addSubview(input)
        input
            .pinToSuperview(edges: .horizontal, padding: 6)
            .pinToSuperview(edges: .vertical, padding: 4)
        
        addArrangedSubview(wordLabel)
        addArrangedSubview(inputParentView)
        spacing = 10
    }
}
