//
//  LiveVideoEmbeddedView.swift
//  Primal
//
//  Created by Pavle Stevanović on 28. 7. 2025..
//

import AVFoundation
import Combine
import UIKit

class LiveVideoEmbeddedView: UIView {
    let liveVideoView = PlayerView()
    
    let playButton = UIButton(configuration: .simpleImage(.embedPlayerPause)).constrainToSize(width: 32)
    let closeButton = UIButton(configuration: .simpleImage(.embedPlayerClose)).constrainToSize(width: 32)
    
    var player: VideoPlayer?
    
    var playPauseCancellable: AnyCancellable?
    
    init() {
        super.init(frame: .zero)
        
        clipsToBounds = true
        layer.cornerRadius = 6
        
        addSubview(liveVideoView)
        liveVideoView.pinToSuperview()
        
        let mainStack = UIStackView([playButton, UIView(), closeButton])
        
        addSubview(mainStack)
        mainStack.pinToSuperview(edges: [.horizontal, .top], padding: 2)
                
        liveVideoView.playerLayer.videoGravity = .resizeAspectFill
        
        playButton.tintColor = .white
        closeButton.tintColor = .white
        
        playButton.addAction(.init(handler: { [weak self] _ in
            if self?.player?.isPlaying == true {
                self?.player?.pause()
            } else {
                self?.player?.play()
            }
        }), for: .touchUpInside)
        
        closeButton.addAction(.init(handler: { _ in
            RootViewController.instance.liveVideoController = nil
        }), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func removePlayer() {
        player = nil
        playPauseCancellable = nil
    }
    
    func setup(player: VideoPlayer, live: ProcessedLiveEvent) {
        self.player = player
        let player = player.avPlayer
        liveVideoView.player = player
        
        playPauseCancellable = player.publisher(for: \.timeControlStatus, options: [.initial, .new])
            .map { $0 == .playing ? UIImage.embedPlayerPause : UIImage.embedPlayerPlay }
            .map { UIButton.Configuration.simpleImage($0) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.configuration, on: playButton)
    }
}
