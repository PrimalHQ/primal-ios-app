//
//  WalletQRCodeViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 16.10.23..
//

import AVKit
import UIKit

final class WalletQRCodeViewController: UIViewController {
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImageView(image: UIImage(named: "qrCodeMask"))
        view.addSubview(image)
        image.pinToSuperview()
        image.contentMode = .scaleAspectFill
        
        let cancelButton = UIButton()
        cancelButton.setImage(UIImage(named: "cancelScan"), for: .normal)
        cancelButton.addAction(.init(handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }), for: .touchUpInside)
        view.addSubview(cancelButton)
        cancelButton.pinToSuperview(edges: .bottom, padding: 30, safeArea: true).centerToSuperview(axis: .horizontal)
        
        view.backgroundColor = .background
        
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTripleCamera, .builtInDualCamera, .builtInDualWideCamera], mediaType: AVMediaType.video, position: .back)

        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
        } catch {
            print(error)
            return
        }
        
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureMetadataOutput)

        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]

        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds
        view.layer.insertSublayer(videoPreviewLayer, at: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        DispatchQueue.global(qos: .background).async {
            self.captureSession.stopRunning()
        }
    }
}

extension WalletQRCodeViewController: AVCaptureMetadataOutputObjectsDelegate {
    
}
