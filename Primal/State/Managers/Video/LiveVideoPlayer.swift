//
//  LiveVideoPlayer.swift
//  Primal
//
//  Created by Pavle Stevanović on 22. 8. 2025..
//

import AVKit
import Combine
import Foundation
import Kingfisher
import MediaPlayer
import UIKit

class LiveVideoPlayer: NSObject, PlayerProtocol {
    func setMuted(_ isMuted: Bool) {
        avPlayer.isMuted = isMuted
        
        updateRemoteControls()
    }
    
    lazy var avPlayer: AVPlayer = makeLivePlayer(url: url)
    
    @Published var isPlaying = false
    
    var shouldPause = false
    
    var url: String
    var live: ParsedLiveEvent
    
    var blocksAutoplay: Bool { true }
    
    var cancellables: Set<AnyCancellable> = []
    
    init(url: String, live: ParsedLiveEvent) {
        self.url = url
        self.live = live
        super.init()
    }
    
    func play() {
        shouldPause = false
        isPlaying = true
        
        avPlayer.play()
        
        VideoPlaybackManager.instance.setAudioSessionCategory(.playback, mode: .moviePlayback)
        
        updateRemoteControls()
        
        VideoPlaybackManager.instance.currentlyPlaying = self
    }
    
    func pause() {
        isPlaying = false
        shouldPause = false
        avPlayer.pause()
        
        clearNowPlayingInfo()
    }
    
    func delayedPause() {
        shouldPause = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
            if self.shouldPause {
                self.pause()
            }
        }
    }
    
}

// MARK: - Private
private extension LiveVideoPlayer {
    func makeLivePlayer(url: String) -> AVPlayer {
        guard let url = URL(string: url) else { return AVPlayer() }
        let player = AVPlayer(url: url)
        player.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
        return player
    }

    func updateRemoteControls() {
        if avPlayer.isMuted {
            clearNowPlayingInfo()
        } else {
            setupNowPlayingInfo()
        }
    }
    
    func clearNowPlayingInfo() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        UIApplication.shared.endReceivingRemoteControlEvents()
    }
    
    func setupNowPlayingInfo() {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = live.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = live.user.data.firstIdentifier
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo

        let urlString = live.event.image.isEmpty ? live.user.profileImage.url : live.event.image
        let imageId = live.event.universalID
        if !urlString.isEmpty, let url = URL(string: urlString) {
            KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
                guard
                    case .success(let value) = result,
                    imageId == self?.live.event.universalID,
                    self?.avPlayer.isMuted != true
                else { return }
                let image = value.image
                let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
        }
    
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true

        commandCenter.togglePlayPauseCommand.isEnabled = false
        commandCenter.nextTrackCommand.isEnabled = false
        commandCenter.previousTrackCommand.isEnabled = false
        commandCenter.changePlaybackPositionCommand.isEnabled = false
        commandCenter.skipForwardCommand.isEnabled = false
        commandCenter.skipBackwardCommand.isEnabled = false
        commandCenter.changePlaybackRateCommand.isEnabled = false
        commandCenter.seekForwardCommand.isEnabled = false
        commandCenter.seekBackwardCommand.isEnabled = false

        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.play()
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
}
