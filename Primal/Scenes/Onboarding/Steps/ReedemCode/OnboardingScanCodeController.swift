//
//  OnboardingScanCodeController.swift
//  Primal
//
//  Created by Pavle Stevanović on 15.5.25..
//

import AVKit
import Combine
import UIKit

final class OnboardingScanCodeController: UIViewController, QRCaptureController, OnboardingViewController, PromotionCodeChecker {
    let titleLabel = UILabel()
    let backButton: UIButton = .init()
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer { previewView.previewLayer }
    var qrCodeFrameView = UIView()
    let previewView = CapturePreviewView()
    
    let enterCodeButton = WalletSendSmallActionBlackButton(title: "Enter Code Instead", icon: .walletTabKeyboard)
    
    var cancellables: Set<AnyCancellable> = []
    
    let cover = UIImageView(image: .qrCodeMaskLoading)
    
    var checking: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImageView(image: UIImage(named: "qrCodeMask"))
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
        enterCodeButton.pinToSuperview(edges: .bottom, padding: 140).centerToSuperview(axis: .horizontal)
        
        let descLabel = UILabel("Scan your Invite Code,\nor a Primal Gift Card.", color: .white, font: .appFont(withSize: 18, weight: .regular), multiline: true)
        view.addSubview(descLabel)
        descLabel.pinToSuperview(edges: .bottom, padding: 40).centerToSuperview(axis: .horizontal)
        
        enterCodeButton.addAction(.init(handler: { [weak self] _ in
            self?.onboardingParent?.pushViewController(OnboardingEnterCodeController(), animated: true)
        }), for: .touchUpInside)
        
        addNavigationBar("Redeem Code")
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
}

extension OnboardingScanCodeController: AVCaptureMetadataOutputObjectsDelegate {
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

        guard let text = metadataObj.stringValue, let code = text.split(separator: "/").last?.string, code.count == 8, checking != code else { return }
            
        checking = code
        
        checkPromotionCode(code) { [weak self] result in
            switch result {
            case .success(let info):
                self?.onboardingParent?.pushViewController(OnboardingPreviewCodeController(info: info, code: code), animated: true)
            case .failure(let message):
                self?.onboardingParent?.pushViewController(OnboardingEnterCodeController(startingCode: code, error: message), animated: true)
                return
            }
        }
    }
}

protocol PromotionCodeChecker: UIViewController {
    var cancellables: Set<AnyCancellable> { get set }
}

struct PromoCodeInfo: Codable {
//    let origin_pubkey: String
    let welcome_message: String
    let preloaded_btc: String?
}

extension PromotionCodeChecker {
    func checkPromotionCode(_ code: String, callback: @escaping (Result<PromoCodeInfo, String>) -> Void) {
        SocketRequest(name: "promo_code_get_details", payload: ["promo_code": .string(code)], connection: Connection.wallet).publisher()
            .receive(on: DispatchQueue.main)
            .sink { res in
                if let message = res.message {
                    callback(.failure(message))
                    return
                }
                
                if let data = res.events.first(where: { Int($0["kind"]?.doubleValue ?? 0) == NostrKind.promoCodeInfo.rawValue }),
                   let promoInfo: PromoCodeInfo = data["content"]?.stringValue?.decode() {
                    callback(.success(promoInfo))
                    return
                }
                
                callback(.failure("Error"))
            }
            .store(in: &cancellables)
    }
    
    func activatePromotionCode(_ code: String, callback: @escaping (String?) -> Void) {
        guard let event = NostrObject.activatePromoCode(code: code) else {
            callback("Promo code not activated")
            return
        }
        
        SocketRequest(name: "promo_codes_redeem", payload: ["event_from_user": event.toJSON()], connection: Connection.wallet).publisher()
            .receive(on: DispatchQueue.main)
            .sink { res in
                if let message = res.message {
                    callback(message)
                    return
                }
                
                callback(nil)
            }
            .store(in: &cancellables)
    }
}
