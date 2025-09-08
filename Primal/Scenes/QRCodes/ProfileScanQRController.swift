//
//  ProfileScanQRController.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.11.23..
//

import AVKit
import Combine
import Kingfisher
import UIKit
import NostrSDK

protocol QRCaptureController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession { get }
}

final class CapturePreviewView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    
    var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
}

final class ProfileScanQRController: UIViewController, OnboardingViewController, QRCaptureController, MetadataCoding {
    var titleLabel: UILabel = .init()
    var backButton: UIButton = .init()
    
    var captureSession = AVCaptureSession()
    var qrCodeFrameView = UIView()
    
    // QR Code debounce properties
    var lastScannedText: String?
    var lastScanTime: Date?
    var isProcessingQRCode = false // Prevent concurrent processing
    private let scanDebounceInterval: TimeInterval = 2.0 // Prevent rescanning same QR for 2 seconds
    
    let previewView = CapturePreviewView()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer { previewView.previewLayer }
    
    var didOpenQRCode = false
    
    let action = QRCodeActionButton("View QR Code")
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        Task { @MainActor in
            await self.setUpCaptureSession()
        }
    }
    
    func search(_ text: String) {
        // Prevent concurrent processing
        if isProcessingQRCode {
            return
        }
        
        // Check if we already processed this QR code recently
        let now = Date()
        if let lastText = lastScannedText, 
           let lastTime = lastScanTime,
           lastText == text,
           now.timeIntervalSince(lastTime) < scanDebounceInterval {
            return
        }
        
        // Set processing flag IMMEDIATELY to prevent race conditions
        isProcessingQRCode = true
        lastScannedText = text
        lastScanTime = now
        
        guard !didOpenQRCode else { 
            isProcessingQRCode = false // Reset processing flag
            return 
        }
        
        // Reset didOpenQRCode after 3 seconds to allow re-scanning if navigation fails
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            if self?.didOpenQRCode == true {
                self?.didOpenQRCode = false
                self?.isProcessingQRCode = false
            }
        }
        
        let origText = text
        let text: String = String(text.split(separator: ":").last ?? "") // Eliminate junk text ("nostr:", etc.)
        
        var pubkey: String?
        var noteId: String?
        
        // Handle npub (user profiles)
        if text.hasPrefix("npub") {
            pubkey = HexKeypair.npubToHexPubkey(text)
        }
        
        // Handle note1 (notes)
        if text.hasPrefix("note1") {
            noteId = text.noteIdToHex()
        }
        
        // Handle complex metadata (nprofile, nevent, naddr, etc.)
        if let result = try? decodedMetadata(from: text) {
            if let resPubkey = result.pubkey {
                pubkey = resPubkey
            }
            if let resEventId = result.eventId {
                noteId = resEventId
            }
            
            // Handle naddr (live streams)
            if let identifier = result.identifier, 
               let kind = result.kind,
               let userId = result.pubkey {
                if kind == UInt32(NostrKind.live.rawValue) {
                    // Set didOpenQRCode = true immediately to prevent double scanning
                    didOpenQRCode = true
                    
                    // Try the live navigation
                    PrimalWebsiteScheme.shared.navigateToLive(pubkey: userId, id: identifier)
                    return
                }
            }
        }
        
        if let pubkey {
            didOpenQRCode = true
            // Clear debounce data on successful navigation
            lastScannedText = nil
            lastScanTime = nil
            isProcessingQRCode = false
            (onboardingParent as? ProfileQRController)?.isOpeningProfileScreen = true
            navigationController?.pushViewController(ProfileViewController(profile: .init(data: .init(pubkey: pubkey))), animated: true)
            return
        }
        
        if let noteId {
            didOpenQRCode = true
            // Clear debounce data on successful navigation
            lastScannedText = nil
            lastScanTime = nil
            isProcessingQRCode = false
            navigationController?.pushViewController(ThreadViewController(threadId: noteId), animated: true)
            return
        }
        
        // Fallback to URL handling
        if let url = URL(string: origText) {
            PrimalWebsiteScheme.shared.openURL(url)
        }
        
        // Reset processing flag if we reach the end without navigation
        isProcessingQRCode = false
    }
}

extension ProfileScanQRController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
            qrCodeFrameView.frame = CGRect.zero
            return
        }

        guard
            metadataObj.type == AVMetadataObject.ObjectType.qr
        else { 
            return 
        }

        if let barCodeObject = videoPreviewLayer.transformedMetadataObject(for: metadataObj) {
            qrCodeFrameView.frame = barCodeObject.bounds
        }

        if let text = metadataObj.stringValue {
            search(text)
        }
    }
}


private extension ProfileScanQRController {
    func setup() {
        addBackground(2.5)
        addNavigationBar("Scan QR Code")
        
        let descLabel = UILabel()
        descLabel.text = "Scan a user's, note or live stream QR code to find them on Nostr"
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
            guard let self else { return }
            self.onboardingParent?.popViewController(animated: true)
        }), for: .touchUpInside)
    }
}

extension QRCaptureController {
    var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            
            var isAuthorized = status == .authorized
            
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            
            return isAuthorized
        }
    }


    func setUpCaptureSession() async {
        guard await isAuthorized else {
            Task { @MainActor in
                let info = UIAlertController(title: "Camera permission not granted", message: "Please go to System Settings and change the permissions.", preferredStyle: .alert)
                info.addAction(.init(title: "OK", style: .cancel))
                info.addAction(.init(title: "Go To Settings", style: .default) { _ in
                    guard
                        let url = URL(string:UIApplication.openSettingsURLString),
                        UIApplication.shared.canOpenURL(url)
                    else { return }

                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                })
                self.present(info, animated: true)
            }
            return
        }
        
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTripleCamera, .builtInDualCamera, .builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)

        guard let captureDevice = deviceDiscoverySession.devices.first ?? AVCaptureDevice.default(for: .video) else {
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
        
        await startRunningSession()
    }
    
    func startRunningSession() async {
        return await withCheckedContinuation({ continuation in
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
                continuation.resume()
            }
        })
    }
}
