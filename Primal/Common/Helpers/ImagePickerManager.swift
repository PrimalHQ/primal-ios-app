//
//  ImagePickerManager.swift
//  Primal
//
//  Created by Pavle D Stevanović on 6.7.23..
//

import UIKit
import AVFoundation
import Photos
import PhotosUI
import FLAnimatedImage
import Combine

struct GalleryVideo {
    var thumbnail: UIImage
    var url: URL
}

enum ImageType {
    case png
    case gif(Data)
    case jpeg
}

typealias GalleryImage = (UIImage, ImageType)

enum ImagePickerResult {
    case image(GalleryImage)
    case video(GalleryVideo)
    
    var image: GalleryImage? {
        switch self {
        case .image(let image): return image
        case .video:            return nil
        }
    }
    
    var thumbnailImage: UIImage {
        switch self {
        case .image(let image): return image.0
        case .video(let video): return video.thumbnail
        }
    }
    
    var animatedImage: FLAnimatedImage? {
        guard let image, case .gif(let data) = image.1 else { return nil }
        return FLAnimatedImage(gifData: data)
    }
}

final class ImagePickerManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var picker = UIImagePickerController()
    
    weak var viewController: UIViewController?
    let pickImageCallback: (ImagePickerResult) -> ()
    
    var strongSelf: ImagePickerManager?
    
    enum Mode {
        case gallery, camera, dialog
    }
    
    @discardableResult
    init(_ vc: UIViewController, mode: Mode = .dialog, allowVideo: Bool = false,  _ callback: @escaping (ImagePickerResult) -> ()) {
        viewController = vc
        pickImageCallback = callback
        super.init()
        
        if allowVideo {
            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) ?? picker.mediaTypes
        }
        picker.delegate = self
        
        switch mode {
        case .camera:
            openCamera()
        case .gallery:
            openGallery()
        case .dialog:
            let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
            alert.popoverPresentationController?.sourceView = vc.view
            alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
                self.openCamera()
            })
            alert.addAction(UIAlertAction(title: "Gallery", style: .default) { _ in
                self.openGallery()
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            viewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            strongSelf = self
            viewController?.present(picker, animated: true, completion: nil)
        } else {
            let alertController: UIAlertController = {
                let controller = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default)
                controller.addAction(action)
                return controller
            }()
            viewController?.present(alertController, animated: true)
        }
    }
    
    func openGallery() {
        strongSelf = self
        picker.sourceType = .photoLibrary
        viewController?.present(picker, animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        strongSelf = nil
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        strongSelf = nil
        
        if let image = info[.originalImage] as? UIImage {
            var isPNG = false
            if let assetPath = info[.imageURL] as? NSURL, assetPath.absoluteString?.uppercased().hasSuffix("PNG") == true {
                isPNG = true
            }

            pickImageCallback(.image((image.updateImageOrientationUp(), isPNG ? .png : .jpeg)))
            return
        }
        
        guard
            let videoURL = info[.mediaURL] as? NSURL,
            let absolute = videoURL.absoluteURL,
            let thumbnail = getThumbnailImage(forUrl: absolute)
        else { return }
        
        pickImageCallback(.video(.init(thumbnail: thumbnail, url: absolute)))
    }
    
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }

        return nil
    }
}

private extension UIImage {
    func updateImageOrientationUp() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        return normalizedImage
    }
}
