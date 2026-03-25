//
//  FeedVideoPlayer.swift
//  Primal
//
//  Created by Pavle Stevanović on 22. 8. 2025..
//

import AVKit
import Combine
import Foundation

class FeedVideoPlayer: NSObject, PlayerProtocol {
    func setMuted(_ isMuted: Bool) {
        avPlayer.isMuted = isMuted

        let category: AVAudioSession.Category = isMuted ? .ambient : .playback
        VideoPlaybackManager.instance.setAudioSessionCategory(category)
    }

    lazy var avPlayer: AVPlayer = playerWithURL(url)

    @Published var isPlaying = false

    var shouldPause = false

    var url: String
    var userPubkey: String
    var originalURL: String

    var cancellables: Set<AnyCancellable> = []
    private var playerItemObserver: NSKeyValueObservation?

    init(url: String, originalURL: String, userPubkey: String) {
        self.url = url
        self.originalURL = originalURL
        self.userPubkey = userPubkey
        super.init()

        if ContentDisplaySettings.autoPlayVideos {
            _ = avPlayer // Force init
        }
    }

    func play() {
        shouldPause = false
        isPlaying = true

        avPlayer.play()

        let isMuted = VideoPlaybackManager.instance.isMuted
        avPlayer.isMuted = isMuted

        let category: AVAudioSession.Category = isMuted ? .ambient : .playback
        VideoPlaybackManager.instance.setAudioSessionCategory(category)

        VideoPlaybackManager.instance.currentlyPlaying = self
    }

    func pause() {
        isPlaying = false
        shouldPause = false
        avPlayer.pause()
    }

    func delayedPause() {
        shouldPause = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
            if self.shouldPause {
                self.pause()
            }
        }
    }

    private func playerWithURL(_ url: String) -> AVPlayer {
        guard let url = URL(string: url) else { return AVPlayer() }

        let item = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: item)
        player.actionAtItemEnd = .none
        player.isMuted = true

        playerItemObserver = item.observe(\.status, options: [.new, .initial]) { [weak self] _, value in
            guard case .failed = value.newValue else { return }

            self?.attemptBlossomLoad()
        }

        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
            .sink { [weak player, weak self] _ in
                if let duration = player?.currentItem?.duration.seconds, duration < 0.5 {
                    self?.attemptBlossomLoad()
                } else {
                    player?.seek(to: .zero)
                }
            }
            .store(in: &cancellables)

        return player
    }

    func attemptBlossomLoad() {
        guard let finalURL: URL = { () -> URL? in
            guard
                let blossomInfo = BlossomServerManager.instance.serversForUser(pubkey: userPubkey),
                let firstServer = blossomInfo.first,
                let pathComponent = URL(string: originalURL)?.pathExtension
            else { return URL(string: originalURL) }

            let serverURL = blossomInfo.first(where: { !url.contains($0) }) ?? firstServer
            guard var finalURL = URL(string: serverURL) else { return URL(string: originalURL) }
            finalURL.append(path: pathComponent)
            return finalURL
        }()
        else { return }

        if finalURL.absoluteString == url {
            print("REACHED THE END OF BLOSSOM LIST")
            return
        }

        let item = AVPlayerItem(url: finalURL)
        avPlayer = .init(playerItem: item)
        url = finalURL.absoluteString
        playerItemObserver = item.observe(\.status, options: [.new, .initial]) { [weak self] _, value in
            guard case .failed = value.newValue else { return }

            self?.attemptBlossomLoad()
        }
    }
}
