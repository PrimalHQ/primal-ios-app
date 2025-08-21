//
//  LivePlayerView.swift
//  Primal
//
//  Created by Pavle Stevanović on 14. 7. 2025..
//

import AVKit
import Combine
import UIKit

enum LivePlayerViewAction {
    case dismiss, fullscreen
}

protocol LivePlayerViewDelegate: AnyObject {
    func livePlayerViewPerformAction(_ action: LivePlayerViewAction)
}

class LargeLivePlayerView: LivePlayerView {
    override var horizontalMargin: CGFloat { 36 }
    override var verticalMargin: CGFloat { 20 }
    
    override init() {
        super.init()
        
        fullscreenButton.configuration = .simpleImage(.exitFullScreen)
        
        playerLayer.videoGravity = .resizeAspect
        
        backgroundColor = .black
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class LivePlayerView: UIView {
    let playerView = PlayerView()
    
    var playerLayer: AVPlayerLayer { playerView.playerLayer }
    var player: AVPlayer? {
        get { playerLayer.player }
        set {
            playerLayer.player = newValue
            
            setCancellables()
        }
    }
    
    let controlsView = UIView()
    
    let dismissButton = UIButton(configuration: .simpleImage(.liveMinimize))
    let airplayButton = AVRoutePickerView() //UIButton(configuration: .simpleImage(.airPlay))
    let threeDotsButton = UIButton(configuration: .simpleImage(.threeDots))
    
    let playPauseButton = UIButton(configuration: .simpleImage(.videoPlay))
    let seekPastButton = UIButton(configuration: .simpleImage(.videoSeekPast))
    let seekFutureButton = UIButton(configuration: .simpleImage(.videoSeekFuture))
    
    let muteButton = UIButton(configuration: .simpleImage(.videoMuted))
    let fullscreenButton = UIButton(configuration: .simpleImage(.fullScreen))
    
    let liveDot = UIView().constrainToSize(8)
    
    weak var delegate: LivePlayerViewDelegate?
    
    var cancellables: Set<AnyCancellable> = []
    var timeObserver: Any?
    
    // TO BE OVERRIDDEN BY THE CHILD
    var horizontalMargin: CGFloat { 8 }
    var verticalMargin: CGFloat { 4 }
    var buttonSize: CGFloat { 36 }
    
    init() {
        super.init(frame: .zero)
        
        playerLayer.videoGravity = .resizeAspectFill
        
        addSubview(playerView)
        playerView.pinToSuperview()
        
        addSubview(controlsView)
        controlsView.isHidden = true
        controlsView.backgroundColor = .black.withAlphaComponent(0.25)
        controlsView.pinToSuperview()
        
        let topRightStack = UIStackView([airplayButton.constrainToSize(buttonSize), threeDotsButton.constrainToSize(buttonSize)])
        topRightStack.spacing = 4
        controlsView.addSubview(topRightStack)
        topRightStack.pinToSuperview(edges: .trailing, padding: horizontalMargin)
        
        controlsView.addSubview(dismissButton.constrainToSize(buttonSize))
        dismissButton.pinToSuperview(edges: .leading, padding: horizontalMargin).pinToSuperview(edges: .top, padding: verticalMargin)
        topRightStack.centerToView(dismissButton, axis: .vertical)
        
        let botRightStack = UIStackView([muteButton.constrainToSize(buttonSize), fullscreenButton.constrainToSize(buttonSize)])
        botRightStack.spacing = 4
        controlsView.addSubview(botRightStack)
        botRightStack.pinToSuperview(edges: .trailing, padding: horizontalMargin).pinToSuperview(edges: .bottom, padding: verticalMargin)
        
        let liveStack = UIStackView([liveDot, UIImageView(image: .liveIcon)])
        liveStack.alignment = .center
        liveStack.spacing = 6
        controlsView.addSubview(liveStack)
        liveStack.centerToView(botRightStack, axis: .vertical).pin(to: dismissButton, edges: .leading)
        
        controlsView.addSubview(playPauseButton)
        playPauseButton.centerToSuperview()
        
        controlsView.addSubview(seekFutureButton)
        seekFutureButton.pin(to: playPauseButton, edges: .trailing, padding: -90).centerToSuperview(axis: .vertical)
        
        controlsView.addSubview(seekPastButton)
        seekPastButton.pin(to: playPauseButton, edges: .leading, padding: -90).centerToSuperview(axis: .vertical)
        
        airplayButton.prioritizesVideoDevices = true
        airplayButton.activeTintColor = .white
        airplayButton.tintColor = .white
        threeDotsButton.tintColor = .white
        liveDot.backgroundColor = .live
        liveDot.layer.cornerRadius = 4
        
        threeDotsButton.centerToView(fullscreenButton, axis: .horizontal)
        airplayButton.centerToView(muteButton, axis: .horizontal)
        
        playPauseButton.addAction(.init(handler: { [weak self] _ in
            guard let player = self?.player else { return }
            if player.timeControlStatus == .playing {
                player.pause()
                self?.liveDot.backgroundColor = .init(rgb: 0xAAAAAA)
            } else {
                player.play()
            }
        }), for: .touchUpInside)
        
        muteButton.addAction(.init(handler: { [weak self] _ in
            if self?.player?.isMuted == true {
                VideoPlaybackManager.instance.isMuted = false
            } else {
                VideoPlaybackManager.instance.isMuted = true
            }
        }), for: .touchUpInside)
        
        seekPastButton.addAction(.init(handler: { [weak self] _ in
            self?.player?.seek15SecondsBackward()
        }), for: .touchUpInside)
        
        seekFutureButton.addAction(.init(handler: { [weak self] _ in
            self?.player?.seek30SecondsForward()
        }), for: .touchUpInside)
        
        dismissButton.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.livePlayerViewPerformAction(.dismiss)
        }), for: .touchUpInside)
        
