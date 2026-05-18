//
//  AudioPlayer.swift
//  Primal
//
//  Created by Pavle Stevanović on 18. 5. 2026..
//

import AVFoundation
import Combine
import Foundation
import MediaPlayer
import UIKit

final class AudioPlayer: NSObject, PlayerProtocol {
    let url: String
    let title: String
    let domain: String
    let imetaDuration: TimeInterval?

    @Published var isPlaying = false
    @Published var isBuffering = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var didError = false

    var blocksAutoplay: Bool { true }

    let avPlayer: AVPlayer
    private var playerItem: AVPlayerItem?
    private var timeObserverToken: Any?
    private var itemStatusObserver: NSKeyValueObservation?
    private var timeControlObserver: NSKeyValueObservation?
    private var didEndObserver: NSObjectProtocol?
    private var remoteCommandsRegistered = false

    init(url: String, title: String, domain: String, imetaDuration: TimeInterval?) {
        self.url = url
        self.title = title
        self.domain = domain
        self.imetaDuration = imetaDuration

        let player = AVPlayer()
        player.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
        player.actionAtItemEnd = .none
        self.avPlayer = player

        super.init()

        if let imetaDuration { self.duration = imetaDuration }

        guard let assetURL = URL(string: url) else {
            didError = true
            return
        }

        let item = AVPlayerItem(url: assetURL)
        avPlayer.replaceCurrentItem(with: item)
        playerItem = item

        itemStatusObserver = item.observe(\.status, options: [.new, .initial]) { [weak self] item, _ in
            guard let self else { return }

            switch item.status {
            case .readyToPlay:
                let seconds = CMTimeGetSeconds(item.duration)
                if seconds.isFinite, seconds > 0 {
                    self.duration = seconds
                }
            case .failed:
                self.didError = true
            default:
                break
            }
        }

        timeControlObserver = avPlayer.observe(\.timeControlStatus, options: [.new, .initial]) { [weak self] player, _ in
            guard let self else { return }
            self.isBuffering = player.timeControlStatus == .waitingToPlayAtSpecifiedRate
        }

        let interval = CMTime(seconds: 0.25, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = avPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self else { return }
            self.currentTime = CMTimeGetSeconds(time)
            self.updateNowPlayingElapsed()
        }

        didEndObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.avPlayer.seek(to: .zero)
            self.currentTime = 0
            self.isPlaying = false
            self.updateNowPlayingElapsed()
        }
    }

    deinit {
        if let timeObserverToken {
            avPlayer.removeTimeObserver(timeObserverToken)
        }
        if let didEndObserver {
            NotificationCenter.default.removeObserver(didEndObserver)
        }
        itemStatusObserver?.invalidate()
        timeControlObserver?.invalidate()
        clearNowPlayingInfo()
    }

    func play() {
        VideoPlaybackManager.instance.setAudioSessionCategory(.playback)
        avPlayer.play()
        isPlaying = true
        VideoPlaybackManager.instance.currentlyPlaying = self
        setupNowPlayingInfo()
    }

    func pause() {
        avPlayer.pause()
        isPlaying = false
        updateNowPlayingElapsed()
    }

    func delayedPause() {
        pause()
    }

    func setMuted(_ isMuted: Bool) {
        avPlayer.isMuted = isMuted
    }

    func seek(to seconds: TimeInterval) {
        let clamped = max(0, min(duration, seconds))
        let target = CMTime(seconds: clamped, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        avPlayer.seek(to: target, toleranceBefore: .zero, toleranceAfter: .zero)
        currentTime = clamped
        updateNowPlayingElapsed()
    }
}

// MARK: - Now Playing / Remote Commands

private extension AudioPlayer {
    func setupNowPlayingInfo() {
        var info: [String: Any] = [:]
        info[MPMediaItemPropertyTitle] = title
        info[MPMediaItemPropertyArtist] = domain
        if duration > 0 {
            info[MPMediaItemPropertyPlaybackDuration] = duration
        }
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info

        registerRemoteCommandsIfNeeded()
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }

    func updateNowPlayingElapsed() {
        guard var info = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        if duration > 0 { info[MPMediaItemPropertyPlaybackDuration] = duration }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    func clearNowPlayingInfo() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    func registerRemoteCommandsIfNeeded() {
        guard !remoteCommandsRegistered else { return }
        remoteCommandsRegistered = true

        let center = MPRemoteCommandCenter.shared()

        center.playCommand.isEnabled = true
        center.pauseCommand.isEnabled = true
        center.togglePlayPauseCommand.isEnabled = true
        center.changePlaybackPositionCommand.isEnabled = true

        center.nextTrackCommand.isEnabled = false
        center.previousTrackCommand.isEnabled = false
        center.skipForwardCommand.isEnabled = false
        center.skipBackwardCommand.isEnabled = false
        center.seekForwardCommand.isEnabled = false
        center.seekBackwardCommand.isEnabled = false
        center.changePlaybackRateCommand.isEnabled = false

        center.playCommand.addTarget { [weak self] _ in
            self?.play()
            return .success
        }
        center.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }
        center.togglePlayPauseCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            if self.isPlaying { self.pause() } else { self.play() }
            return .success
        }
        center.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self, let positionEvent = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            self.seek(to: positionEvent.positionTime)
            return .success
        }
    }
}
