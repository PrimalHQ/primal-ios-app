//
//  WalletQRCodeViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 16.10.23..
//

import AVKit
import Combine
import UIKit

final class WalletQRCodeViewController: UIViewController, QRCaptureController {
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer { previewView.previewLayer }
    var qrCodeFrameView = UIView()
    let previewView = CapturePreviewView()
    
    var textSearch: String?
    
    var cancellables: Set<AnyCancellable> = []
    
    let callback: (String, ParsedLNInvoice?, ParsedUser?) -> Void
    init(callback: @escaping (String, ParsedLNInvoice?, ParsedUser?) -> Void) {
        self.callback = callback
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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

        videoPreviewLayer.session = captureSession
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds
        view.addSubview(previewView)
        previewView.pinToSuperview()

        qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
        qrCodeFrameView.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView)
        view.bringSubviewToFront(qrCodeFrameView)
        
        Task { @MainActor in
            await self.setUpCaptureSession()
        }
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
    
    func search(_ text: String) {
        guard textSearch == nil else { return }
        
        textSearch = text
        
        PrimalWalletRequest(type: .parseLNURL(text)).publisher().receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }
                if let message = result.message {
//                        self?.showErrorMessage(message)
                    self.textSearch = nil
                    return
                }
                
                guard let pubkey: String = result.parsedLNURL?.target_pubkey ?? result.parsedLNInvoice?.pubkey else {
                    self.dismiss(animated: true) {
                        self.callback(text, result.parsedLNInvoice, nil)
                    }
                    return
                }
            
                SocketRequest(name: "user_infos", payload: .object(["pubkeys": [.string(pubkey)]])).publisher()
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] userRes in
                        var user: ParsedUser?
                        
                        if let simpUser = userRes.users[pubkey] {
                            user = userRes.createParsedUser(simpUser)
                        }
                        
                        self?.dismiss(animated: true) {
                            self?.callback(text, result.parsedLNInvoice, user)
                        }
                    }
                    .store(in: &self.cancellables)
            }
            .store(in: &cancellables)
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
            search(text)
        }
    }
}
