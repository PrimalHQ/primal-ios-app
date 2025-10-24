//
//  ImageGalleryVideoController.swift
//  Primal
//
//  Created by Pavle Stevanović on 16. 10. 2025..
//

import UIKit

class ImageGalleryVideoController: UIViewController, ImageGalleryMediaController, UIGestureRecognizerDelegate {
    let media: MediaMetadata.Resource
    
    var video: VideoPlayer {
        let currentlyPlaying = VideoPlaybackManager.instance.currentlyPlaying
        return (currentlyPlaying?.originalURL == media.url ? currentlyPlaying : nil) ?? VideoPlayer(url: media.url, originalURL: media.url, userPubkey: "")
    }
    
    lazy var fullScreenVideoController = FullScreenVideoPlayerController(video)
    
    let background = UIView()
    
    init(media: MediaMetadata.Resource) {
        self.media = media
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(background)
        background.pinToSuperview()
        
        fullScreenVideoController.willMove(toParent: self)
        view.addSubview(fullScreenVideoController.view)
        fullScreenVideoController.view.pinToSuperview()
        addChild(fullScreenVideoController)
        fullScreenVideoController.didMove(toParent: self)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        pan.delegate = self
        view.addGestureRecognizer(pan)
        
        fullScreenVideoController.view.backgroundColor = .clear
        background.backgroundColor = .black
    }
    
    @objc func didPan(_ sender: UIPanGestureRecognizer) {
        let trans = sender.translation(in: view)
        
        switch sender.state {
        case .began, .changed:
            let rotationProgress = (trans.x / 400).clamp(-1, 1)
            let rotation = (.pi * 0.2) * rotationProgress
            
            fullScreenVideoController.view.transform = CGAffineTransform(translationX: trans.x, y: trans.y).rotated(by: rotation)
            
            let totalTrans = sqrt(trans.x * trans.x + trans.y * trans.y)
            let progress = (totalTrans / 500).clamp(0, 1)
            background.alpha = 1 - progress
        case .ended, .cancelled:
            let velocity = sender.velocity(in: view)
            let extendedTrans = CGPoint(x: trans.x + velocity.x / 20, y: trans.y + velocity.y / 20)
                        
            let totalTrans = sqrt(extendedTrans.x * extendedTrans.x + extendedTrans.y * extendedTrans.y)
            if totalTrans > 200 {
                UIView.animate(withDuration: 0.4) { [self] in
                    fullScreenVideoController.view.transform = fullScreenVideoController.view.transform.translatedBy(x: velocity.x / 5, y: velocity.y / 5)
                    fullScreenVideoController.view.alpha = 0
                    background.alpha = 0
                } completion: { _ in
                    self.dismiss(animated: false)
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.fullScreenVideoController.view.transform = .identity
                    self.background.alpha = 1
                }
            }
        default:
            break
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate for panning exit gesture
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        
        let velocity = pan.velocity(in: view)
        return abs(velocity.y) > abs(velocity.x)
    }
}
