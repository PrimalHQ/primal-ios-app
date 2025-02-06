//
//  LegendTheme.swift
//  Primal
//
//  Created by Pavle Stevanović on 18.11.24..
//

import UIKit

enum LegendTheme: String, CaseIterable {
    case gold, aqua, silver, purple, purplehaze, teal, brown, blue, sunfire
}

extension LegendTheme {
    var startPoint: CGPoint {
        switch self {
        case .gold, .aqua, .silver:
            return .init(x: 0.5, y: 0)
        case .purple, .purplehaze, .teal, .brown, .blue, .sunfire:
            return .zero
        }
    }
    
    var endPoint: CGPoint {
        switch self {
        case .gold, .aqua, .silver:
            return .init(x: 0.5, y: 1)
        case .purple, .purplehaze, .teal, .brown, .blue, .sunfire:
            return .init(x: 1, y: 1)
        }
    }
    
    var colors: [UIColor] {
        switch self {
        case .gold:
            return [.init(rgb: 0xFFB700), .init(rgb: 0xFFB700), .init(rgb: 0xCB721E), .init(rgb: 0xFFAA00)]
        case .aqua:
            return [.init(rgb: 0x6BCCFF), .init(rgb: 0x6BCCFF), .init(rgb: 0x247FFF), .init(rgb: 0x6BCCFF)]
        case .silver:
            return [.init(rgb: 0xCCCCCC), .init(rgb: 0xCCCCCC), .init(rgb: 0x777777), .init(rgb: 0xCCCCCC)]
        case .purple:
            return [.init(rgb: 0xB300D3), .init(rgb: 0x4800FF)]
        case .purplehaze:
            return [.init(rgb: 0xFB00C4), .init(rgb: 0x04F7FC)]
        case .teal:
            return [.init(rgb: 0x40FCFF), .init(rgb: 0x007D9F)]
        case .brown:
            return [.init(rgb: 0xBB9971), .init(rgb: 0x5C3B22)]
        case .blue:
            return [.init(rgb: 0x01E0FF), .init(rgb: 0x0190F8), .init(rgb: 0x2555EE)]
        case .sunfire:
            return [.init(rgb: 0xFFA722), .init(rgb: 0xFA3C3C), .init(rgb: 0xF00492)]
        }
    }
    
    var locations: [Double] {
        switch self {
        case .gold, .aqua, .silver:
            return [0, 0.49, 0.50, 1]
        case .purple, .purplehaze:
            return [0, 1]
        case  .teal, .brown:
            return [0.2, 0.75]
        case .blue, .sunfire:
            return [0.05, 0.35, 0.75]
        }
    }
    
    // When capsule button has themed background color, use this to style button text
    var blackButtonText: Bool {
        switch self {
        case .purple, .purplehaze, .blue, .sunfire:
            return false
        default:
            return true
        }
    }
    
    var cgColors: [CGColor] { colors.map { $0.cgColor } }
    
    var nsNumberLocations: [NSNumber] { locations.map { NSNumber(floatLiteral: $0) } }
    
    var checkmarkBackgroundImage: UIImage? {
        UIImage(named: "verifiedBackground")?.applyGradientTint(colors: colors, locations: nsNumberLocations, startPoint: startPoint, endPoint: endPoint)
    }
    
    var transparentCheckmarkImage: UIImage? {
        UIImage(named: "purpleVerified")?.applyGradientTint(colors: colors, locations: nsNumberLocations, startPoint: startPoint, endPoint: endPoint)
    }
}

extension GradientView {
    func setLegendGradient(_ theme: LegendTheme) {
        colors = theme.colors
        gradientLayer.startPoint = theme.startPoint
        gradientLayer.endPoint = theme.endPoint
        gradientLayer.locations = theme.nsNumberLocations
    }
}


extension UIImage {
    func applyGradientTint(colors: [UIColor], locations: [NSNumber]? = nil, startPoint: CGPoint, endPoint: CGPoint) -> UIImage? {
        let size = size
        let rect = CGRect(origin: .zero, size: size)
        
        // Create gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = locations
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.frame = rect
        
        // Render the gradient into a UIImage
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Clip the context to the image's shape
        draw(in: rect)
        context.clip(to: rect, mask: cgImage!)
        
        // Render the gradient into the context
        gradientLayer.render(in: context)
        
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return tintedImage
    }
}
