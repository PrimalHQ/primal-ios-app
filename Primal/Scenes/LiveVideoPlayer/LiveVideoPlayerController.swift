//
//  LiveVideoPlayerController.swift
//  Primal
//
//  Created by Pavle Stevanović on 14. 7. 2025..
//

import UIKit
import AVFoundation
import AVKit
import Combine
import GenericJSON
import NostrSDK

class ParsedLiveComment {
    let user: ParsedUser
    let text: NSAttributedString
    let event: [String: JSON]
    let zapAmount: Int
    let createdAt: Double
    
    init(user: ParsedUser, comment: NSAttributedString, event: [String : JSON], zapAmount: Int = 0) {
        self.user = user
        self.text = comment
        self.event = event
        self.zapAmount = zapAmount
        self.createdAt = event["created_at"]?.doubleValue ?? 0
    }
}

struct LiveDismissGestureState {
    var totalVerticalDistance: CGFloat
    var videoVerticalMove: CGFloat
    var startHorizontalPosition: CGFloat
    var finalHorizontalPosition: CGFloat
    var finalHorizontalScale: CGFloat
    var finalVerticalScale: CGFloat
    var initialTouchPoint: CGPoint
}

class LiveVideoPlayerController: UIViewController {
    let liveVideoPlayer = LivePlayerView()
    let horizontalVideoPlayer = LargeLivePlayerView()
    let horizontalVideoParent = UIView()
    
    let player: VideoPlayer?
    
    let live: ParsedLiveEvent
    
    let safeAreaSpacer = UIView()
    var safeAreaConstraint: NSLayoutConstraint?
    
    let contentBackgroundView = UIView()
    let contentView = AutoHidingView()
    
    var cancellables: Set<AnyCancellable> = []
    
    var videoAspect: CGFloat = 16/9
    var dismissGestureState: LiveDismissGestureState?
    
    private lazy var commentsVC = LiveVideoChatController(live: live)
    
    var currentTransitionProgress: CGFloat = 0
    @Published var currentVideoRotation: UIDeviceOrientation = .portrait
    var isDismissingInteractively: Bool { currentTransitionProgress != 0 }
    
    var smallPip: AVPictureInPictureController? {
        guard AVPictureInPictureController.isPictureInPictureSupported() else { return nil }
        return AVPictureInPictureController(playerLayer: liveVideoPlayer.playerLayer)
    }
    var bigPip: AVPictureInPictureController? {
        guard AVPictureInPictureController.isPictureInPictureSupported() else { return nil }
        return AVPictureInPictureController(playerLayer: horizontalVideoPlayer.playerLayer)
    }
    
