//
//  VideoPlaybackManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 29.8.23..
//

import AVFoundation
import UIKit
import Combine
import AVKit

final class VideoPlaybackManager: NSObject {
    static let instance = VideoPlaybackManager()

    var currentlyLivePip: AVPictureInPictureController? {
        didSet {
            oldValue?.canStartPictureInPictureAutomaticallyFromInline = false
            currentlyLivePip?.canStartPictureInPictureAutomaticallyFromInline = true
        }
    }

    @Published var isMuted = true

    @Published var currentlyPlaying: PlayerProtocol? {
        didSet {
            guard oldValue !== currentlyPlaying else { return }
            oldValue?.pause()
        }
    }

    var autoPlay: Bool { !blocksAutoplay }
    var blocksAutoplay: Bool { currentlyPlaying?.blocksAutoplay == true && currentlyPlaying?.isPlaying == true }

    var currentlyPlayingFeedVideo: FeedVideoPlayer? { currentlyPlaying as? FeedVideoPlayer }
    var currentlyPlayingLiveVideo: LiveVideoPlayer? { currentlyPlaying as? LiveVideoPlayer }

    private var cancellables: Set<AnyCancellable> = []

    override init() {
        super.init()

        $isMuted
            .dropFirst()
            .sink { [weak self] isMuted in
                self?.currentlyPlaying?.setMuted(isMuted)
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                if let livePlayer = self?.currentlyPlaying as? LiveVideoPlayer {
                    let isPlaying = livePlayer.avPlayer.rate > 0.01
                    if isPlaying {
                        livePlayer.play()
                    } else {
                        livePlayer.pause()
                    }
                }

                if RootViewController.instance.presentingViewController == nil {
                    self?.currentlyLivePip = RootViewController.instance.myPip
                }
            }
            .store(in: &cancellables)
    }
}
