//
//  UIImage+Extra.swift
//  Primal
//
//  Created by Pavle D Stevanović on 25.8.23..
//

import UIKit

extension UIImage {
    static func createQRCode(_ string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        
        filter.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 3, y: 3)

        guard let output = filter.outputImage?.transformed(by: transform) else { return nil }
        
        return UIImage(ciImage: output)
    }
    
    func scalePreservingAspectRatio(size: CGFloat) -> UIImage {
        scalePreservingAspectRatio(targetSize: .init(width: size, height: size))
    }
    
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
    
    func withGradient(from colors: [UIColor], startPoint: CGPoint = .zero, endPoint: CGPoint = .init(x: 1, y: 1)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1, y: -1)

        context.setBlendMode(.normal)
        let rect = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)

        // Create gradient
        let colors = (colors.map { $0.cgColor }) as CFArray
        let space = CGColorSpaceCreateDeviceRGB()
        
        guard let gradient = CGGradient(colorsSpace: space, colors: colors, locations: nil), let cgImage else { return self }

        // Apply gradient
        context.clip(to: rect, mask: cgImage)
        context.drawLinearGradient(
            gradient,
            start: CGPoint(x: size.width - startPoint.x * size.width, y: startPoint.y * size.height),
            end: CGPoint(x: size.width - endPoint.x * size.width, y: endPoint.y * size.height),
            options: .drawsAfterEndLocation
        )
        
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return gradientImage ?? self
    }
}

