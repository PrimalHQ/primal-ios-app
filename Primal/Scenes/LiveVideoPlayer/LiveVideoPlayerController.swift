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

class LiveVideoPlayerController: UIViewController {
    
    static var currentlyLivePip: AVPictureInPictureController?
    
    let liveVideoPlayer = LivePlayerView()
    
    let player: AVPlayer
    
    let live: ParsedLiveEvent
    let user: ParsedUser
    
    let safeAreaSpacer = UIView()
    var safeAreaConstraint: NSLayoutConstraint?
    
    var cancellables: Set<AnyCancellable> = []
    
    var initialTouchPoint = CGPoint.zero
    
    private lazy var commentsVC = LiveVideoChatController(live: live, user: user)
    
    init(live: ParsedLiveEvent, user: ParsedUser) {
        self.live = live
        self.user = user
        
        let asset = AVURLAsset(url: live.liveURL)
        
        player = AVPlayer(playerItem: .init(asset: asset))
        liveVideoPlayer.playerLayer.player = player
        player.play()
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        
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
        
        let videoStack = UIStackView(axis: .vertical, [safeAreaSpacer, liveVideoPlayer])
        
        view.addSubview(videoStack)
        videoStack.pinToSuperview(edges: [.top, .horizontal])
        let heightC = liveVideoPlayer.heightAnchor.constraint(equalTo: liveVideoPlayer.widthAnchor, multiplier: 9 / 16)
        heightC.priority = .defaultLow
        NSLayoutConstraint.activate([heightC, liveVideoPlayer.heightAnchor.constraint(lessThanOrEqualTo: liveVideoPlayer.widthAnchor)])
        
        safeAreaConstraint = safeAreaSpacer.heightAnchor.constraint(equalToConstant: RootViewController.instance.view.window?.safeAreaInsets.top ?? 0)
        safeAreaConstraint?.isActive = true
        
        liveVideoPlayer.playerLayer.videoGravity = .resizeAspectFill
        
        view.backgroundColor = .background
        
        commentsVC.willMove(toParent: self)
        addChild(commentsVC)
        view.addSubview(commentsVC.view)
        commentsVC.didMove(toParent: self)
        
        commentsVC.view.pinToSuperview(edges: [.bottom, .horizontal])
        commentsVC.view.topAnchor.constraint(equalTo: liveVideoPlayer.bottomAnchor).isActive = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_:)))
        view.addGestureRecognizer(panGesture)
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        safeAreaConstraint?.constant = view.window?.safeAreaInsets.top ?? 0
        UIView.animate(withDuration: 0.1, animations: { self.view.layoutIfNeeded() })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Self.currentlyLivePip = nil
    }
    
    func chatControllerRequestsMoreSpace() {
        safeAreaSpacer.isHidden = true
    }
    
    func chatControllerRequestsNormalSize() {
        safeAreaSpacer.isHidden = false
    }
}

private extension LiveVideoPlayerController {
    @objc func panGestureHandler(_ gesture: UIPanGestureRecognizer) {
        let touchPoint = gesture.location(in: view?.window)
        
        let delta = touchPoint.y - initialTouchPoint.y
        
        switch gesture.state {
        case .began:
            initialTouchPoint = touchPoint
        case .changed:
            if touchPoint.y > initialTouchPoint.y {
                view.transform = .init(translationX: 0, y: delta)
            }
        case .ended, .cancelled:
            let velocity = gesture.velocity(in: self.view)
            if delta > 350 || velocity.y > 500 {
                self.dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.view.transform = .identity
                }
            }
        default:
            break
        }
    }

    @MainActor
    func setVideoAspectRatio(_ aspect: CGFloat) {
        let heightC = liveVideoPlayer.widthAnchor.constraint(equalTo: liveVideoPlayer.heightAnchor, multiplier: aspect)
        heightC.priority = .defaultHigh
        heightC.isActive = true
    }
}
