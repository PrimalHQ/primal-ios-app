//
//  TextViewManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 19.9.23..
//

import Combine
import Foundation
import UIKit

struct PostingImage {
    let id = UUID().uuidString
    var image: UIImage
    var isPNG: Bool
    var state = State.uploading
    
    enum State {
        case uploaded(String)
        case failed
        case uploading
    }
}

class TextViewManager: NSObject, UITextViewDelegate {
    @Published var isEditing = false
    @Published var isEmpty = true
    
    @Published var images: [PostingImage] = []
    
    var didChangeEvent = PassthroughSubject<UITextView, Never>()
    
    let textView: UITextView
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(textView: UITextView) {
        self.textView = textView
    }
    
    var postingText: String {
        var text = textView.text ?? ""
        
        for image in images {
            guard case .uploaded(let url) = image.state else { continue }
            text += "\n" + url
        }
        
        return text
    }
    
    var isUploadingImages: Bool {
        for image in images {
            if case .uploading = image.state {
                return true
            }
        }
        return false
    }
    
    var didUploadFail: Bool {
        for image in images {
            if case .failed = image.state {
                return true
            }
        }
        return false
    }
    
    func processSelectedImage(_ image: UIImage, isPNG: Bool) {
        let postingImage = PostingImage(image: image, isPNG: isPNG)
        images.append(postingImage)
        uploadSelectedImage(postingImage.id)
    }
    
    func uploadSelectedImage(_ id: String) {
        guard let postingIndex = images.firstIndex(where: { $0.id == id }) else { return }
        
        let postingImage = images[postingIndex]
        
        if case .uploaded = postingImage.state { return }
        
        images[postingIndex].state = .uploading
        
        UploadPhotoRequest(image: postingImage.image, isPNG: postingImage.isPNG).publisher().receive(on: DispatchQueue.main).sink(receiveCompletion: { [weak self] in
            guard case .failure(let error) = $0, let index = self?.images.firstIndex(where: { $0.id == postingImage.id }) else { return }
            
            self?.images[index].state = .failed
            print(error)
        }) { [weak self] urlString in
            guard let index = self?.images.firstIndex(where: { $0.id == postingImage.id }) else { return }
            
            self?.images[index].state = .uploaded(urlString)
        }
        .store(in: &self.cancellables)
    }
    
    func restartFailedUploads() {
        for image in images {
            if case .failed = image.state {
                uploadSelectedImage(image.id)
            }
        }
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        isEditing = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        isEditing = false
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textView.invalidateIntrinsicContentSize() // Necessary for self sizing text field
        didChangeEvent.send(textView)
        
        isEmpty = postingText.isEmpty
    }
}

extension TextViewManager: PostingImageCollectionViewDelegate {
    func didTapImage(resource: PostingImage) {
        
    }
    
    func didTapDeleteImage(resource: PostingImage) {
        images = images.filter { $0.id != resource.id }
    }
}
