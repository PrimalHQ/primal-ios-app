//
//  PopupPollTypeController.swift
//  Primal
//
//  Created by Pavle Stevanović on 26. 2. 2026..
//

import UIKit

protocol PopupPollTypeDelegate: AnyObject {
    func pollTypeController(_ controller: PopupPollTypeController, didSelect type: PollType)
}

final class PopupPollTypeController: UIViewController {
    weak var delegate: PopupPollTypeDelegate?

    private let userPollCard = PollTypeOptionView(
        icon: UIImage(systemName: "person.fill"),
        title: "User Poll",
        subtitle: "One vote per user"
    )

    private let zapPollCard = PollTypeOptionView(
        icon: UIImage(systemName: "bolt.fill"),
        title: "Zap Poll",
        subtitle: "One zap per user. Option with the highest total sats wins. You can set minimum and maximum zap amounts per vote. Set them equal if you want every vote to carry the same weight."
    )

    private var selectedType: PollType

    init(currentType: PollType) {
        self.selectedType = currentType
        super.init(nibName: nil, bundle: nil)
        overrideUserInterfaceStyle = Theme.current.userInterfaceStyle
        
        if let pc = presentationController as? UISheetPresentationController {
            pc.detents = [.custom(resolver: { _ in 270 })]
            pc.prefersGrabberVisible = true
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { Theme.current.statusBarStyle }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        updateSelection()
    }

    private func setup() {
        view.backgroundColor = .background4

        let titleLabel = UILabel("Select poll type", color: .foreground, font: .appFont(withSize: 20, weight: .bold))

        let mainStack = UIStackView(axis: .vertical, [
            titleLabel,
            SpacerView(height: 16),
            userPollCard,
            SpacerView(height: 12),
            zapPollCard
        ])

        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .top, padding: 16)
            .pinToSuperview(edges: .horizontal, padding: 20)

        mainStack.alignment = .center
        titleLabel.pinToSuperview(edges: .leading)
        userPollCard.pinToSuperview(edges: .horizontal)
        zapPollCard.pinToSuperview(edges: .horizontal)

        userPollCard.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            guard let self else { return }
            self.selectedType = .user
            self.updateSelection()
            self.delegate?.pollTypeController(self, didSelect: .user)
            self.dismiss(animated: true)
        }))

        zapPollCard.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            guard let self else { return }
            self.selectedType = .defaultZap
            self.updateSelection()
            self.delegate?.pollTypeController(self, didSelect: .defaultZap)
            self.dismiss(animated: true)
        }))
    }

    private func updateSelection() {
        switch selectedType {
        case .user:
            userPollCard.setSelected(true)
            zapPollCard.setSelected(false)
        case .zap:
            userPollCard.setSelected(false)
            zapPollCard.setSelected(true)
        }
    }
}

private class PollTypeOptionView: UIView {
    init(icon: UIImage?, title: String, subtitle: String) {
        super.init(frame: .zero)

        let iconView = UIImageView(image: icon)
        iconView.tintColor = .foreground
        iconView.contentMode = .scaleAspectFit
        iconView.constrainToSize(20)

        let titleLabel = UILabel(title, color: .foreground, font: .appFont(withSize: 16, weight: .semibold))
        let subtitleLabel = UILabel(subtitle, color: .foreground3, font: .appFont(withSize: 14, weight: .regular))
        subtitleLabel.numberOfLines = 0

        let titleRow = UIStackView(spacing: 8, [iconView, titleLabel])
        titleRow.alignment = .center

        let contentStack = UIStackView(axis: .vertical, spacing: 6, [titleRow, subtitleLabel])

        addSubview(contentStack)
        contentStack.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .vertical, padding: 12)

        backgroundColor = .background3
        layer.cornerRadius = 12
        layer.borderWidth = 2
        layer.borderColor = UIColor.clear.cgColor
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setSelected(_ selected: Bool) {
        layer.borderColor = selected ? UIColor.accent.cgColor : UIColor.clear.cgColor
    }
}