    init(live: ParsedLiveEvent) {
        self.live = live
        if let url = live.videoURL {
            player = VideoPlayer(url: url, originalURL: "", userPubkey: "", live: live)
        } else {
            player = nil
        }
        
        print("Muted: \(LiveMuteManager.instance.isMuted(live.user.data.pubkey))") // to initialize the mute list
        
        player?.play()
        liveVideoPlayer.player = player
        
        super.init(nibName: nil, bundle: nil)
        
        DispatchQueue.main.async {
            self.player?.avPlayer.isMuted = false
        }
        
        modalPresentationStyle = .overFullScreen
        
        guard let asset = player?.avPlayer.currentItem?.asset as? AVURLAsset else { return }
        Task { [weak self] in
            do {
                for variant in try await asset.load(.variants) {
                    if let size = variant.videoAttributes?.presentationSize {
                        self?.setVideoAspectRatio(size.width / size.height)
                        return
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override var prefersStatusBarHidden: Bool { currentVideoRotation != .portrait }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        liveVideoPlayer.backgroundColor = .background
        safeAreaSpacer.backgroundColor = .background
        contentBackgroundView.backgroundColor = .background
        
        contentBackgroundView.addSubview(commentsVC.view)
        commentsVC.view.pinToSuperview(edges: [.bottom, .horizontal]).pinToSuperview(edges: .top, padding: 5)
        
        commentsVC.willMove(toParent: self)
        addChild(commentsVC)
        view.addSubview(contentBackgroundView)
        commentsVC.didMove(toParent: self)
        
        let videoStack = UIStackView(axis: .vertical, [safeAreaSpacer, liveVideoPlayer])
        
        view.addSubview(videoStack)
        videoStack.pinToSuperview(edges: [.top, .horizontal])
        let heightC = liveVideoPlayer.heightAnchor.constraint(equalTo: liveVideoPlayer.widthAnchor, multiplier: 9 / 16)
        heightC.priority = .defaultLow
        
        view.addSubview(contentView)
        contentView.pin(to: contentBackgroundView, edges: [.bottom, .horizontal]).pin(to: contentBackgroundView, edges: .top, padding: 5)
        
        view.addSubview(horizontalVideoParent)
        horizontalVideoParent.centerToSuperview(axis: .horizontal).pinToSuperview(edges: .vertical).constrainToAspect(1)
        
        horizontalVideoParent.addSubview(horizontalVideoPlayer)
        horizontalVideoPlayer.pinToSuperview(edges: .horizontal).centerToSuperview()
        horizontalVideoParent.isHidden = true
        
        NSLayoutConstraint.activate([
            heightC,
            horizontalVideoPlayer.heightAnchor.constraint(equalTo: view.widthAnchor),
            liveVideoPlayer.heightAnchor.constraint(lessThanOrEqualTo: liveVideoPlayer.widthAnchor),
        ])
        
        safeAreaConstraint = safeAreaSpacer.heightAnchor.constraint(equalToConstant: RootViewController.instance.view.window?.safeAreaInsets.top ?? 0)
        safeAreaConstraint?.isActive = true
        
        contentBackgroundView.pinToSuperview(edges: [.bottom, .horizontal])
        contentBackgroundView.topAnchor.constraint(equalTo: liveVideoPlayer.bottomAnchor, constant: -5).isActive = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_:)))
        view.addGestureRecognizer(panGesture)
        
        liveVideoPlayer.delegate = self
        horizontalVideoPlayer.delegate = self
        
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .compactMap { _ in UIDevice.current.orientation }
            .filter { $0 == .portrait || $0.isLandscape }
            .sink { [weak self] orientation in
                self?.rotateVideoPlayer(for: orientation)
            }
            .store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        player?.play()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        RootViewController.instance.liveVideoController = self
        
        switch currentVideoRotation {
        case .portrait:
            VideoPlaybackManager.instance.currentlyLivePip = smallPip
        case .landscapeLeft, .landscapeRight:
            VideoPlaybackManager.instance.currentlyLivePip = bigPip
        default: break
        }
        
        liveVideoPlayer.anchorPoint = (.init(x: 0, y: 0.5))
        liveVideoPlayer.transform = .init(translationX: -view.frame.width / 2, y: 0)
        
        safeAreaConstraint?.constant = view.window?.safeAreaInsets.top ?? 0
        UIView.animate(withDuration: 0.1, animations: { self.view.layoutIfNeeded() })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        VideoPlaybackManager.instance.currentlyLivePip = RootViewController.instance.myPip
    }
    
    func presentLivePopup(_ vc: UIViewController) {
        vc.willMove(toParent: self)
        contentView.addSubview(vc.view)
        vc.view.pinToSuperview(edges: [.horizontal, .bottom]).pinToSuperview(edges: .top, padding: -12)
        addChild(vc)
        vc.didMove(toParent: self)
        
        vc.view.transform = .init(translationX: 0, y: 700)
        vc.view.alpha = 0
        
        UIView.animate(withDuration: 0.5) {
            vc.view.transform = .identity
            vc.view.alpha = 1
        }
    }
    
    func chatControllerRequestsMoreSpace() {
        safeAreaSpacer.isHidden = true
    }
    
    func chatControllerRequestsNormalSize() {
        safeAreaSpacer.isHidden = false
    }
    
    func setTransition(progress: CGFloat) {
        guard let dgs = dismissGestureState else { return }
        
        currentTransitionProgress = progress
        
        view.transform = .init(translationX: 0, y: progress * dgs.totalVerticalDistance)
        
        safeAreaSpacer.transform = .init(translationX: 0, y: -progress * dgs.totalVerticalDistance - progress.interpolatingBetween(start: 0, end: 200))
    
        contentBackgroundView.transform = .init(translationX: 0, y: progress.interpolatingBetween(start: 0, end: dgs.videoVerticalMove - 140))
        contentBackgroundView.alpha = progress.interpolatingBetween(start: 75, end: 0).clamp(0, 1)
        commentsVC.view.alpha = progress.interpolatingBetween(start: 3, end: -1).clamp(0, 1)
        
        contentView.transform = .init(translationX: 0, y: progress.interpolatingBetween(start: 0, end: 1000))
        
        liveVideoPlayer.transform = CGAffineTransform(
                translationX: progress.interpolatingBetween(start: dgs.startHorizontalPosition, end: dgs.startHorizontalPosition + dgs.finalHorizontalPosition),
                y: progress.interpolatingBetween(start: 0, end: dgs.videoVerticalMove)
            )
            .scaledBy(
                x: progress.interpolatingBetween(start: 1, end: dgs.finalHorizontalScale),
                y: progress.interpolatingBetween(start: 1, end: dgs.finalVerticalScale)
            )
    }
    
    func resetDismissTransition() {
        view.transform = .identity
        liveVideoPlayer.transform = .init(translationX: -view.bounds.width / 2, y: 0)
        safeAreaSpacer.transform = .identity
        contentView.transform = .identity
        contentBackgroundView.transform = .identity
        contentBackgroundView.alpha = 1
        commentsVC.view.alpha = 1
        currentTransitionProgress = 0
        
        RootViewController.instance.livePlayer.alpha = 1
    }
}



private extension LiveVideoPlayerController {
    private func rotateVideoPlayer(for orientation: UIDeviceOrientation) {
        guard currentTransitionProgress < 0.01, let player else { return }
        
        let big = view.frame
        let small = liveVideoPlayer.convert(liveVideoPlayer.bounds, to: view)
        
        let bigAdjustedHeight = big.width * videoAspect
        
        if currentVideoRotation == .portrait { // For the initial animation
            horizontalVideoParent.transform = .init(scaleX: small.width / bigAdjustedHeight, y: small.height / big.width).translatedBy(x: 0, y: (-big.height / 2 + small.midY) * big.width / small.height)
        }
                
        currentVideoRotation = orientation
        setNeedsStatusBarAppearanceUpdate()
        
        liveVideoPlayer.hideControls()
        horizontalVideoPlayer.hideControls()
        
        switch orientation {
        case .portrait:
            VideoPlaybackManager.instance.currentlyLivePip = smallPip
            UIView.animate(withDuration: 0.3) {
                self.horizontalVideoParent.transform = .init(scaleX: small.width / bigAdjustedHeight, y: small.height / big.width).translatedBy(x: 0, y: (-big.height / 2 + small.midY) * big.width / small.height)
            } completion: { _ in
                self.liveVideoPlayer.playerView.alpha = 1
                self.horizontalVideoPlayer.player = nil
                self.horizontalVideoParent.isHidden = true
            }
        case .landscapeLeft:
            horizontalVideoParent.isHidden = false
            liveVideoPlayer.playerView.alpha = 0
            horizontalVideoPlayer.player = player
            VideoPlaybackManager.instance.currentlyLivePip = bigPip
            
            UIView.animate(withDuration: 0.3) {
                self.horizontalVideoParent.transform = .init(rotationAngle: .pi / 2)
            }
        case .landscapeRight:
            horizontalVideoParent.isHidden = false
            liveVideoPlayer.playerView.alpha = 0
            horizontalVideoPlayer.player = player
            VideoPlaybackManager.instance.currentlyLivePip = bigPip
            
            UIView.animate(withDuration: 0.3) {
                self.horizontalVideoParent.transform = .init(rotationAngle: .pi / -2)
            }
        case .unknown, .portraitUpsideDown, .faceUp, .faceDown: return
        @unknown default:                                       return
        }
        
    }
    
