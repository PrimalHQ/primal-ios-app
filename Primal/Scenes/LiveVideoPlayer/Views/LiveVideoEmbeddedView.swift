//
//  LiveVideoEmbeddedView.swift
//  Primal
//
//  Created by Pavle Stevanović on 28. 7. 2025..
//

import AVFoundation
import Combine
import UIKit

class LiveVideoEmbeddedView: UIView, Themeable {
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let liveVideoView = PlayerView()
    
    let playButton = UIButton(configuration: .simpleImage(.embedPlayerPause)).constrainToSize(width: 36)
    let closeButton = UIButton(configuration: .simpleImage(.embedPlayerClose)).constrainToSize(width: 36)
    
    var player: AVPlayer? {
        get { liveVideoView.player }
        set { liveVideoView.player = newValue }
    }
    
    var playPauseCancellable: AnyCancellable?
    
    init() {
        super.init(frame: .zero)
        
        let textStack = UIStackView(axis: .vertical, [titleLabel, subtitleLabel])
        textStack.spacing = 2
        let mainStack = UIStackView([liveVideoView, textStack, playButton, closeButton])
        mainStack.alignment = .center
        
        addSubview(mainStack)
        mainStack.pinToSuperview(padding: 4)
        mainStack.setCustomSpacing(10, after: liveVideoView)
        
        liveVideoView.constrainToSize(width: 93, height: 52)
        
        liveVideoView.playerLayer.videoGravity = .resizeAspectFill
        
        titleLabel.font = .appFont(withSize: 14, weight: .semibold)
        subtitleLabel.font = .appFont(withSize: 12, weight: .regular)
                
        updateTheme()
        
        playButton.addAction(.init(handler: { [weak self] _ in
            if self?.player?.rate ?? 0 > 0.5 {
                self?.player?.pause()
            } else {
                self?.player?.play()
            }
        }), for: .touchUpInside)
        
        closeButton.addAction(.init(handler: { _ in
            guard let mainTab: MainTabBarController = RootViewController.instance.findInChildren() else { return }
            mainTab.liveVideoController = nil
        }), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        playButton.tintColor = .foreground3
        closeButton.tintColor = .foreground3
        
        titleLabel.textColor = .foreground
        subtitleLabel.textColor = .foreground4
        
        playButton.backgroundColor = .background4
        closeButton.backgroundColor = .background4
        backgroundColor = .background4
    }
    
    func removePlayer() {
        player = nil
        playPauseCancellable = nil
    }
    
    func setup(player: AVPlayer, live: ParsedLiveEvent) {
        self.player = player
        
        titleLabel.text = live.title.trimmingCharacters(in: .whitespacesAndNewlines)
        subtitleLabel.text = live.summary.trimmingCharacters(in: .whitespacesAndNewlines)
        subtitleLabel.isHidden = subtitleLabel.text?.isEmpty ?? true
        
        playPauseCancellable = player.publisher(for: \.timeControlStatus, options: [.initial, .new])
            .map { $0 == .playing ? UIImage.embedPlayerPause : UIImage.embedPlayerPlay }
            .map { UIButton.Configuration.simpleImage($0) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.configuration, on: playButton)
    }
}
