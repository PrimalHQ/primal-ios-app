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
        let fontSize: CGFloat
        switch ChromeSize.current {
        case .small:
            config.imagePadding = 6
            config.contentInsets = .init(top: 8, leading: 16, bottom: 8, trailing: 16)
            fontSize = 13
        case .regular:
            config.imagePadding = 6
            config.contentInsets = .init(top: 8, leading: 16, bottom: 8, trailing: 16)
            fontSize = 13
        case .medium:
            config.imagePadding = 6
            config.contentInsets = .init(top: 8, leading: 18, bottom: 8, trailing: 20)
            fontSize = 14
        case .large:
            config.imagePadding = 8
            config.contentInsets = .init(top: 9, leading: 18, bottom: 9, trailing: 20)
            fontSize = 15
        }
        
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.appFont(withSize: fontSize, weight: .regular)
            return outgoing
        }
        
        configuration = config
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(text: String, icon: UIImage?) {
        let imageSize: CGFloat
        switch ChromeSize.current {
        case .small, .regular:
            imageSize = 16
        case .medium, .large:
            imageSize = 18
        }
        
        configuration?.title = text
        configuration?.image = icon?.scalePreservingAspectRatio(size: imageSize).withRenderingMode(.alwaysTemplate)
    }
}
