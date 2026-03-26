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

enum ImageType {
    case png
    case gif(Data)
    case jpeg
}

enum MediaPickerResultThumbnailSource {
    case animated(FLAnimatedImage)
    case thumbnail(UIImage)
    case remote(URL)
}

protocol ImagePickerResult {  // TODO: Rename MediaPickerResult
    var thumbnailSource: MediaPickerResultThumbnailSource? { get }
    func metaTagsWithURL(uploadURL: String) async -> [String]
    func uploadURL() async throws -> URL
}

extension ImagePickerResult {
    var thumbnailImage: UIImage? {
        guard case .thumbnail(let image) = thumbnailSource else { return nil }
        return image
    }
}

class ImageMediaPickerResult: ImagePickerResult {
    let image: UIImage
    let type: ImageType
    
    init(image: UIImage, type: ImageType) {
        self.image = image
        self.type = type
    }
    
    func metaTagsWithURL(uploadURL: String) async -> [String] {
        let tagString = {
            switch self.type {
            case .jpeg:
                return "image/jpeg"
            case .png:
                return "image/png"
            case .gif:
                return "image/gif"
            }
        }
        return [
            "imeta",
            "url \(uploadURL)",
            "m \(type)",
            "dim \(image.size.width)x\(image.size.height)"
        ]
    }
    
    var thumbnailSource: MediaPickerResultThumbnailSource? {
        switch type {
        case .gif(let data):
            return .animated(FLAnimatedImage(gifData: data))
        default:
            return .thumbnail(image)
        }
    }
    func uploadURL() async throws -> URL {
        let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        switch type {
        case .png:
            guard let data = image.pngData() else { throw UploadError.unableToProcess }
            
            try data.write(to: tmpURL)
            return tmpURL
        case .jpeg:
            guard let data = image.jpegData(compressionQuality: 0.9) else { throw UploadError.unableToProcess }
            try data.write(to: tmpURL)
            return tmpURL
        case .gif(let data):
            try data.write(to: tmpURL)
            return tmpURL
        }
    }
}

class VideoMediaPickerResult: ImagePickerResult {
    let thumbnail: UIImage
    let url: URL
    
    init(thumbnail: UIImage, url: URL) {
        self.thumbnail = thumbnail
        self.url = url
    }
    
    func uploadURL() async throws -> URL { url }
    var thumbnailSource: MediaPickerResultThumbnailSource? { .thumbnail(thumbnail) }
    
    func metaTagsWithURL(uploadURL: String) async -> [String] {
        var info = [
            "imeta",
            "url \(uploadURL)"
        ]
        
        if let mimeType = mimeType(for: url) {
            info.append("m \(mimeType)")
        }

        if let dimensions = try? await getVideoDimensions(from: url) {
            info.append("dim \(dimensions.width)x\(dimensions.height)")
        }
        
        return info
    }
    
    func mimeType(for url: URL) -> String? {
        guard let utType = UTType(filenameExtension: url.pathExtension) else { return nil }
        return utType.preferredMIMEType
    }

    func getVideoDimensions(from url: URL) async throws -> CGSize {
        let asset = AVURLAsset(url: url)
        
        // Load the tracks asynchronously
        let tracks = try await asset.loadTracks(withMediaType: .video)
        guard let track = tracks.first else {
            throw NSError(domain: "VideoError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No video track found"])
        }
        
        // Load the natural size and preferred transform
        let (naturalSize, preferredTransform) = try await track.load(.naturalSize, .preferredTransform)
        
        // Apply transform to handle rotated videos (e.g., portrait recordings)
        let transformedSize = naturalSize.applying(preferredTransform)
        return CGSize(width: abs(transformedSize.width), height: abs(transformedSize.height))
    }
}

final class ImagePickerManager: NSObject {
    // For camera capture only – PHPicker doesn’t support capturing.
    var imagePicker = UIImagePickerController()
    
    weak var viewController: UIViewController?
    let pickImageCallback: (ImagePickerResult) -> Void
    let selectionLimit: Int
    
    // Hold a strong reference to self during the picker presentation.
    var strongSelf: ImagePickerManager?
    var cancellables: Set<AnyCancellable> = []
    
    enum Mode {
        case gallery, camera, dialog
    }
    
    @discardableResult
    init(_ vc: UIViewController, mode: Mode = .dialog, allowVideo: Bool = false, selectionLimit: Int = 1, _ callback: @escaping (ImagePickerResult) -> Void) {
        viewController = vc
        pickImageCallback = callback
        self.selectionLimit = selectionLimit
        super.init()
        
        // Configure UIImagePickerController for camera mode.
        imagePicker.delegate = self
        
        switch mode {
        case .camera:
            openCamera()
        case .gallery:
            openGallery(allowVideo: allowVideo)
        case .dialog:
            let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
            alert.popoverPresentationController?.sourceView = vc.view
            alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
                self.openCamera()
            })
            alert.addAction(UIAlertAction(title: "Gallery", style: .default) { _ in
                self.openGallery(allowVideo: allowVideo)
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            viewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            strongSelf = self
            viewController?.present(imagePicker, animated: true, completion: nil)
        } else {
            let alertController: UIAlertController = {
                let controller = UIAlertController(title: "Warning", message: "You don't have a camera", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default)
                controller.addAction(action)
                return controller
            }()
            viewController?.present(alertController, animated: true)
        }
    }
    
