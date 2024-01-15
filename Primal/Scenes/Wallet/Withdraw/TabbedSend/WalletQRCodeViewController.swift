//
//  WalletQRCodeViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 16.10.23..
//

import AVKit
import Combine
import UIKit

protocol WalletSendTabController: UIViewController { }

extension WalletSendTabController {
    var sendParent: WalletSendParentViewController? {
        parent as? WalletSendParentViewController ?? parent?.parent as? WalletSendParentViewController
    }
}

final class WalletQRCodeViewController: UIViewController, QRCaptureController, WalletSendTabController {
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer { previewView.previewLayer }
    var qrCodeFrameView = UIView()
    let previewView = CapturePreviewView()
    
    var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImageView(image: UIImage(named: "qrCodeMask"))
        view.addSubview(image)
        image.pinToSuperview(safeArea: true)
        image.contentMode = .scaleAspectFill
        image.alpha = 0.8
        
        view.backgroundColor = .background

        videoPreviewLayer.session = captureSession
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds
        view.addSubview(previewView)
        previewView.pinToSuperview()

        qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
        qrCodeFrameView.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView)
        
        view.bringSubviewToFront(image)
        
        let importImageButton = WalletSendSmallActionBlackButton(title: "Scan Image", icon: UIImage(named: "walletImageIcon"))
        view.addSubview(importImageButton)
        importImageButton.pinToSuperview(edges: .bottom, padding: 40).centerToSuperview(axis: .horizontal).constrainToSize(width: 164)
        
        importImageButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            ImagePickerManager(self, mode: .gallery) { [weak self] image, isPNG in
                guard let code = image.detectQRCode() else { return }
                self?.sendParent?.search(code)
            }
        }), for: .touchUpInside)
    }
    
    var isRunning = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        guard !isRunning else { return }
        
        Task { @MainActor in
            await self.setUpCaptureSession()
            
            isRunning = true
            
            self.startSession()
        }
    }
    
    func startSession() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }
}

extension WalletQRCodeViewController: AVCaptureMetadataOutputObjectsDelegate {
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

        if let text = metadataObj.stringValue {
            sendParent?.search(text)
        }
    }
}
