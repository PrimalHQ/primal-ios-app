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
    
    lazy var textStack = UIStackView(axis: .vertical, [titleLabel, subtitleLabel])
    let textStackParent = UIView()
    let gradientView = UIImageView(image: .liveTextGradientCover)
    
    var maxTitleDelta: CGFloat = 0
    var maxSubtitleDelta: CGFloat = 0
    var currentDelta: CGFloat = 0 {
        didSet {
            titleLabel.transform = .init(translationX: -min(maxTitleDelta, currentDelta), y: 0)
            subtitleLabel.transform = .init(translationX: -min(maxSubtitleDelta, currentDelta), y: 0)
        }
    }
    
    var player: VideoPlayer?
    
    var playPauseCancellable: AnyCancellable?
    private var titleDisplayLink: CADisplayLink? {
        didSet {
            oldValue?.remove(from: .main, forMode: .default)
            titleDisplayLink?.add(to: .main, forMode: .default)
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        textStack.spacing = 2
        textStack.alignment = .leading
        textStackParent.addSubview(textStack)
        textStack.pinToSuperview(edges: [.vertical, .leading])
        
        textStackParent.addSubview(gradientView)
        gradientView.pinToSuperview(edges: [.trailing, .vertical])
        
        textStackParent.clipsToBounds = true
        
        let mainStack = UIStackView([liveVideoView, textStackParent, playButton, closeButton])
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
            if self?.player?.isPlaying == true {
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
        
        gradientView.tintColor = .background4
        playButton.backgroundColor = .background4
        closeButton.backgroundColor = .background4
        backgroundColor = .background4
    }
    
    func removePlayer() {
        player = nil
        playPauseCancellable = nil
    }
    
    func setup(player: VideoPlayer, live: ParsedLiveEvent) {
        self.player = player
        let player = player.avPlayer
        liveVideoView.player = player
        
        titleLabel.text = live.title.trimmingCharacters(in: .whitespacesAndNewlines)
        subtitleLabel.text = live.summary.trimmingCharacters(in: .whitespacesAndNewlines)
        subtitleLabel.isHidden = subtitleLabel.text?.isEmpty ?? true
        
        playPauseCancellable = player.publisher(for: \.timeControlStatus, options: [.initial, .new])
            .map { $0 == .playing ? UIImage.embedPlayerPause : UIImage.embedPlayerPlay }
            .map { UIButton.Configuration.simpleImage($0) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.configuration, on: playButton)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
            guard let self, titleLabel.frame.width > textStackParent.frame.width || subtitleLabel.frame.width > textStackParent.frame.width else { return }
            
            maxTitleDelta = max(0, titleLabel.frame.width - textStackParent.frame.width + 20)
            maxSubtitleDelta = max(0, subtitleLabel.frame.width - textStackParent.frame.width + 20)
            
            startUpdatingLabels()
        }
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        startUpdatingLabels()
    }
    
    func startUpdatingLabels() {
        guard maxTitleDelta > 0 || maxSubtitleDelta > 0 else {
            currentDelta = 0
            isPaused = false
            elapsed = 0
            titleLabel.transform = .identity
            subtitleLabel.transform = .identity
            titleDisplayLink = nil
            return
        }
        
        titleDisplayLink = .init(target: self, selector: #selector(updateLabelAnimation))
    }

    var maxDelta: CGFloat { max(maxTitleDelta, maxSubtitleDelta) }
    var animationDuration: CGFloat { maxDelta / 50 }
    
    private var elapsed: CGFloat = 0
    var direction: CGFloat = -1
    var isPaused = false
    
    @objc private func updateLabelAnimation(link: CADisplayLink) {
        let dt = CGFloat(link.duration)
        elapsed += dt
        
        if isPaused {
            if elapsed < 2 {
                return
            }
            isPaused = false
            elapsed = 0
        }
        
        var progress = elapsed / animationDuration
        if progress >= 1 {
            // Switch direction
            direction *= -1
            elapsed = 0
            progress = 0
            
            isPaused = true // Pause after reaching start/end position
        }
        
        if direction < 0 {
            let delta = maxDelta * -progress
            
            let titleOffset = delta.clamp(-maxTitleDelta, 0)
            titleLabel.transform = CGAffineTransform(translationX: titleOffset, y: 0)
            let subtitleOffset = delta.clamp(-maxSubtitleDelta, 0)
            subtitleLabel.transform = CGAffineTransform(translationX: subtitleOffset, y: 0)
        } else {
            let moveDelta = maxDelta * progress
            
            let titleDelta = -maxTitleDelta + moveDelta
            let subtitleDelta = -maxSubtitleDelta + moveDelta
            
            let titleOffset = titleDelta.clamp(-maxTitleDelta, 0)
            titleLabel.transform = CGAffineTransform(translationX: titleOffset, y: 0)
            let subtitleOffset = subtitleDelta.clamp(-maxSubtitleDelta, 0)
            subtitleLabel.transform = CGAffineTransform(translationX: subtitleOffset, y: 0)
        }
    }
}
