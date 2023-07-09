//
//  ImagePickerManager.swift
//  Primal
//
//  Created by Pavle D Stevanović on 6.7.23..
//

import UIKit

protocol ImagePickerManagerProtocol: UIViewController {
    
}

final class ImagePickerManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var picker = UIImagePickerController()
    
    weak var viewController: UIViewController?
    var pickImageCallback: (UIImage) -> () = { _ in }
    
    var strongSelf: ImagePickerManager?
    
    @discardableResult
    init(_ vc: UIViewController, _ callback: @escaping (UIImage) -> ()) {
        viewController = vc
        super.init()
        
        picker.delegate = self
        pickImageCallback = callback
        
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
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        pickImageCallback(image)
    }
}
