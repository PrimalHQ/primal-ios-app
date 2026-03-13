//
//  RemoteSignerSignInViews.swift
//  Primal
//
//  Created by Pavle Stevanović on 13. 3. 2026..
//

import UIKit
import PrimalShared
import Kingfisher

enum AppSignTrustLevel {
    case full, medium, low

    var name: String {
        "\(self)".capitalized + " Trust"
    }

    var desc: String {
        switch self {
        case .full:     return "I fully trust this app; auto-sign all requests"
        case .medium:   return "Auto-approve most common requests"
        case .low:      return "Ask me to approve each request"
        }
    }

    var icon: UIImage {
        switch self {
        case .full:
            return .Signer.highTrust
        case .medium:
            return .Signer.mediumTrust
        case .low:
            return .Signer.lowTrust
        }
    }

    var trustLevel: TrustLevel {
        switch self {
        case .full:     return .full
        case .medium:   return .medium
        case .low:      return .low
        }
    }
}

class TrustSelectionButton: MyButton {
    let imageView = UIImageView().constrainToSize(40)
    let nameLabel = UILabel("", color: .foreground, font: .appFont(withSize: 16, weight: .bold))
    let descLabel = UILabel("", color: .foreground4, font: .appFont(withSize: 14, weight: .regular))

    override var isPressed: Bool {
        didSet {
            layer.borderWidth = isSelected || isPressed ? 1 : 0
        }
    }

    override var isSelected: Bool {
        didSet {
            layer.borderWidth = isSelected || isPressed ? 1 : 0
        }
    }

    init(trustLevel: AppSignTrustLevel) {
        super.init(frame: .zero)

        let nameStack = UIStackView(axis: .vertical, [nameLabel, descLabel])
        nameStack.spacing = 2

        let mainStack = UIStackView([imageView, nameStack])
        mainStack.alignment = .center
        mainStack.spacing = 10

        addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 14).pinToSuperview(edges: .vertical, padding: 12)

        layer.cornerRadius = 12
        layer.borderColor = UIColor.accent.cgColor
        backgroundColor = .background3

        imageView.tintColor = Theme.inverse.foreground4

        imageView.image = trustLevel.icon
        nameLabel.text = trustLevel.name
        descLabel.text = trustLevel.desc
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class UserSelectionButton: MyButton {
    let avatar = UserImageView(height: 40)
    let checkbox = VerifiedView().constrainToSize(15)
    let nameLabel = UILabel("", color: .foreground, font: .appFont(withSize: 16, weight: .bold))
    let nipLabel = UILabel("", color: .foreground4, font: .appFont(withSize: 14, weight: .regular))

    override var isPressed: Bool {
        didSet {
            layer.borderWidth = isSelected || isPressed ? 1 : 0
        }
    }

    override var isSelected: Bool {
        didSet {
            layer.borderWidth = isSelected || isPressed ? 1 : 0
        }
    }

    init(user: ParsedUser) {
        super.init(frame: .zero)

        let nameStack = UIStackView([nameLabel, checkbox])
        nameStack.spacing = 4

        let nameSuperStack = UIStackView(axis: .vertical, [nameStack, nipLabel])
        nameSuperStack.spacing = 2
        nameSuperStack.alignment = .leading

        let mainStack = UIStackView([avatar, nameSuperStack])
        mainStack.alignment = .center
        mainStack.spacing = 10

        addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 14).pinToSuperview(edges: .vertical, padding: 12)

        layer.cornerRadius = 12
        layer.borderColor = UIColor.accent.cgColor
        backgroundColor = .background3

        avatar.setUserImage(user)
        checkbox.user = user.data
        nameLabel.text = user.data.firstIdentifier
        nipLabel.text = user.data.secondIdentifier
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class BudgetSelectionButton: MyButton {
    let satsLabel = UILabel("", color: .foreground, font: .appFont(withSize: 14, weight: .semibold))
    let usdLabel = UILabel("", color: .foreground4, font: .appFont(withSize: 12, weight: .regular))

    override var isPressed: Bool { didSet { updateColors() } }
    override var isSelected: Bool { didSet { updateColors() } }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(sats: Int?) {
        super.init(frame: .zero)

        let contentStack = UIStackView(axis: .vertical, [satsLabel, usdLabel])
        contentStack.alignment = .center
        contentStack.spacing = 2

        addSubview(contentStack)
        contentStack.pinToSuperview(edges: .horizontal, padding: 8).pinToSuperview(edges: .vertical, padding: 8)

        layer.cornerRadius = 12
        layer.borderColor = UIColor.accent.cgColor
        backgroundColor = .background3

        if let sats {
            satsLabel.attributedText = .satsString(sats, fontSize: 14, weight: .semibold)
            let usdAmount = Double(sats).satToUSD
            usdLabel.text = "~\(String(format: "%.2f", usdAmount)) USD"
        } else {
            satsLabel.text = "NO LIMIT"
            usdLabel.isHidden = true
        }
    }
    
    func updateColors() {
        let highlight = isSelected || isPressed
        layer.borderWidth = highlight ? 1 : 0
        backgroundColor = highlight ? .background5 : .background3
    }
}

class DailyBudgetInfoRow: MyButton {
    let budgetLabel = UILabel("", color: .foreground3, font: .appFont(withSize: 16, weight: .regular))

    init(budgetText: String) {
        super.init(frame: .zero)

        backgroundColor = .background3
        layer.cornerRadius = 12

        let leftLabel = UILabel("Daily budget", color: .foreground, font: .appFont(withSize: 16, weight: .regular))
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)))
        chevron.tintColor = .foreground3

