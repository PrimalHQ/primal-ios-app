//
//  AudioPlayerContentView.swift
//  Primal
//
//  Created by Pavle Stevanović on 18. 5. 2026..
//

import Combine
import UIKit

final class AudioPlayerContentView: UIView, FloatingPlayerContent, Themeable {
    static let skipInterval: TimeInterval = 15

    private let backButton = UIButton(type: .system).constrainToSize(24)
    private let playButton = UIButton(type: .system).constrainToSize(28)
    private let forwardButton = UIButton(type: .system).constrainToSize(24)
    private let spinner = UIActivityIndicatorView(style: .medium)
    private let closeButton = UIButton(configuration: .simpleImage(.embedPlayerClose)).constrainToSize(24)
    private let titleLabel = UILabel()
    private let timeLabel = UILabel()

    var player: AudioPlayer? {
        didSet { bindPlayer() }
    }

    var onClose: (() -> Void)?

    private var cancellables: Set<AnyCancellable> = []

    init() {
        super.init(frame: .zero)
        setupLayout()
        updateTheme()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        backgroundColor = .background3
        
        backButton.tintColor = .foreground
        playButton.tintColor = .foreground
        forwardButton.tintColor = .foreground
        closeButton.tintColor = .foreground
        
        spinner.color = .foreground
        
        titleLabel.textColor = .foreground
        timeLabel.textColor = .foreground4
    }

    private func setupLayout() {
        layer.cornerRadius = 6
        clipsToBounds = true

        backButton.setImage(UIImage(systemName: "gobackward.15"), for: .normal)
        backButton.addAction(.init(handler: { [weak self] _ in self?.skip(-Self.skipInterval) }), for: .touchUpInside)

        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.addAction(.init(handler: { [weak self] _ in self?.togglePlay() }), for: .touchUpInside)

        forwardButton.setImage(UIImage(systemName: "goforward.15"), for: .normal)
        forwardButton.addAction(.init(handler: { [weak self] _ in self?.skip(Self.skipInterval) }), for: .touchUpInside)

        let controls = UIStackView([backButton, playButton, forwardButton])
        controls.spacing = 6
        controls.alignment = .center
        
        let topStack = UIStackView(spacing: 8, [titleLabel, closeButton])
        topStack.alignment = .center
        let horizontalStack = UIStackView(axis: .horizontal, spacing: 0, [controls, UIView(), timeLabel])
        horizontalStack.alignment = .center
        
        let mainStack = UIStackView(axis: .vertical, [topStack, UIView(), horizontalStack])

        addSubview(mainStack)
        mainStack.pinToSuperview(edges: .vertical, padding: 4).pinToSuperview(edges: .horizontal, padding: 12)
        
        addSubview(spinner)
        spinner.pin(to: playButton)
        spinner.hidesWhenStopped = true
        closeButton.addAction(.init(handler: { [weak self] _ in self?.onClose?() }), for: .touchUpInside)
        
        titleLabel.font = .appFont(withSize: 12, weight: .semibold)
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail
        
        timeLabel.font = .appFont(withSize: 10, weight: .regular)
        timeLabel.setContentHuggingPriority(.required, for: .horizontal)
    }

    private func bindPlayer() {
        cancellables.removeAll()
        guard let player else {
            titleLabel.text = ""
            timeLabel.text = ""
            return
        }

        titleLabel.text = player.title

        player.$isPlaying
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isPlaying in
                let name = isPlaying ? "pause.fill" : "play.fill"
                self?.playButton.setImage(UIImage(systemName: name), for: .normal)
            }
            .store(in: &cancellables)

        player.$isBuffering
            .receive(on: DispatchQueue.main)
            .sink { [weak self] buffering in
                if buffering {
                    self?.spinner.startAnimating()
                    self?.playButton.imageView?.alpha = 0
                } else {
                    self?.spinner.stopAnimating()
                    self?.playButton.imageView?.alpha = 1
                }
            }
            .store(in: &cancellables)

        Publishers.CombineLatest(player.$currentTime, player.$duration)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] time, duration in
                self?.updateTimeLabel(time: time, duration: duration)
            }
            .store(in: &cancellables)
    }

    private func togglePlay() {
        guard let player else { return }
        if player.isPlaying { player.pause() } else { player.play() }
    }

    private func skip(_ delta: TimeInterval) {
        guard let player else { return }
        player.seek(to: player.currentTime + delta)
    }

    private func updateTimeLabel(time: TimeInterval, duration: TimeInterval) {
        let effectiveDuration = duration > 0 ? duration : (player?.imetaDuration ?? 0)
        timeLabel.text = "\(format(time)) / \(format(effectiveDuration))"
    }

    private func format(_ seconds: TimeInterval) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "0:00" }
        let total = Int(seconds)
        let minutes = total / 60
        let secs = total % 60
        return String(format: "%d:%02d", minutes, secs)
    }

    func setPeeking(_ peeking: Bool) {
        subviews.forEach { $0.alpha = peeking ? 0 : 1 }
    }
}