    func openGallery(allowVideo: Bool) {
        strongSelf = self
        
        var config = PHPickerConfiguration()
        config.selectionLimit = selectionLimit
        // If you allow video, set filter to .any, otherwise only images.
        config.filter = allowVideo ? PHPickerFilter.any(of: [.images, .videos]) : .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        viewController?.present(picker, animated: true, completion: nil)
    }
    
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        do {
            let cgImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print(error)
        }
        return nil
    }
}

extension ImagePickerManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - UIImagePickerController Delegate (Camera Mode)
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        strongSelf = nil
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        strongSelf = nil
        
        // Handle camera capture; for simplicity we assume image capture.
        if let image = info[.originalImage] as? UIImage {
            // When captured from camera, treat as JPEG.
            pickImageCallback(ImageMediaPickerResult(image: image.updateImageOrientationUp(), type: .jpeg))
        }
        
        // (Additional video capture from camera could be added similarly.)
    }
}

extension ImagePickerManager: PHPickerViewControllerDelegate {
    // MARK: - PHPicker Delegate (Gallery Mode)
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)

        guard !results.isEmpty else {
            strongSelf = nil
            return
        }

        for result in results {
            processPickerResult(result)
        }

        // Release extra retain; async closures capture self to stay alive
        strongSelf = nil
    }

    private func processPickerResult(_ result: PHPickerResult) {
        let itemProvider = result.itemProvider

        // Check for video first (if allowed).
        if itemProvider.hasItemConformingToTypeIdentifier("public.movie") {
            let progressAlert = UIAlertController(title: "Processing", message: "Operation in progress...\n\n", preferredStyle: .alert)

            let progress = itemProvider.loadFileRepresentation(forTypeIdentifier: "public.movie") { (url, error) in
                if let error = error {
                    print("Error loading video: \(error)")
                    return
                }
                guard var url = url else { return }

                do {
                    // Create a unique temporary file URL
                    let tempDirectory = FileManager.default.temporaryDirectory
                    let fileName = UUID().uuidString + "." + (url.pathExtension)
                    let tempURL = tempDirectory.appendingPathComponent(fileName)

                    // Copy the video file
                    try FileManager.default.copyItem(at: url, to: tempURL)
                    url = tempURL
                } catch {
                    print("Error copying video: \(error.localizedDescription)")
                }

                guard let thumbnail = self.getThumbnailImage(forUrl: url) else { return }

                DispatchQueue.main.async {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                        progressAlert.dismiss(animated: true)
                    }
                    self.pickImageCallback(VideoMediaPickerResult(thumbnail: thumbnail, url: url))
                }
            }

            // Add progress view
            let progressView = UIProgressView(progressViewStyle: .default)
            progressView.translatesAutoresizingMaskIntoConstraints = false
            progressView.progress = 0.0

            progressAlert.view?.addSubview(progressView)
            progressView
                .pinToSuperview(edges: .top, padding: 80)
                .pinToSuperview(edges: .horizontal, padding: 20)
                .constrainToSize(height: 8)

            // Add cancel action
            progressAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

            // Present
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                self.viewController?.present(progressAlert, animated: true, completion: nil)
            }

            Publishers.CombineLatest(
                progress.publisher(for: \.completedUnitCount),
                progress.publisher(for: \.totalUnitCount)
            )
            .receive(on: DispatchQueue.main)
            .sink { completed, total in
                progressView.progress = Float(completed) / Float(total)
            }
            .store(in: &cancellables)
            return
        }

        // Check for GIF. We use "public.gif" to identify GIF images.
        if itemProvider.hasItemConformingToTypeIdentifier(UTType.gif.identifier) {
            itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.gif.identifier) { (url, error) in
                if let error = error {
                    print("Error loading GIF: \(error)")
                    return
                }
                guard let url = url else { return }
                do {
                    let gifData = try Data(contentsOf: url)
                    // Load a UIImage for display purposes.
                    if let image = UIImage(data: gifData) {
                        DispatchQueue.main.async {
                            self.pickImageCallback(ImageMediaPickerResult(image: image, type: .gif(gifData)))
                        }
                    }
                } catch {
                    print("Error reading GIF data: \(error)")
                }
            }
            return
        }

        // Otherwise, handle standard images.
        if itemProvider.canLoadObject(ofClass: UIImage.self) {
            // Here we load the file representation so we can check the file type.
            itemProvider.loadFileRepresentation(forTypeIdentifier: "public.image") { (url, error) in
                if let error = error {
                    print("Error loading image file representation: \(error)")
                    return
                }
                guard let url = url else { return }
                let ext = url.pathExtension.lowercased()
                do {
                    let imageData = try Data(contentsOf: url)
                    if let image = UIImage(data: imageData) {
                        DispatchQueue.main.async {
                            if ext == "png" {
                                self.pickImageCallback(ImageMediaPickerResult(image: image, type: .png))
                            } else {
                                self.pickImageCallback(ImageMediaPickerResult(image: image.updateImageOrientationUp(), type: .jpeg))
                            }
                        }
                    }
                } catch {
                    print("Error reading image data: \(error)")
                }
            }
        }
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
