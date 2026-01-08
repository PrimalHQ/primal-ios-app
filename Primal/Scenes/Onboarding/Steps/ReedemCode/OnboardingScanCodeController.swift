//
//  OnboardingScanCodeController.swift
//  Primal
//
//  Created by Pavle Stevanović on 15.5.25..
//

import AVKit
import Combine
import UIKit

final class OnboardingScanCodeController: OnboardingBaseViewController, QRCaptureController, WalletSearchController, PromotionCodeChecker {
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer { previewView.previewLayer }
    var qrCodeFrameView = UIView()
    let previewView = CapturePreviewView()
    
    let enterCodeButton = WalletSendSmallActionBlackButton(title: "Use Keyboard Instead", icon: .walletTabKeyboard)
    
    var cancellables: Set<AnyCancellable> = []
    
    let cover = UIImageView(image: .qrCodeMaskLoading)
    
    var textSearch: String?
    
    var navigationControllerForSearchResults: UINavigationController? { RootViewController.instance.findInChildren() }
    
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
        
        let descStack = UIStackView(axis: .vertical, [
            UILabel("Scan Anything:", color: .white, font: .appFont(withSize: 16, weight: .bold), multiline: true),
            UILabel("Invite code, payment invoice, login string,\nuser link, content link, primal gift card", color: .white.withAlphaComponent(0.75), font: .appFont(withSize: 14, weight: .regular), multiline: true)
        ])
        descStack.spacing = 4
        view.addSubview(descStack)
        descStack.pinToSuperview(edges: .bottom, padding: 40).centerToSuperview(axis: .horizontal)
        
        enterCodeButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            onboardingParent?.pushViewController(OnboardingEnterCodeController(backgroundIndex: backgroundIndex + 1), animated: true)
        }), for: .touchUpInside)
        
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
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
//            self.dismiss(animated: true) {
//                RootViewController.instance.present(RemoteSignerRootController(.newLogin("nostrconnect://5aa4f3ea9da10181c7246d19876dc420405dd1aa5caaf93580f56a5ef74e5520?url=https%3A%2F%2Fapp.coracle.social&name=Coracle&image=https%3A%2F%2Fapp.coracle.social%2Fimages%2Flogo.png&perms=sign_event%3A22242%2Cnip04_encrypt%2Cnip04_decrypt%2Cnip44_encrypt%2Cnip44_decrypt&secret=278yp5&relay=wss%3A%2F%2Frelay.nsec.app%2F&relay=wss%3A%2F%2Fbucket.coracle.social%2F&relay=wss%3A%2F%2Foffchain.pub%2F")), animated: true)
//            }
//        }
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

        guard let text = metadataObj.stringValue else { return }
              
        if let code = text.split(separator: "/").last?.string, code.count == 8, textSearch != code {
            textSearch = code
            
            checkPromotionCode(code) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let info):
                    onboardingParent?.pushViewController(OnboardingPreviewCodeController(info: info, code: code, backgroundIndex: backgroundIndex + 1), animated: true)
                case .failure(let message):
                    onboardingParent?.pushViewController(OnboardingEnterCodeController(startingCode: code, error: message, backgroundIndex: backgroundIndex + 1), animated: true)
                    return
                }
            }
            return
        }
        
        if text.hasPrefix("nostrconnect:") {
            dismiss(animated: true) {
                RootViewController.instance.present(RemoteSignerRootController(.newLogin(text)), animated: true)
            }
            return
        }
        
        search(text)
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
