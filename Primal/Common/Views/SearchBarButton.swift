//
//  SearchBarButton.swift
//  Primal
//
//  Created by Pavle D Stevanović on 28.4.26..
//

import UIKit

final class SearchBarButton: UIButton, Themeable {
    let configButton = UIButton(type: .system)

    var onTap: (() -> Void)?
    var onConfigTap: (() -> Void)?

    var placeholder: String {
        didSet { updateTitle() }
    }

    var showsConfigButton: Bool {
        didSet {
            configButton.isHidden = !showsConfigButton
            configureButton()
        }
    }

    init(placeholder: String = "Search…", showsConfigButton: Bool = true) {
        self.placeholder = placeholder
        self.showsConfigButton = showsConfigButton
        super.init(frame: .zero)

        addSubview(configButton)
        configButton.setImage(.searchConfig.withRenderingMode(.alwaysTemplate), for: .normal)
        configButton.constrainToSize(40)
        configButton.centerToSuperview(axis: .vertical)
        configButton.pinToSuperview(edges: .trailing, padding: 4)
        configButton.isHidden = !showsConfigButton
        configButton.addAction(.init(handler: { [weak self] _ in
            self?.onConfigTap?()
        }), for: .touchUpInside)
        
        constrainToSize(height: 40)

        addAction(.init(handler: { [weak self] _ in
            self?.onTap?()
        }), for: .touchUpInside)

        configureButton()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func updateTheme() {
        configureButton()
    }

    private func configureButton() {
        var config: UIButton.Configuration
        if #available(iOS 26.0, *) {
            config = .glass()
        } else {
            config = .gray()
            config.baseForegroundColor = .foreground.withAlphaComponent(0.7)
        }

        config.cornerStyle = .capsule
        config.image = UIImage.searchIconSmall.withRenderingMode(.alwaysTemplate)
        config.imagePlacement = .leading
        config.imagePadding = 12

        configuration = config
        contentHorizontalAlignment = .leading

        configButton.tintColor = .foreground.withAlphaComponent(0.7)

        updateTitle()
    }

    private func updateTitle() {
        guard var config = configuration else { return }
        var attr = AttributedString(placeholder)
        attr.font = .appFont(withSize: 15, weight: .regular)
        config.attributedTitle = attr
        configuration = config
    }
}

protocol SearchBarButtonController: UIViewController {
    var searchBarButton: SearchBarButton { get }
}

extension SearchBarButtonController {
    func setupSearchBarActions() {
        searchBarButton.onTap = { [weak self] in
            guard let self else { return }
            SearchViewController.present(from: self)
        }
        searchBarButton.onConfigTap = { [weak self] in
            self?.present(AdvancedSearchController(manager: AdvancedSearchManager()), animated: true)
        }
    }
}
