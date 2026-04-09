//
//  PrimalNavigationBar.swift
//  Primal
//
//  Created by Pavle Stevanović on 3.4.26..
//

import Combine
import UIKit

enum ChromeSize {
    case small, regular, medium, large

    static let current: ChromeSize = {
        let screenWidth = RootViewController.instance.view.frame.size.width

        if screenWidth < 380 { return .small }
        if screenWidth < 405 { return .regular }
        if screenWidth < 430 { return .medium }
        return .large
    }()
}

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
    static let height: CGFloat = {
        switch ChromeSize.current {
        case .small: return 64
        case .regular: return 70
        case .medium: return 76
        case .large: return 83
        }
    }()

    private static let titleFontSize: CGFloat = {
        switch ChromeSize.current {
        case .small: return 24
        case .regular: return 26
        case .medium: return 28
        case .large: return 30
        }
    }()

    private static let subtitleFontSize: CGFloat = {
        switch ChromeSize.current {
        case .small: return 14
        case .regular: return 15
        case .medium: return 15
        case .large: return 17
        }
    }()

    private static let avatarSize: CGFloat = {
        switch ChromeSize.current {
        case .small: return 37
        case .regular: return 41
        case .medium: return 43
        case .large: return 45
        }
    }()

    private static let chevronSize: CGFloat = {
        switch ChromeSize.current {
        case .small: return 10
        case .regular: return 10
        case .medium: return 10
        case .large: return 12
        }
    }()

    let titleLabel = UILabel()
    let chevronView = UIImageView(image: UIImage(named: "navChevron"))
    let subtitleLabel = UILabel()
    let userImageView = UserImageView(height: PrimalNavigationBar.avatarSize)
    let border = SpacerView(height: 1, color: .background3)

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
        border.backgroundColor = .background3
        titleLabel.textColor = .foreground
        subtitleLabel.textColor = .foreground5
        chevronView.image = UIImage(named: "navChevron")?.withTintColor(.foreground).withRenderingMode(.alwaysOriginal)
    }
}

private extension PrimalNavigationBar {
    func setup() {
        constrainToSize(height: Self.height)

        addSubview(border)
        border.pinToSuperview(edges: [.horizontal, .bottom])

        titleLabel.font = .appFont(withSize: Self.titleFontSize, weight: .bold)
        subtitleLabel.font = .appFont(withSize: Self.subtitleFontSize, weight: .regular)

        chevronView.constrainToSize(Self.chevronSize)
        chevronView.contentMode = .scaleAspectFit
        chevronView.setContentHuggingPriority(.required, for: .horizontal)
        chevronView.setContentCompressionResistancePriority(.required, for: .horizontal)

        let titleRow = UIStackView(spacing: 8, [titleLabel, chevronView])
        titleRow.alignment = .center

        let leftStack = UIStackView(axis: .vertical, spacing: 2, [titleRow, subtitleLabel])
        leftStack.alignment = .leading
        
        let mainStack = UIStackView(spacing: 12, [leftStack, userImageView])
        mainStack.alignment = .center

        addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .leading, padding: 18)
            .pinToSuperview(edges: .trailing, padding: 16)
            .centerToSuperview(axis: .vertical)

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
