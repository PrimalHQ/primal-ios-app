//
//  NotificationsTabIconComposer.swift
//  Primal
//

import UIKit

enum NotificationsTabIconComposer {
    static let iconSize: CGFloat = {
        switch ChromeSize.current {
        case .small:    return 24
        case .regular:  return 28
        case .medium:   return 28
        case .large:    return 30
        }
    }()

    static let dotSize: CGFloat = 7 * iconSize / 24
    static let dotTopInset: CGFloat = 2 * iconSize / 24
    static let dotTrailingInset: CGFloat = 1.3 * iconSize / 24

    @available(iOS 26.0, *)
    static let nativeTabBarImageYOffset: CGFloat = {
        switch ChromeSize.current {
        case .small:    return 5
        case .large:    return 1
        default:        return 2
        }
    }()

    static func composedIcon(tint: UIColor, forNativeBar: Bool) -> UIImage? {
        guard let base = UIImage(named: "tabIcon2-notificationsCutout") else { return nil }
        let size = iconSize
        let scaled = base.scalePreservingAspectRatio(size: size).withRenderingMode(.alwaysTemplate)

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        let composed = renderer.image { ctx in
            let rect = CGRect(x: 0, y: 0, width: size, height: size)
            scaled.draw(in: rect)
            ctx.cgContext.setBlendMode(.sourceIn)
            tint.setFill()
            ctx.cgContext.fill(rect)
            ctx.cgContext.setBlendMode(.normal)

            let dotRect = CGRect(
                x: size - dotTrailingInset - dotSize,
                y: dotTopInset,
                width: dotSize,
                height: dotSize
            )
            UIColor.accent.setFill()
            ctx.cgContext.fillEllipse(in: dotRect)
        }.withRenderingMode(.alwaysOriginal)

        guard forNativeBar else { return composed }
        if #available(iOS 26.0, *) {
            return composed.withAlignmentRectInsets(.init(
                top: nativeTabBarImageYOffset,
                left: 0,
                bottom: -nativeTabBarImageYOffset,
                right: 0))
        }
        return composed
    }
}
