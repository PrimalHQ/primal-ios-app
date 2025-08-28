//
//  UIImage+Extra.swift
//  Primal
//
//  Created by Pavle D Stevanović on 25.8.23..
//

import UIKit
import QRCode

extension CIImage {
    var image: UIImage { .init(ciImage: self) }
}

extension UIImage {
    static func createWhiteTransparentQRCode(_ string: String, dimension: Int, logo: UIImage? = nil) -> UIImage? {
        let doc = QRCode.Document(utf8String: string, errorCorrection: logo != nil ? .quantize : .default)
        doc.design.backgroundColor(UIColor.clear.cgColor)
        doc.design.shape.eye = QRCode.EyeShape.RoundedRect()
        doc.design.shape.onPixels = QRCode.PixelShape.RoundedPath(cornerRadiusFraction: 1)
        doc.design.style.onPixels = QRCode.FillStyle.Solid(UIColor.white.cgColor)
        
        if let image = logo?.cgImage {
            doc.logoTemplate = QRCode.LogoTemplate.CircleCenter(image: image, inset: 15)
        }
        
        return doc.uiImage(dimension: dimension, scale: 3)
    }
    
    static func createQRCode(_ string: String, dimension: Int, logo: UIImage? = nil) -> UIImage? {
        let doc = QRCode.Document(utf8String: string, errorCorrection: logo != nil ? .quantize : .default)
        doc.design.backgroundColor(UIColor.white.cgColor)
        doc.design.shape.eye = QRCode.EyeShape.RoundedRect()
        doc.design.shape.onPixels = QRCode.PixelShape.RoundedPath(cornerRadiusFraction: 1)
        doc.design.style.onPixels = QRCode.FillStyle.Solid(UIColor.black.cgColor)
        
        if let image = logo?.cgImage {
            doc.logoTemplate = QRCode.LogoTemplate.CircleCenter(image: image, inset: 15)
        }
        
        return doc.uiImage(dimension: dimension, scale: 3)
    }
    
    static func concatenateImagesVertically(images: [UIImage], background: UIColor) -> UIImage? {
        guard !images.isEmpty else { return nil }

        // Calculate total size
        let totalWidth = images.map { $0.size.width }.max() ?? 0
        let totalHeight = images.reduce(0) { $0 + $1.size.height }
        let size = CGSize(width: totalWidth, height: totalHeight)
        // Create graphics context
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        background.setFill()
        UIRectFill(.init(origin: .zero, size: size))
        
        var currentY: CGFloat = 0
        for image in images {
            let xOffset = (totalWidth - image.size.width) / 2
            image.draw(at: CGPoint(x: xOffset, y: currentY))
            currentY += image.size.height
        }

        // Capture final image
        let concatenatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return concatenatedImage
    }
    
    func trimBottomPixels(pixelsToTrim: CGFloat) -> UIImage {
        guard size.height > pixelsToTrim / scale else { return self }
        
        guard
            let cgImage,
            let newCGImage = cgImage.cropping(to: CGRect(
                x: 0,
                y: 0,
                width: CGFloat(cgImage.width),
                height: CGFloat(cgImage.height) - pixelsToTrim
            ))
        else { return self }

        return UIImage(cgImage: newCGImage, scale: scale, orientation: imageOrientation)
    }

    func detectQRCode() -> String? {
        guard let ciImage = CIImage.init(image: self) else { return nil }
        
        var options: [String: Any] = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        
        let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: CIContext(), options: options)
        if ciImage.properties.keys.contains((kCGImagePropertyOrientation as String)){
            options = [CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
        } else {
            options = [CIDetectorImageOrientation: 1]
        }
        
        let features = qrDetector?.features(in: ciImage, options: options) ?? []
        
        for case let feature as CIQRCodeFeature in features {
            if let text = feature.messageString {
                return text
            }
        }

        return nil
    }
    
    func withAlpha(alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPointZero, blendMode: .normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
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
    
    static var nonZapPaymentDynamic: UIImage {
        nonZapPayment.withTintColor(.accent, renderingMode: .alwaysOriginal)
    }
    
    func overlayed(with overlay: UIImage, at position: CGPoint? = nil) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)

        // Draw base image
        self.draw(in: CGRect(origin: .zero, size: self.size))

        // Calculate overlay position (center if not provided)
        let pos: CGPoint
        if let position = position {
            pos = position
        } else {
            pos = CGPoint(
                x: (self.size.width - overlay.size.width) / 2,
                y: (self.size.height - overlay.size.height) / 2
            )
        }

        // Draw overlay
        overlay.draw(in: CGRect(origin: pos, size: overlay.size))

        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}