    @objc func panGestureHandler(_ gesture: UIPanGestureRecognizer) {
        let touchPoint = gesture.location(in: view?.window)
        
        guard currentVideoRotation.isPortrait else { return }
        
        if case .began = gesture.state {
            let main = RootViewController.instance
            
            main.livePlayer.alpha = 0.01
            
            let small = main.livePlayer.convert(main.livePlayer.bounds, to: nil)
            let large = liveVideoPlayer.convert(liveVideoPlayer.bounds, to: nil)
            
            dismissGestureState = .init(
                totalVerticalDistance: 500,
                videoVerticalMove: (small.midY - large.midY) - 500,
                startHorizontalPosition: -large.width / 2,
                finalHorizontalPosition: small.minX,
                finalHorizontalScale: small.width / large.width,
                finalVerticalScale: small.height / large.height,
                initialTouchPoint: touchPoint
            )
            
            liveVideoPlayer.hideControls()
            
            commentsVC.input.textView.resignFirstResponder()
            return
        }
        
        guard let dgs = dismissGestureState else { return }
        
        
        let delta = touchPoint.y - dgs.initialTouchPoint.y
        
        var percent = delta / (dgs.totalVerticalDistance)
        percent = percent.clamp(0, 1)
        
        switch gesture.state {
        case .changed, .began:
            setTransition(progress: percent)
        case .ended, .cancelled:
            let velocity = gesture.velocity(in: self.view)
            if delta > 200 || velocity.y > 400 {
                UIView.animate(withDuration: 0.4) {
                    self.setTransition(progress: 1)
                } completion: { _ in
                    RootViewController.instance.livePlayer.alpha = 1
                    
                    self.dismiss(animated: false) { [weak self] in
                        self?.resetDismissTransition()
                    }
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.resetDismissTransition()
                }
            }
        default:
            break
        }
    }

