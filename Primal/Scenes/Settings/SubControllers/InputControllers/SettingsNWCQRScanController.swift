//
//  SettingsNWCQRScanController.swift
//  Primal
//
//  Created by Pavle Stevanović on 29.5.25..
//

import UIKit
import AVFoundation
import Combine

class SettingsNWCQRScanController: UIViewController, OnboardingViewController, QRCaptureController {
    var titleLabel = UILabel()
    var backButton = UIButton()
    
    var captureSession = AVCaptureSession()
    var qrCodeFrameView = UIView()
    
    let previewView = CapturePreviewView()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer { previewView.previewLayer }
    
    var didOpenQRCode = false
    
    let action = QRCodeActionButton("Paste Connection String")
    
    private var cancellables: Set<AnyCancellable> = []
    
    var didCall = false
    let callback: (String) -> Void
    init(callback: @escaping (String) -> Void) {
        self.callback = callback
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        Task { @MainActor in
            await self.setUpCaptureSession()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        mainTabBarController?.setTabBarHidden(true, animated: animated)
    }
    
}

extension SettingsNWCQRScanController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !didCall, let metadataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
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
            didCall = true
            callback(text)
            navigationController?.popViewController(animated: true)
        }
    }
}


private extension SettingsNWCQRScanController {
    func setup() {
        addBackground(1)
        addNavigationBar("Connect NWC Wallet")
        
        backButton.addAction(.init(handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }), for: .touchUpInside)
        backButton.isHidden = false
        
        let descLabel = UILabel()
        descLabel.text = "Scan the NWC\nconnection QR code"
        descLabel.textAlignment = .center
        descLabel.font = .appFont(withSize: 18, weight: .regular)
        descLabel.textColor = .white
        descLabel.numberOfLines = 0
        
        videoPreviewLayer.session = captureSession
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer.masksToBounds = true
        videoPreviewLayer.borderColor = UIColor.white.cgColor
        videoPreviewLayer.borderWidth = 4
        videoPreviewLayer.cornerRadius = 16
        
        let mainStack = UIStackView(axis: .vertical, [previewView.constrainToSize(280), SpacerView(height: 16), descLabel])
        descLabel.pinToSuperview(edges: .horizontal, padding: 40)
        mainStack.alignment = .center
        view.addSubview(mainStack)
        mainStack.centerToSuperview().constrainToSize(width: 280)
        
        view.addSubview(action)
        action.pinToSuperview(edges: .horizontal, padding: 35).pinToSuperview(edges: .bottom, padding: 45, safeArea: true)
        
        qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
        qrCodeFrameView.layer.borderWidth = 2
        previewView.addSubview(qrCodeFrameView)
        
        action.addAction(.init(handler: { [weak self] _ in
            guard let self, !didCall, let text = UIPasteboard.general.string else { return }
            didCall = true
            callback(text)
            navigationController?.popViewController(animated: true)
        }), for: .touchUpInside)
    }
}
