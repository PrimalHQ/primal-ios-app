//
//  UIImage+Extra.swift
//  Primal
//
//  Created by Pavle D Stevanović on 25.8.23..
//

import UIKit

extension UIImage {
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
}

