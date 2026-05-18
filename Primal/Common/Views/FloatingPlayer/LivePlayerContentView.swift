//
//  LivePlayerContentView.swift
//  Primal
//
//  Created by Pavle Stevanović on 18. 5. 2026..
//

import AVFoundation
import Combine
import Lottie
import UIKit

final class LivePlayerContentView: UIView, FloatingPlayerContent {
    let playerView = PlayerView()

    private let playButton = UIButton(configuration: .simpleImage(.embedPlayerPause)).constrainToSize(32)
    private let closeButton = UIButton(configuration: .simpleImage(.embedPlayerClose)).constrainToSize(32)
    private let loadingView = UIView().constrainToSize(32)
    private let animationView = LottieAnimationView(animation: AnimationType.liveBuffering.animation).constrainToSize(40)

    private let streamEndedView = UIView()
    private let streamEndedLabel = UILabel("STREAM ENDED", color: .init(rgb: 0x666666), font: .appFont(withSize: 12, weight: .bold))

    private(set) var player: LiveVideoPlayer? {
        didSet { streamEndedView.isHidden = player != nil }
    }

    private var stateCancellable: AnyCancellable?
    private var peeking: Bool = false

    var livePlayerLayer: AVPlayerLayer { playerView.playerLayer }

    init() {
        super.init(frame: .zero)

        addSubview(playerView)
        playerView.pinToSuperview()
        playerView.playerLayer.videoGravity = .resizeAspectFill

        addSubview(loadingView)
        loadingView.centerToSuperview()
        loadingView.addSubview(animationView)
        animationView.centerToSuperview()
        animationView.loopMode = .loop

        addSubview(playButton)
        playButton.pinToSuperview(edges: [.leading, .top], padding: 2)

        addSubview(streamEndedView)
        streamEndedView.pinToSuperview()
        streamEndedView.isHidden = true
        streamEndedView.addSubview(streamEndedLabel)
        streamEndedLabel.centerToSuperview()
        streamEndedView.backgroundColor = .init(rgb: 0x222222)

        addSubview(closeButton)
        closeButton.pinToSuperview(edges: [.trailing, .top], padding: 2)

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

    func setup(player: LiveVideoPlayer) {
        self.player = player
        playerView.player = player.avPlayer

        stateCancellable = Publishers.CombineLatest(
            player.avPlayer.publisher(for: \.timeControlStatus, options: [.initial, .new]).map { $0 == .playing },
            player.$isPlaying
        )
        .receive(on: DispatchQueue.main)
        .sink(receiveValue: { [weak self] isPlaying, shouldPlay in
            guard let self else { return }

            loadingView.isHidden = isPlaying == shouldPlay

            playButton.configuration = .simpleImage(isPlaying ? UIImage.embedPlayerPause : UIImage.embedPlayerPlay)

            if isPlaying == shouldPlay {
                animationView.pause()
            } else {
                animationView.play()
            }

            // Re-apply peek state so the play button hides on idle peek frames.
            applyPeekVisibility()
        })
    }

    func removePlayer() {
        player = nil
        playerView.player = nil
        stateCancellable = nil
    }

    func setPeeking(_ peeking: Bool) {
        self.peeking = peeking
        applyPeekVisibility()
    }

    private func applyPeekVisibility() {
        playButton.isHidden = peeking
        closeButton.isHidden = peeking
        // playerView stays visible so the thumbnail peeks out at the edge.
    }
}
