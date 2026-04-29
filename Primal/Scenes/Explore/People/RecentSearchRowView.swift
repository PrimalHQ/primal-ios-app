//
//  RecentSearchRowView.swift
//  Primal
//
//  Created by Pavle Stevanović on 29.4.26..
//

import UIKit

final class RecentSearchRowView: UIView, Themeable {
    let termLabel = UILabel()
    let arrowIcon = UIImageView(image: UIImage(named: "recentSearchArrow"))
    let border = UIView()

    var onTap: (() -> Void)?

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setSearch(_ text: String) { termLabel.text = text }

    func updateTheme() {
        termLabel.textColor = .foreground
        arrowIcon.tintColor = .accent
        border.backgroundColor = .background3
        backgroundColor = .background
    }
}

private extension RecentSearchRowView {
    func setup() {
        termLabel.font = .appFont(withSize: 16, weight: .regular)

        arrowIcon.contentMode = .center
        arrowIcon.constrainToSize(20)

        let stack = UIStackView(arrangedSubviews: [termLabel, UIView(), arrowIcon])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12

        addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .vertical, padding: 16)

        addSubview(border)
        border.pinToSuperview(edges: [.horizontal, .bottom]).constrainToSize(height: 1)

        updateTheme()

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }

    @objc func handleTap() { onTap?() }
}
