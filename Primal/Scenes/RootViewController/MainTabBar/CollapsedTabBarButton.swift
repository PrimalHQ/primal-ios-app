//
//  CollapsedTabBarButton.swift
//  Primal
//
//  Created by Pavle D Stevanović on 14.4.26..
//

import UIKit

@available(iOS 26.0, *)
final class CollapsedTabBarButton: UIButton {
    init() {
        super.init(frame: .zero)

        var config = UIButton.Configuration.glass()
        config.cornerStyle = .capsule
        config.imagePadding = 8
        config.contentInsets = .init(top: 12, leading: 20, bottom: 12, trailing: 24)
        configuration = config
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(text: String, icon: UIImage?) {
        configuration?.title = text
        configuration?.image = icon?.withRenderingMode(.alwaysTemplate)
    }
}
