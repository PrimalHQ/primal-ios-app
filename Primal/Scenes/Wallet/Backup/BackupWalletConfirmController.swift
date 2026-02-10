//
//  BackupWalletConfirmController.swift
//  Primal
//
//  Created by Pavle Stevanović on 2. 2. 2026..
//

import Combine
import UIKit

class BackupWalletConfirmController: UIViewController {
    
    var cancellables: Set<AnyCancellable> = []
    
    @Published var checkedCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Congrats!"
        navigationItem.leftBarButtonItem = customBackButton
        view.backgroundColor = .background
        
        let label = UILabel("Your wallet has been backed up. You now hold the keys to your bitcoin! Please confirm the three points below.", color: .foreground, font: .appFont(withSize: 18, weight: .regular), multiline: true)
        
        let checkViews = [
            BackupWalletCheckView(text: "My funds are not held by Primal"),
            BackupWalletCheckView(text: "If my device gets lost or stolen, the only way to recover my funds is via the wallet recovery phrase"),
            BackupWalletCheckView(text: "It is my sole responsibility to keep my recovery phrase safe")
        ]
        let checkStack = UIStackView(axis: .vertical, spacing: 32, checkViews)
        
        let bodyStack = UIStackView(axis: .vertical, spacing: 35, [
            UILabel("I understand that:", color: .foreground, font: .appFont(withSize: 22, weight: .bold), multiline: true),
            checkStack
        ])
        
        let finishButton = UIButton().constrainToSize(height: 56)
        
        let mainStack = UIStackView(axis: .vertical, [label, bodyStack, finishButton])
        mainStack.distribution = .equalSpacing
        
        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .top, padding: 24, safeArea: true)
            .pinToSuperview(edges: .bottom, padding: 20, safeArea: true)
            .pinToSuperview(edges: .horizontal, padding: 24)
        
        
        for view in checkViews {
            view.$isChecked.removeDuplicates().dropFirst().sink { [weak self] new in
                self?.checkedCount += new ? 1 : -1
            }
            .store(in: &cancellables)
        }
        
        $checkedCount.map { $0 >= 3 }
            .sink { isAllChecked in
                finishButton.configuration = isAllChecked ?
                    .accentPill(text: "Finish", font: .appFont(withSize: 18, weight: .semibold)) :
                    .pill(text: "Finish", foregroundColor: .foreground5, backgroundColor: .background3, font: .appFont(withSize: 18, weight: .semibold))
                finishButton.isEnabled = isAllChecked
            }
            .store(in: &cancellables)

        
        finishButton.addAction(.init(handler: { [weak self] _ in
            WalletManager.instance.markWalletAsBackedUp()
            
            self?.dismiss(animated: true)
        }), for: .touchUpInside)
    }
}


class BackupWalletCheckView: UIStackView {
    @Published var isChecked = false
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(text: String) {
        super.init(frame: .zero)
        
        let check = CheckboxRadioButton().constrainToSize(44)
        check.accent = false
        addArrangedSubview(check)
        
        let label = UILabel(text, color: .foreground, font: .appFont(withSize: 18, weight: .regular))
        label.numberOfLines = 0
        addArrangedSubview(label)
        addArrangedSubview(SpacerView(width: 11))
        
        alignment = .center
        
        check.addAction(.init(handler: { [weak self] _ in
            self?.isChecked.toggle()
            check.isSelected = self?.isChecked ?? false
        }), for: .touchUpInside)
    }
}