        fullscreenButton.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.livePlayerViewPerformAction(.fullscreen)
        }), for: .touchUpInside)
        
        addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            guard let self else { return }
            if self.controlsView.isHidden {
                self.controlsView.alpha = 0
                self.controlsView.isHidden = false
                UIView.animate(withDuration: 0.2) {
                    self.controlsView.alpha = 1
                }
            } else {
                self.hideControls()
            }
        }))
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func hideControls() {
        UIView.animate(withDuration: 0.2) {
            self.controlsView.alpha = 0
        } completion: { _ in
            self.controlsView.isHidden = true
        }        
    }
    
    func setCancellables() {
        cancellables = []
        
        // Is playing
        player?.publisher(for: \.timeControlStatus, options: [.initial, .new])
            .map { $0 == .playing ? UIImage.liveVideoPause : UIImage.liveVideoPlay }
            .map { UIButton.Configuration.simpleImage($0) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.configuration, on: playPauseButton)
            .store(in: &cancellables)
        
        // Is Muted
        player?.publisher(for: \.isMuted, options: [.initial, .new])
            .map { $0 ? UIImage.videoMuted : UIImage.videoUnmuted }
            .map { UIButton.Configuration.simpleImage($0) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.configuration, on: muteButton)
            .store(in: &cancellables)
        
        // time
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] _ in
            guard let player = self?.player, let item = player.currentItem else { return }
            
            // Get seekable range
            guard player.rate > 0.5, let range = item.seekableTimeRanges.last?.timeRangeValue else {
                self?.liveDot.backgroundColor = .init(rgb: 0xAAAAAA)
                return
            }
            
            let livePosition = CMTimeAdd(range.start, range.duration)
            let currentTime = item.currentTime()
            
            // Consider within 2 seconds of live edge to be "live"
            let difference = CMTimeSubtract(livePosition, currentTime)
            let secondsFromLive = CMTimeGetSeconds(difference)
            
            self?.liveDot.backgroundColor = secondsFromLive <= 5 ? .live : .init(rgb: 0xAAAAAA)
        }
    }
}
