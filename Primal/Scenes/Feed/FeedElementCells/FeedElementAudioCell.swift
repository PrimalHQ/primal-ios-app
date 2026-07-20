//
//  FeedElementAudioCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 18. 5. 2026..
//

import Combine
import UIKit

protocol AudioCellBindable: AnyObject {
    func bind(audio: ParsedAudio)
}

class FeedElementAudioCell: FeedElementBaseCell, RegularFeedElementCell, AudioCellBindable {
    static var cellID: String { "FeedElementAudioCell" }

    private let container = UIView()
    private let playButton = UIButton(type: .system).constrainToSize(42)
    private let spinner = UIActivityIndicatorView(style: .medium)
    private let titleLabel = UILabel()
    private let domainLabel = UILabel()
    private let durationLabel = UILabel()
    private let waveform = AudioWaveformView().constrainToSize(height: 32)

    private var player: AudioPlayer?
    private var cancellables: Set<AnyCancellable> = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func bind(audio: ParsedAudio) {
        cancellables.removeAll()

        let player = AudioPlayerRegistry.instance.player(for: audio)
        self.player = player

        titleLabel.text = audio.title
        domainLabel.text = URL(string: audio.url)?.host?
            .split(separator: ".")
            .suffix(2)
            .joined(separator: ".") ?? ""

        waveform.seed = audio.url
        waveform.progress = 0
        waveform.onScrub = { [weak player] ratio in
            guard let player else { return }
            let target = (player.duration > 0 ? player.duration : (player.imetaDuration ?? 0)) * Double(ratio)
            player.seek(to: target)
        }

        player.$isPlaying
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isPlaying in
                self?.updatePlayButton(isPlaying: isPlaying)
            }
            .store(in: &cancellables)

        player.$isBuffering
            .receive(on: DispatchQueue.main)
            .sink { [weak self] buffering in
                self?.updateBuffering(buffering)
            }
            .store(in: &cancellables)

        Publishers.CombineLatest(player.$currentTime, player.$duration)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] time, duration in
                self?.updateTimes(time: time, duration: duration)
            }
            .store(in: &cancellables)
        
        updateTheme()
    }

    override func updateTheme() {
        super.updateTheme()
        container.backgroundColor = .background3
        container.layer.cornerRadius = 12
        playButton.backgroundColor = .foreground
        playButton.tintColor = .background2
        titleLabel.textColor = .foreground
        titleLabel.font = .appFont(withSize: 15, weight: .semibold)
        domainLabel.textColor = .foreground4
        domainLabel.font = .appFont(withSize: 12, weight: .regular)
        durationLabel.textColor = .foreground4
        durationLabel.font = .appFont(withSize: 12, weight: .regular)
        spinner.color = .background2
        waveform.setNeedsLayout()
    }
}

private extension FeedElementAudioCell {
    func setupLayout() {
        contentContainer.addSubview(container)
        container
            .pinToSuperview(edges: .top, padding: 4)
            .pinToSuperview(edges: .bottom, padding: 8)
            .pinToSuperview(edges: .leading, padding: leadingPadding)
            .pinToSuperview(edges: .trailing, padding: horizontalPadding)

        container.clipsToBounds = true

        playButton.layer.cornerRadius = 21
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.addAction(.init(handler: { [weak self] _ in self?.toggle() }), for: .touchUpInside)

        let botRow = UIStackView(spacing: 8, [domainLabel, durationLabel])
        botRow.alignment = .center
        let verticalStack = UIStackView(axis: .vertical, spacing: 8, [titleLabel, botRow, waveform])
        verticalStack.setCustomSpacing(2, after: titleLabel)
        
        let mainStack = UIStackView(spacing: 12, [playButton, verticalStack])
        mainStack.alignment = .center
        container.addSubview(mainStack)
        mainStack.pinToSuperview(padding: 12)
        
        container.addSubview(spinner)
        spinner.pin(to: playButton)
        spinner.hidesWhenStopped = true
        
        durationLabel.setContentHuggingPriority(.required, for: .horizontal)
        durationLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.lineBreakMode = .byTruncatingTail
    }

    func toggle() {
        guard let player else { return }
        if player.isPlaying {
            player.pause()
        } else {
            player.play()
        }
    }

    func updatePlayButton(isPlaying: Bool) {
        let name = isPlaying ? "pause.fill" : "play.fill"
        playButton.setImage(UIImage(systemName: name), for: .normal)
    }

    func updateBuffering(_ buffering: Bool) {
        if buffering {
            spinner.startAnimating()
            playButton.imageView?.alpha = 0
        } else {
            spinner.stopAnimating()
            playButton.imageView?.alpha = 1
        }
    }

    func updateTimes(time: TimeInterval, duration: TimeInterval) {
        let effectiveDuration = duration > 0 ? duration : (player?.imetaDuration ?? 0)
        if effectiveDuration > 0 {
            waveform.progress = CGFloat(time / effectiveDuration)
        } else {
            waveform.progress = 0
        }
        durationLabel.text = "\(format(time)) / \(format(effectiveDuration))"
    }

    func format(_ seconds: TimeInterval) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "0:00" }
        let total = Int(seconds)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let secs = total % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        }
        return String(format: "%d:%02d", minutes, secs)
    }
}

class HeaderAudioCell: FeedElementAudioCell {
    static let headerID = "HeaderAudioCell"
}
