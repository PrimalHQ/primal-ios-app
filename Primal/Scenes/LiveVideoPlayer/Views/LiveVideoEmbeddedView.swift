//
//  LiveVideoEmbeddedView.swift
//  Primal
//
//  Created by Pavle Stevanović on 28. 7. 2025..
//

import AVFoundation
import Combine
import UIKit
import Lottie

class LiveVideoEmbeddedView: UIView {
    let playerView = PlayerView()
    
    private let playButton = UIButton(configuration: .simpleImage(.embedPlayerPause)).constrainToSize(32)
    private let closeButton = UIButton(configuration: .simpleImage(.embedPlayerClose)).constrainToSize(32)
    private let loadingView = UIView().constrainToSize(32)
    private let animationView = LottieAnimationView(animation: AnimationType.liveBuffering.animation).constrainToSize(40)
    
    private let leftChevron = UIImageView(image: .livePlayerChevron)
    private let rightChevron = UIImageView(image: .livePlayerChevron)
    
    @Published var showChevron = false
    var player: VideoPlayer?
    
    var playPauseCancellable: AnyCancellable?
    
    init() {
        super.init(frame: .zero)
        
        clipsToBounds = true
        layer.cornerRadius = 6
        backgroundColor = .black
        
        addSubview(playerView)
        playerView.pinToSuperview()
        
        let mainStack = UIStackView([playButton, UIView(), closeButton])
        
        addSubview(loadingView)
        loadingView.centerToSuperview()
        loadingView.addSubview(animationView)
        animationView.centerToSuperview()
        animationView.loopMode = .loop
        
        addSubview(mainStack)
        mainStack.pinToSuperview(edges: [.horizontal, .top], padding: 2)
        
        addSubview(leftChevron)
        leftChevron.pinToSuperview(edges: [.leading, .vertical])
        leftChevron.transform = .init(rotationAngle: .pi)
        
        addSubview(rightChevron)
        rightChevron.pinToSuperview(edges: [.trailing, .vertical])
        
        leftChevron.isHidden = true
        rightChevron.isHidden = true
                
        playerView.playerLayer.videoGravity = .resizeAspectFill
        
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
        playerView.player = player.avPlayer
        
        playPauseCancellable = Publishers.CombineLatest3(
            player.avPlayer.publisher(for: \.timeControlStatus, options: [.initial, .new]).map { $0 == .playing },
            player.$isPlaying,
            $showChevron
        )
        .sink(receiveValue: { [weak self] isPlaying, shouldPlay, showChevron in
            guard let self else { return }
            
            leftChevron.isHidden = !showChevron
            rightChevron.isHidden = !showChevron
            
            playButton.isHidden = showChevron || (isPlaying != shouldPlay)
            closeButton.isHidden = showChevron
            loadingView.isHidden = isPlaying == shouldPlay
            
            playButton.configuration = .simpleImage(isPlaying ? UIImage.embedPlayerPause : UIImage.embedPlayerPlay)
            
            if isPlaying == shouldPlay {
                animationView.pause()
            } else {
                animationView.play()
            }
        })
    }
}