    @MainActor
    func setVideoAspectRatio(_ aspect: CGFloat) {
        videoAspect = aspect
        let heightC = liveVideoPlayer.widthAnchor.constraint(equalTo: liveVideoPlayer.heightAnchor, multiplier: aspect)
        heightC.priority = .defaultHigh
        heightC.isActive = true
    }
}

extension LiveVideoPlayerController: LivePlayerViewDelegate {
    func livePlayerViewPerformAction(_ action: LivePlayerViewAction) {
        switch action {
        case .dismiss:
            rotateVideoPlayer(for: .portrait)
            dismiss(animated: true)
        case .fullscreen:
            if currentVideoRotation == .portrait {
                rotateVideoPlayer(for: .landscapeLeft)
            } else {
                rotateVideoPlayer(for: .portrait)
            }
        case .quote:
            let new = AdvancedEmbedPostViewController()
            new.manager.embeddedElements.append(.live(live))
            present(new, animated: true)
        case .copyRawData:
            UIPasteboard.general.string = live.event.event.encodeToString()
            liveVideoPlayer.showDimmedToastCentered("Copied!")
        case .copyID:
            UIPasteboard.general.string = "nostr:\(live.event.noteId())"
            liveVideoPlayer.showDimmedToastCentered("Copied!")
        case .copyLink:
            UIPasteboard.general.string = live.webURL()
            liveVideoPlayer.showDimmedToastCentered("Copied!")
        case .mute:
            let pubkey = live.user.data.pubkey
            let alert = UIAlertController(title: "Are you sure you want to mute this user?", message: nil, preferredStyle: .alert)
            if MuteManager.instance.isMutedUser(pubkey) {
                alert.title = "User is already muted"
                alert.addAction(.init(title: "OK", style: .default))
            } else {
                alert.addAction(.init(title: "Cancel", style: .cancel))
                alert.addAction(.init(title: "Mute", style: .destructive, handler: { [weak self] _ in
                    MuteManager.instance.toggleMuteUser(pubkey)
                    
                    self?.dismiss(animated: true)
                    RootViewController.instance.liveVideoController = nil
                }))
            }
            present(alert, animated: true)
        case .report:
            present(PopupReportContentController(live), animated: true)
        case .share:
            let activityViewController = UIActivityViewController(activityItems: [live.webURL()], applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
        }
    }
}

extension LiveVideoPlayerController: AVPlayerViewControllerDelegate {
    func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        // The system pauses when returning from full screen, we need to 'resume' manually.
        coordinator.animate(alongsideTransition: nil) { [weak self] transitionContext in
            self?.player?.play()
        }
    }
}

extension ParsedLiveEvent: PostingReferenceObject, MetadataCoding {
    var reference: (tagLetter: String, universalID: String)? {
        ("a", event.universalID)
    }
    
    var referencePubkey: String {
        user.data.pubkey
    }
    
    func webURL() -> String {
        if let name = PremiumCustomizationManager.instance.getPremiumName(pubkey: event.creatorPubkey) {
            return "https://primal.net/\(name)/live/\(event.dTag)"
        }

        var metadata = Metadata()
        metadata.pubkey = event.creatorPubkey
        if let identifier = try? encodedIdentifier(with: metadata, identifierType: .profile) {
            return "https://primal.net/p/\(identifier)/live/\(event.dTag)"
        }

        let npub = event.creatorPubkey.hexToNpub() ?? event.creatorPubkey

        return "https://primal.net/p/\(npub)/live/\(event.dTag)/"
    }
}
