//
//  AudioPlayerContentView.swift
//  Primal
//
//  Created by Pavle Stevanović on 18. 5. 2026..
//

import Combine
import UIKit

final class AudioPlayerContentView: UIView, FloatingPlayerContent {
    static let skipInterval: TimeInterval = 15

    private let backButton = UIButton(type: .system).constrainToSize(24)
    private let playButton = UIButton(type: .system).constrainToSize(28)
    private let forwardButton = UIButton(type: .system).constrainToSize(24)
    private let spinner = UIActivityIndicatorView(style: .medium)
    private let closeButton = UIButton(configuration: .simpleImage(.embedPlayerClose)).constrainToSize(28)
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
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupLayout() {
        backgroundColor = .background3
        layer.cornerRadius = 6
        clipsToBounds = true

        backButton.setImage(UIImage(systemName: "gobackward.15"), for: .normal)
        backButton.tintColor = .foreground
        backButton.addAction(.init(handler: { [weak self] _ in self?.skip(-Self.skipInterval) }), for: .touchUpInside)

        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.tintColor = .foreground
        playButton.addAction(.init(handler: { [weak self] _ in self?.togglePlay() }), for: .touchUpInside)

        forwardButton.setImage(UIImage(systemName: "goforward.15"), for: .normal)
        forwardButton.tintColor = .foreground
        forwardButton.addAction(.init(handler: { [weak self] _ in self?.skip(Self.skipInterval) }), for: .touchUpInside)

        let controls = UIStackView([backButton, playButton, forwardButton])
        controls.spacing = 6
        controls.alignment = .center
        addSubview(controls)
        controls.translatesAutoresizingMaskIntoConstraints = false

        addSubview(spinner)
        spinner.pin(to: playButton)
        spinner.hidesWhenStopped = true
        spinner.color = .foreground

        addSubview(closeButton)
        closeButton
            .pinToSuperview(edges: .trailing, padding: 6)
            .centerToSuperview(axis: .vertical)
        closeButton.tintColor = .foreground
        closeButton.addAction(.init(handler: { [weak self] _ in self?.onClose?() }), for: .touchUpInside)

        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .appFont(withSize: 12, weight: .semibold)
        titleLabel.textColor = .foreground
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail

        addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = .appFont(withSize: 10, weight: .regular)
        timeLabel.textColor = .foreground4

        NSLayoutConstraint.activate([
            controls.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            controls.centerYAnchor.constraint(equalTo: centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: controls.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: closeButton.leadingAnchor, constant: -6),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),

            timeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: closeButton.leadingAnchor, constant: -6),
            timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
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