        budgetLabel.text = budgetText

        let content = UIStackView([leftLabel, UIView(), budgetLabel, chevron])
        content.alignment = .center
        content.spacing = 6
        addSubview(content)
        content.pinToSuperview(edges: .horizontal, padding: 14).pinToSuperview(edges: .vertical, padding: 14)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class BudgetPickerView: UIView {
    static let budgetOptions: [Int?] = [0, 1_000, 5_000, 10_000, 20_000, 50_000, 100_000, nil]

    var onBudgetSelected: ((Int?) -> Void)?

    private var buttons: [(sats: Int?, button: BudgetSelectionButton)] = []
    private var selectedButton: BudgetSelectionButton? {
        didSet {
            oldValue?.isSelected = false
            selectedButton?.isSelected = true
        }
    }

    private(set) var selectedBudget: Int?

    init(selectedBudget: Int?) {
        self.selectedBudget = selectedBudget
        super.init(frame: .zero)
        setup()
    }

    func setSelectedBudget(_ sats: Int?) {
        selectedBudget = sats
        selectedButton = buttons.first(where: { $0.sats == sats })?.button
    }

    private func setup() {
        let stack = UIStackView(axis: .vertical, [])
        stack.spacing = 8

        let title = UILabel("Daily spending budget for this app:", color: .foreground, font: .appFont(withSize: 16, weight: .semibold))
        title.textAlignment = .center
        stack.addArrangedSubview(title)
        stack.setCustomSpacing(24, after: title)

        let gridStack = UIStackView(axis: .vertical, [])
        gridStack.spacing = 10

        for row in stride(from: 0, to: Self.budgetOptions.count, by: 2) {
            let rowStack = UIStackView()
            rowStack.spacing = 8
            rowStack.distribution = .fillEqually

            for col in 0..<2 {
                let index = row + col
                guard index < Self.budgetOptions.count else { break }
                let sats = Self.budgetOptions[index]
                let button = BudgetSelectionButton(sats: sats)
                rowStack.addArrangedSubview(button)
                buttons.append((sats, button))

                button.addAction(.init(handler: { [weak self] _ in
                    self?.selectedButton = button
                    self?.selectedBudget = sats
                    self?.onBudgetSelected?(sats)
                }), for: .touchUpInside)
            }

            gridStack.addArrangedSubview(rowStack)
        }

        stack.addArrangedSubview(gridStack)
        addSubview(stack)
        stack.pinToSuperview()

        selectedButton = buttons.first(where: { $0.sats == selectedBudget })?.button
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
