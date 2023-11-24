//
//  UIImage+Extra.swift
//  Primal
//
//  Created by Pavle D Stevanović on 25.8.23..
//

import UIKit

extension CIImage {
    var image: UIImage { .init(ciImage: self) }
}

extension UIImage {
    static func createQRCode(_ string: String) -> UIImage? {
        guard
            let data = string.data(using: .isoLatin1),
            let outputImage = CIFilter(name: "CIQRCodeGenerator",
                              parameters: ["inputMessage": data, "inputCorrectionLevel": "M"])?.outputImage
        else { return nil }
        let size = outputImage.extent.integral
        let output = CGSize(width: 400, height: 400)
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        return UIGraphicsImageRenderer(size: output, format: format).image { _ in
            outputImage
                .transformed(by: .init(scaleX: output.width/size.width, y: output.height/size.height))
                .image
                .draw(in: .init(origin: .zero, size: output))
        }
    }
    
    func maskWhiteColor(color: UIColor) -> UIImage? {
        let maskingColors: [CGFloat] = [1, 255, 1, 255, 1, 255]
//        let maskingColors: [CGFloat] = [0, 254, 0, 254, 0, 254]
        let bounds = CGRect(origin: .zero, size: size)

        let maskImage = cgImage!
        var returnImage: UIImage?

        // make sure image has no alpha channel
        let rFormat = UIGraphicsImageRendererFormat()
        rFormat.opaque = true
        let renderer = UIGraphicsImageRenderer(size: size, format: rFormat)
        let noAlphaImage = renderer.image {
            (context) in
            self.draw(at: .zero)
        }

        let noAlphaCGRef = noAlphaImage.cgImage

        if let imgRefCopy = noAlphaCGRef?.copy(maskingColorComponents: maskingColors) {

            let rFormat = UIGraphicsImageRendererFormat()
            rFormat.opaque = false
            let renderer = UIGraphicsImageRenderer(size: size, format: rFormat)
            returnImage = renderer.image {
                (context) in
                context.cgContext.clip(to: bounds, mask: maskImage)
                context.cgContext.setFillColor(color.cgColor)
                context.cgContext.fill(bounds)
                context.cgContext.draw(imgRefCopy, in: bounds)
            }

        }
        return returnImage
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
}

