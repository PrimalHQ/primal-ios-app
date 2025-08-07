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

class ParsedLiveComment {
    let user: ParsedUser
    let text: String
    let event: [String: JSON]
    let zapAmount: Int
    let createdAt: Double
    
    init(user: ParsedUser, comment: String, event: [String : JSON], zapAmount: Int = 0) {
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
    var totalHorizontalDistance: CGFloat
    var finalHorizontalScale: CGFloat
    var finalVerticalScale: CGFloat
    var initialTouchPoint: CGPoint
}

class LiveVideoPlayerController: UIViewController {
    
    static var currentlyLivePip: AVPictureInPictureController?
    
    let liveVideoPlayer = LivePlayerView()
    
    let player: VideoPlayer
    
    let live: ParsedLiveEvent
    let user: ParsedUser
    
    let safeAreaSpacer = UIView()
    var safeAreaConstraint: NSLayoutConstraint?
    
    let contentBackgroundView = UIView()
    let contentView = UIView()
    
    var cancellables: Set<AnyCancellable> = []
    
    var videoAspect = CGFloat.zero
    var dismissGestureState: LiveDismissGestureState?
    
    private lazy var commentsVC = LiveVideoChatController(live: live, user: user)
    
    init(live: ParsedLiveEvent, user: ParsedUser) {
        self.live = live
        self.user = user
        player = VideoPlayer(url: live.liveURL, originalURL: "", userPubkey: "", isLive: true)
        
        VideoPlaybackManager.instance.currentlyPlaying = player
        liveVideoPlayer.player = player.avPlayer
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        
        guard let asset = player.avPlayer.currentItem?.asset as? AVURLAsset else { return }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        liveVideoPlayer.backgroundColor = .background
        safeAreaSpacer.backgroundColor = .background
        contentBackgroundView.backgroundColor = .background
        
        contentBackgroundView.addSubview(contentView)
        contentView.pinToSuperview()
        contentView.addSubview(commentsVC.view)
        commentsVC.view.pinToSuperview()
        
        commentsVC.willMove(toParent: self)
        addChild(commentsVC)
        view.addSubview(contentBackgroundView)
        commentsVC.didMove(toParent: self)
        
        let videoStack = UIStackView(axis: .vertical, [safeAreaSpacer, liveVideoPlayer])
        
        view.addSubview(videoStack)
        videoStack.pinToSuperview(edges: [.top, .horizontal])
        let heightC = liveVideoPlayer.heightAnchor.constraint(equalTo: liveVideoPlayer.widthAnchor, multiplier: 9 / 16)
        heightC.priority = .defaultLow
        NSLayoutConstraint.activate([heightC, liveVideoPlayer.heightAnchor.constraint(lessThanOrEqualTo: liveVideoPlayer.widthAnchor)])
        
        safeAreaConstraint = safeAreaSpacer.heightAnchor.constraint(equalToConstant: RootViewController.instance.view.window?.safeAreaInsets.top ?? 0)
        safeAreaConstraint?.isActive = true
        
        contentBackgroundView.pinToSuperview(edges: [.bottom, .horizontal])
        contentBackgroundView.topAnchor.constraint(equalTo: liveVideoPlayer.bottomAnchor).isActive = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_:)))
        view.addGestureRecognizer(panGesture)
        
        liveVideoPlayer.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        player.play()
        
        if AVPictureInPictureController.isPictureInPictureSupported(), let pipController = AVPictureInPictureController(playerLayer: liveVideoPlayer.playerLayer) {
            pipController.startPictureInPicture()
            Self.currentlyLivePip = pipController
        }
        
        if let mainTabBarController: MainTabBarController = RootViewController.instance.findInChildren() {
            mainTabBarController.liveVideoController = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        liveVideoPlayer.setAnchorPoint(.init(x: 0, y: 0.5))
        
        safeAreaConstraint?.constant = view.window?.safeAreaInsets.top ?? 0
        UIView.animate(withDuration: 0.1, animations: { self.view.layoutIfNeeded() })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Self.currentlyLivePip = nil
        
        if
            let mainTabBarController: MainTabBarController = RootViewController.instance.findInChildren(),
            AVPictureInPictureController.isPictureInPictureSupported(),
            let pipController = AVPictureInPictureController(playerLayer: mainTabBarController.livePlayer.liveVideoView.playerLayer)
        {
            pipController.startPictureInPicture()
            Self.currentlyLivePip = pipController
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
        view.transform = .init(translationX: 0, y: progress * dgs.totalVerticalDistance)
        
        safeAreaSpacer.transform = .init(translationX: 0, y: -progress * dgs.totalVerticalDistance - progress.interpolatingBetween(start: 0, end: 200))
    
        contentBackgroundView.transform = .init(translationX: 0, y: progress.interpolatingBetween(start: 0, end: dgs.videoVerticalMove - 140))
        contentBackgroundView.alpha = progress.interpolatingBetween(start: 75, end: 0).clamp(0, 1)
        contentView.alpha = progress.interpolatingBetween(start: 3, end: -1).clamp(0, 1)
        
        liveVideoPlayer.transform = CGAffineTransform(
                translationX: -dgs.totalHorizontalDistance + progress.interpolatingBetween(start: 0, end: 4),
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
        contentBackgroundView.transform = .identity
        contentBackgroundView.alpha = 1
        contentView.alpha = 1
        
        guard let main: MainTabBarController = presentingViewController?.findInChildren() else { return }

        main.livePlayer.liveVideoView.alpha = 1
    }
}



private extension LiveVideoPlayerController {
    @objc func panGestureHandler(_ gesture: UIPanGestureRecognizer) {
        let touchPoint = gesture.location(in: view?.window)
        
        if case .began = gesture.state {
            guard let main: MainTabBarController = presentingViewController?.findInChildren() else { return }
            
            main.livePlayer.liveVideoView.alpha = 0.01
            
            let small = main.livePlayer.liveVideoView.convert(main.livePlayer.liveVideoView.bounds, to: nil)
            let large = liveVideoPlayer.convert(liveVideoPlayer.bounds, to: nil)
            
            dismissGestureState = .init(
                totalVerticalDistance: (small.midY - large.midY) / 2,
                videoVerticalMove: (small.midY - large.midY) / 2,
                totalHorizontalDistance: large.width / 2,
                finalHorizontalScale: small.width / large.width,
                finalVerticalScale: small.height / large.height,
                initialTouchPoint: touchPoint
            )
            
            liveVideoPlayer.hideControls()
            return
        }
        
        guard let dgs = dismissGestureState else { return }
        
        
        let delta = touchPoint.y - dgs.initialTouchPoint.y
        
        var percent = delta / (dgs.totalVerticalDistance)
        percent = percent.clamp(0, 1)
        
        print(delta)
        
        switch gesture.state {
        case .changed, .began:
            setTransition(progress: percent)
        case .ended, .cancelled:
            let velocity = gesture.velocity(in: self.view)
            if delta > 200 || velocity.y > 400 {
                UIView.animate(withDuration: 0.4) {
                    self.setTransition(progress: 1)
                } completion: { _ in
                    let main: MainTabBarController? = self.presentingViewController?.findInChildren()
                    main?.livePlayer.liveVideoView.alpha = 1
                    
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
            dismiss(animated: true)
        case .fullscreen:
            let playerVC = AVPlayerViewController()
            playerVC.delegate = self
            playerVC.player = player.avPlayer
            present(playerVC, animated: true)        }
    }
}

extension LiveVideoPlayerController: AVPlayerViewControllerDelegate {
    func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        // The system pauses when returning from full screen, we need to 'resume' manually.
        coordinator.animate(alongsideTransition: nil) { [weak self] transitionContext in
            self?.player.play()
        }
    }
}
