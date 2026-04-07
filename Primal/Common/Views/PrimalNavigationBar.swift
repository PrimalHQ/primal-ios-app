//
//  PrimalNavigationBar.swift
//  Primal
//
//  Created by Pavle Stevanović on 3.4.26..
//

import Combine
import UIKit

protocol PrimalNavigationBarController: UIViewController {
    var primalNavigationBar: PrimalNavigationBar { get }
}

extension PrimalNavigationBarController {
    func addNavigationBar() {
        view.addSubview(primalNavigationBar)
        primalNavigationBar.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, safeArea: true)
    }
}

final class PrimalNavigationBar: UIView, Themeable {
    let titleLabel = UILabel()
    let chevronView = UIImageView(image: UIImage(named: "navChevron"))
    let subtitleLabel = UILabel()
    let userImageView = UserImageView(height: 36)

    private let titleButton = UIButton()
    private let avatarButton = UIButton()

    private var cancellables: Set<AnyCancellable> = []

    var title: String = "" {
        didSet { titleLabel.text = title }
    }

    var subtitle: String = "" {
        didSet { subtitleLabel.text = subtitle }
    }

    var showChevron: Bool = true {
        didSet { chevronView.isHidden = !showChevron }
    }

    var onTitleTapped: (() -> Void)?
    var onAvatarTapped: (() -> Void)?

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateTheme() {
        backgroundColor = .background
        titleLabel.textColor = .foreground
        subtitleLabel.textColor = .foreground5
        chevronView.image = UIImage(named: "navChevron")?.withTintColor(.foreground).withRenderingMode(.alwaysOriginal)
    }
}

private extension PrimalNavigationBar {
    func setup() {
        constrainToSize(height: 64)

        titleLabel.font = .appFont(withSize: 20, weight: .bold)
        subtitleLabel.font = .appFont(withSize: 14, weight: .regular)

        chevronView.setContentHuggingPriority(.required, for: .horizontal)
        chevronView.setContentCompressionResistancePriority(.required, for: .horizontal)

        let titleRow = UIStackView(arrangedSubviews: [titleLabel, chevronView])
        titleRow.alignment = .center
        titleRow.spacing = 8

        let leftStack = UIStackView(arrangedSubviews: [titleRow, subtitleLabel])
        leftStack.axis = .vertical
        leftStack.spacing = 2

        addSubview(leftStack)
        leftStack
            .pinToSuperview(edges: .leading, padding: 20)
            .centerToSuperview(axis: .vertical)

        addSubview(userImageView)
        userImageView
            .pinToSuperview(edges: .trailing, padding: 16)
            .centerToSuperview(axis: .vertical)

        leftStack.trailingAnchor.constraint(lessThanOrEqualTo: userImageView.leadingAnchor, constant: -12).isActive = true

        addSubview(titleButton)
        titleButton.pin(to: leftStack)
        titleButton.addAction(.init(handler: { [weak self] _ in
            self?.onTitleTapped?()
        }), for: .touchUpInside)

        addSubview(avatarButton)
        avatarButton.pin(to: userImageView)
        avatarButton.addAction(.init(handler: { [weak self] _ in
            self?.onAvatarTapped?()
        }), for: .touchUpInside)

        IdentityManager.instance.$parsedUser
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.userImageView.setUserImage(user)
            }
            .store(in: &cancellables)

        updateTheme()
    }
}
