//
//  ScanAnythingQRController.swift
//  Primal
//
//  Created by Pavle Stevanović on 30. 12. 2025..
//

import AVKit
import Combine
import UIKit

final class ScanAnythingQRController: UIViewController, QRCaptureController, WalletSearchController {
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer { previewView.previewLayer }
    var qrCodeFrameView = UIView()
    let previewView = CapturePreviewView()
    
    let titleLabel = UILabel()
    
    let descTitleLabel = UILabel("Scan Anything:", color: .white, font: .appFont(withSize: 16, weight: .bold), multiline: true)
    let descLabel = UILabel("Invite code, payment invoice, login string,\nuser link, content link, primal gift card", color: .white.withAlphaComponent(0.75), font: .appFont(withSize: 14, weight: .regular), multiline: true)
    
    let enterCodeButton = WalletSendSmallActionBlackButton(title: "Use Keyboard Instead", icon: .walletTabKeyboard)
    
    var cancellables: Set<AnyCancellable> = []
    
    let cover = UIImageView(image: .qrCodeMaskLoading)
    
    var textSearch: String?
    
    var navigationControllerForSearchResults: UINavigationController? {
        dismiss(animated: true)
        return RootViewController.instance.findInChildren()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImageView(image: .qrCodeMask)
        view.addSubview(image)
        image.pinToSuperview()
        image.contentMode = .scaleAspectFill
        image.alpha = 0.8
        
        view.backgroundColor = .background

        videoPreviewLayer.session = captureSession
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds
        view.addSubview(previewView)
        previewView.pinToSuperview()
        
        view.addSubview(cover)
        cover.contentMode = .scaleAspectFill
        cover.pinToSuperview()

        qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
        qrCodeFrameView.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView)
        
        view.bringSubviewToFront(image)
        
        view.addSubview(enterCodeButton)
        enterCodeButton.centerToSuperview(axis: .horizontal)
        enterCodeButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 150).isActive = true
        
        let descStack = UIStackView(axis: .vertical, [descTitleLabel, descLabel])
        descStack.spacing = 4
        view.addSubview(descStack)
        descStack.pinToSuperview(edges: .bottom, padding: 40).centerToSuperview(axis: .horizontal)
        
        addNavigationBar("Scan Code")
    }
    
    var isRunning = false
    var isScanning = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard !isRunning else { return }
        
        Task { @MainActor in
            await self.setUpCaptureSession()
            
            isRunning = true
            
            UIView.animate(withDuration: 0.3) {
                self.cover.alpha = 0
            }
        }
    }
    
    func addNavigationBar(_ title: String) {
        view.addSubview(titleLabel)
        titleLabel.centerToSuperview(axis: .horizontal).pinToSuperview(edges: .top, padding: 20, safeArea: true)
        titleLabel.text = title
        titleLabel.font = .appFont(withSize: 24, weight: .regular)
        titleLabel.textColor = .foreground
    }
}

extension ScanAnythingQRController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
            qrCodeFrameView.frame = CGRect.zero
            return
        }
        
        guard
            metadataObj.type == AVMetadataObject.ObjectType.qr
        else { return }
                
        if let barCodeObject = videoPreviewLayer.transformedMetadataObject(for: metadataObj) {
            qrCodeFrameView.frame = barCodeObject.bounds
        }

        guard let text = metadataObj.stringValue, textSearch != text else { return }
        
        // Try to parse as URL using deeplink handlers first
        if parseURLWithDeeplinkHandlers(text) {
            textSearch = text
            return
        }
        
        // Fallback to search
        search(text)
    }
    
    /// Attempts to parse the given text as a URL using all registered deeplink handlers.
    /// - Parameter text: The text to parse as a URL
    /// - Returns: `true` if the URL was successfully handled by a deeplink handler, `false` otherwise
    func parseURLWithDeeplinkHandlers(_ text: String) -> Bool {
        guard let url = URL(string: text), DeeplinkCoordinator.shared.canHandleURL(url) else { return false }
        
        // Dismiss the scanner and let the handler process the URL
        dismiss(animated: true) {
            DeeplinkCoordinator.shared.handleURL(url)
        }
        
        return true
    }
}
