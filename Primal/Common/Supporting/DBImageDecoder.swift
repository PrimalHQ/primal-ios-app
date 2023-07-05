//
//  DBImageDecoder.swift
//  Test
//
//  Created by Varun Tomar on 03/08/21.
//
import ImageIO
import Foundation
import UIKit

final class DBImageDecoder {

    struct DecodingOptions {

        enum Mode {
            case synchronous
            case asynchronous
        }

        static var `default`: DecodingOptions {
            DecodingOptions(mode: .asynchronous, sizeForDrawing: nil)
        }

        var mode: Mode
        var sizeForDrawing: CGSize?
    }

    enum DownSamplingLevel: Int {
        case level0 = 1
        case level1 = 2
        case level2 = 4
        case level3 = 8
        public static var `default`: DownSamplingLevel {
            .level0
        }
    }

    // MARK: - Public
    init() {
        imageSource = CGImageSourceCreateIncremental(nil)
    }

    private(set) var isAllDataReceived: Bool = false

    func setData(_ data: Data, allDataReceived: Bool) {
        assert(!isAllDataReceived)

        isAllDataReceived = allDataReceived
        CGImageSourceUpdateData(imageSource, data as CFData, allDataReceived)
    }

    var frameCount: Int {
        CGImageSourceGetCount(imageSource)
    }

    func frameDuration(at index: Int) -> TimeInterval? {
        guard let frameProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, imageSourceOptions()) as? [CFString: Any] else {
            return nil
        }

        var animationProperties = DBImageDecoder.animationProperties(from: frameProperties)

        if animationProperties == nil {
            if let properties = CGImageSourceCopyProperties(imageSource, imageSourceOptions()) as? [CFString: Any] {
                animationProperties = DBImageDecoder.animationHEICSProperties(from: properties, at: index)
            }
        }

        let duration: TimeInterval

        // Use the unclamped frame delay if it exists. Otherwise use the clamped frame delay.
        if let unclampedDelay = animationProperties?["UnclampedDelayTime" as CFString] as? TimeInterval {
            duration = unclampedDelay
        }
        else if let delay = animationProperties?["DelayTime" as CFString] as? TimeInterval {
            duration = delay
        }
        else {
            duration = 0.0
        }

        // We are not allowing frame duration faster than 10ms here but we can have it as required.
        return duration < 0.011 ? 0.1 : duration
    }

    func frameSize(at index: Int, downsamplingLevel: DownSamplingLevel = .default) -> CGSize? {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, imageSourceOptions(with: downsamplingLevel)) as? [CFString: Any] else {
            return nil
        }

        guard let width = properties[kCGImagePropertyPixelWidth] as? Int, let height = properties[kCGImagePropertyPixelHeight] as? Int else {
            return nil
        }

        return CGSize(width: width, height: height)
    }

    func createFrameImage(at index: Int, downsamplingLevel: DownSamplingLevel = .default, decodingOptions: DecodingOptions = .default) -> CGImage? {

        guard index < frameCount else {
            return nil
        }

        let image: CGImage?
        let options: CFDictionary

        switch decodingOptions.mode {
            case .asynchronous:
                // No need to consider the down sampling when comparing the image native size with sizeForDrawing.
                guard var size = frameSize(at: index) else {
                    return nil
                }

                if let sizeForDrawing = decodingOptions.sizeForDrawing {
                    // Choose the smaller one.
                    if sizeForDrawing.width * sizeForDrawing.height < size.width * size.height {
                        size = sizeForDrawing
                    }
                }

                options = imageSourceAsyncOptions(sizeForDrawing: size, donwsamplingLevel: downsamplingLevel)
                image = CGImageSourceCreateThumbnailAtIndex(imageSource, index, options)

            case .synchronous:
                options = imageSourceOptions(with: downsamplingLevel)
                image = CGImageSourceCreateImageAtIndex(imageSource, index, options)
        }

        return image
    }

    // MARK: - Private
    private static let imageSourceOptions: [CFString: Any] = [
        kCGImageSourceShouldCache: true
    ]

    private static let imageSourceAsyncOptions: [CFString: Any] = [
        kCGImageSourceShouldCacheImmediately: true,
        kCGImageSourceCreateThumbnailFromImageAlways: true
    ]

    private let imageSource: CGImageSource

    private func imageSourceOptions(with downsamplingLevel: DownSamplingLevel = .default) -> CFDictionary {
        var options = DBImageDecoder.imageSourceOptions

        switch downsamplingLevel {
            case .default:
                return options as CFDictionary
            default:
                options[kCGImageSourceSubsampleFactor] = downsamplingLevel
                return options as CFDictionary
        }
    }

    private func imageSourceAsyncOptions(sizeForDrawing: CGSize, donwsamplingLevel: DownSamplingLevel = .default) -> CFDictionary {
        var options = DBImageDecoder.imageSourceAsyncOptions

        options[kCGImageSourceThumbnailMaxPixelSize] = Int(max(sizeForDrawing.width, sizeForDrawing.height))

        switch donwsamplingLevel {
            case .default:
                return options as CFDictionary
            default:
                options[kCGImageSourceSubsampleFactor] = donwsamplingLevel
                return options as CFDictionary
        }
    }
}


extension DBImageDecoder {

    fileprivate static func animationProperties(from properties: [CFString: Any]) -> [CFString: Any]? {
        if let gifProperties = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any] {
            return gifProperties
        }

        if let pngProperties = properties[kCGImagePropertyPNGDictionary] as? [CFString: Any] {
            return pngProperties
        }

        if #available(iOS 13.0, *) {
            if let heicsProperties = properties[kCGImagePropertyHEICSDictionary] as? [CFString: Any] {
                return heicsProperties
            }
        }

        return nil
    }

    fileprivate static func animationHEICSProperties(from properties: [CFString: Any], at index: Int) -> [CFString: Any]? {
        if #available(iOS 13.0, *) {
            guard let heicsProperties = properties[kCGImagePropertyHEICSDictionary] as? [CFString: Any] else {
                return nil
            }

            guard let array = heicsProperties["FrameInfo" as CFString] as? [[CFString: Any]], array.count > index else {
                return nil
            }

            return array[index]
        }

        return nil
    }
}

extension DBImageDecoder {

    var uiImage: UIImage? {
        switch frameCount {
            case 0:
                return nil
            case 1:
                return staticUIImage
            default:
                return animatedUIImage
        }
    }

    var animatedUIImage: UIImage? {
        guard frameCount > 1 else {
            return nil
        }

        var duration: TimeInterval = 0.0
        var images: [UIImage] = []

        for i in 0..<frameCount {
            guard let image = createFrameUIImage(at: i) else {
                continue
            }

            images.append(image)
            duration += frameDuration(at: i) ?? 0.0
        }

        return UIImage.animatedImage(with: images, duration: duration)
    }

    // If we need to have only static image, no matter has single or multiple frames.
    var staticUIImage: UIImage? {
        frameCount > 0 ? createFrameUIImage(at: 0) : nil
    }

    private func createFrameUIImage(at index: Int, downsamplingLevel: DownSamplingLevel = .default, decodingOptions: DecodingOptions = .default) -> UIImage? {
        guard let cgImage = createFrameImage(at: index, downsamplingLevel: downsamplingLevel, decodingOptions: decodingOptions) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}
