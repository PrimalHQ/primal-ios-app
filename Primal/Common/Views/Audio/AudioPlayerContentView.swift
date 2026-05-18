//
//  AudioPlayerContentView.swift
//  Primal
//
//  Created by Pavle Stevanović on 18. 5. 2026..
//

import Combine
import UIKit

final class AudioPlayerContentView: UIView {
    private let playButton = UIButton(type: .system).constrainToSize(28)
    private let spinner = UIActivityIndicatorView(style: .medium)
    private let closeButton = UIButton(configuration: .simpleImage(.embedPlayerClose)).constrainToSize(28)
    private let titleLabel = UILabel()
    private let timeLabel = UILabel()
    private let progressBar = UIView()
    private let progressFill = UIView()

    var player: AudioPlayer? {
        didSet { bindPlayer() }
    }

    var onClose: (() -> Void)?

    private var cancellables: Set<AnyCancellable> = []
    private var progressFillWidth: NSLayoutConstraint?

    init() {
        super.init(frame: .zero)
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupLayout() {
        backgroundColor = .background3
        layer.cornerRadius = 6
        clipsToBounds = true

        addSubview(playButton)
        playButton
            .pinToSuperview(edges: .leading, padding: 8)
            .centerToSuperview(axis: .vertical)
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.tintColor = .foreground
        playButton.addAction(.init(handler: { [weak self] _ in self?.togglePlay() }), for: .touchUpInside)

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

        addSubview(progressBar)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.backgroundColor = .foreground5
        progressBar.layer.cornerRadius = 1

        progressBar.addSubview(progressFill)
        progressFill.translatesAutoresizingMaskIntoConstraints = false
        progressFill.backgroundColor = .foreground
        progressFill.layer.cornerRadius = 1

        let fillWidth = progressFill.widthAnchor.constraint(equalToConstant: 0)
        progressFillWidth = fillWidth

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: closeButton.leadingAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),

            timeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),

            progressBar.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 6),
            progressBar.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -8),
            progressBar.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 2),

            progressFill.leadingAnchor.constraint(equalTo: progressBar.leadingAnchor),
            progressFill.topAnchor.constraint(equalTo: progressBar.topAnchor),
            progressFill.bottomAnchor.constraint(equalTo: progressBar.bottomAnchor),
            fillWidth
        ])
    }

    private func bindPlayer() {
        cancellables.removeAll()
        guard let player else {
            titleLabel.text = ""
            timeLabel.text = ""
            progressFillWidth?.constant = 0
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
                self?.updateProgress(time: time, duration: duration)
            }
            .store(in: &cancellables)
    }

    private func togglePlay() {
        guard let player else { return }
        if player.isPlaying { player.pause() } else { player.play() }
    }

    private func updateProgress(time: TimeInterval, duration: TimeInterval) {
        let effectiveDuration = duration > 0 ? duration : (player?.imetaDuration ?? 0)
        let ratio: CGFloat = effectiveDuration > 0 ? CGFloat(time / effectiveDuration) : 0
        layoutIfNeeded()
        let barWidth = progressBar.bounds.width
        progressFillWidth?.constant = max(0, min(barWidth, barWidth * ratio))
        timeLabel.text = "\(format(time))/\(format(effectiveDuration))"
    }

    private func format(_ seconds: TimeInterval) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "0:00" }
        let total = Int(seconds)
        let minutes = total / 60
        let secs = total % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}
