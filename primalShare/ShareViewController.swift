//
//  ShareViewController.swift
//  primalShare
//
//  Created by Pavle Stevanović on 10.3.25..
//

import MobileCoreServices
import UIKit
import Social
import UniformTypeIdentifiers

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }
    
    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    

    override func didSelectPost() {
        // Ensure you have at least one extension item
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let attachments = extensionItem.attachments else {
            
            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
            
            return
        }
        
        // Array to hold unique file names of saved images
        var savedImageNames: [String] = []
        
        // Use a dispatch group to know when all images have been processed
        let dispatchGroup = DispatchGroup()
        
        for provider in attachments {
            if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                dispatchGroup.enter()
                provider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { (item, error) in
                    defer { dispatchGroup.leave() }
                    
                    if let imageURL = item as? URL {
                        do {
                            let imageData = try Data(contentsOf: imageURL)
                            let fileManager = FileManager.default
                            
                            // Access the shared container
                            if let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.primal") {
                                // Generate a unique file name for each image
                                let uniqueFileName = "sharedImage_\(UUID().uuidString).jpg"
                                let destinationURL = containerURL.appendingPathComponent(uniqueFileName)
                                
                                // Save the image data to the shared container
                                try imageData.write(to: destinationURL)
                                
                                // Collect the file name so your main app knows which files to load
                                savedImageNames.append(uniqueFileName)
                            }
                        } catch {
                            print("Error saving image: \(error)")
                        }
                    }
                }
            }
            
            if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                dispatchGroup.enter()
                provider.loadItem(forTypeIdentifier: UTType.movie.identifier, options: nil) { (item, error) in
                    defer { dispatchGroup.leave() }
                    
                    if let videoURL = item as? URL {
                        do {
                            let videoData = try Data(contentsOf: videoURL)
                            let fileManager = FileManager.default
                            
                            // Access the shared container
                            if let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.primal") {
                                // Generate a unique file name for each video
                                let uniqueFileName = "sharedVideo_\(UUID().uuidString).mp4"
                                let destinationURL = containerURL.appendingPathComponent(uniqueFileName)
                                
                                // Save the video data to the shared container
                                try videoData.write(to: destinationURL)
                                
                                // Optionally, collect the file name so your main app knows which files to load
                                savedImageNames.append(uniqueFileName)
                            }
                        } catch {
                            print("Error saving video: \(error)")
                        }
                    }
                }
            }

        }
        
        // Once all images are processed, store the file names and open the main app
        dispatchGroup.notify(queue: .main) {
            // Optionally, store the image file names in UserDefaults using the shared App Group
            if let userDefaults = UserDefaults(suiteName: "group.primal") {
                userDefaults.set(savedImageNames, forKey: "sharedImageNames")
                userDefaults.synchronize()
            }
            
            let text = self.contentText?.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
            // Open your main app via your custom URL scheme
            if let urlScheme = URL(string: "primal://sharedImages?text=\(text)") {
                self.openURL(urlScheme)
            }
            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        }
    }
    
    @objc @discardableResult private func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                if #available(iOS 18.0, *) {
                    application.open(url, options: [:], completionHandler: nil)
                    return true
                } else {
                    return application.perform(#selector(openURL(_:)), with: url) != nil
                }
            }
            responder = responder?.next
        }
        return false
    }

}
