//
//  VideoPlaybackManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 29.8.23..
//

import AVFoundation
import UIKit
import Combine
import MediaPlayer
import Kingfisher
import AVKit

final class VideoPlaybackManager: NSObject {
    static let instance = VideoPlaybackManager()
    
    var currentlyLivePip: AVPictureInPictureController? {
        didSet {
            oldValue?.canStartPictureInPictureAutomaticallyFromInline = false
            currentlyLivePip?.canStartPictureInPictureAutomaticallyFromInline = true
        }
    }
    
    var isMuted: Bool {
        get { _isMuted && !liveOverride }
        set {
            _isMuted = newValue
            liveOverride = false
        }
    }
    
    var isMutedPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest($_isMuted, $liveOverride)
            .map { $0 && !$1 }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    @Published private var _isMuted = true
    @Published private var liveOverride = false
    @Published var currentlyPlaying: VideoPlayer? {
        didSet {
            currentlyPlaying?.avPlayer.play()
            guard oldValue != currentlyPlaying else { return }
            oldValue?.pause()
            liveOverride = currentlyPlaying?.isLive == true
        }
    }
    @Published private var avCategory = AVAudioSession.Category.ambient
    
    var isLive: Bool { currentlyPlaying?.isLive == true && currentlyPlaying?.isPlaying == true }
    
    private var cancellables: Set<AnyCancellable> = []
    override init() {
        super.init()
        
        Publishers.CombineLatest(isMutedPublisher, $currentlyPlaying.removeDuplicates())
            .debounce(for: 0.01, scheduler: DispatchQueue.main)
            .sink { [weak self] isMuted, currentlyPlaying in
                
                currentlyPlaying?.avPlayer.isMuted = isMuted
                
                guard let live = currentlyPlaying?.live, !isMuted else {
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
                    UIApplication.shared.endReceivingRemoteControlEvents()
                    self?.avCategory = isMuted ? .ambient : .playback
                    return
                }
                
                UIApplication.shared.beginReceivingRemoteControlEvents()
                self?.avCategory = .playback

                var nowPlayingInfo = [String: Any]()
                nowPlayingInfo[MPMediaItemPropertyTitle] = live.title
                nowPlayingInfo[MPMediaItemPropertyArtist] = live.user.data.firstIdentifier
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                
                let urlString = live.event.image.isEmpty ? live.user.profileImage.url : live.event.image
                let imageId = live.event.universalID
                if !urlString.isEmpty, let url = URL(string: urlString) {
                    KingfisherManager.shared.retrieveImage(with: url) { result in
                        let mngr = VideoPlaybackManager.instance
                        guard case .success(let value) = result, imageId == mngr.currentlyPlaying?.live?.event.universalID, !mngr.isMuted else { return }
                        let image = value.image
                        let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                        nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                    }
                }
            }
            .store(in: &cancellables)
        
        $avCategory.removeDuplicates().sink { category in
            print("SETTING CATEGORY \(category.rawValue) \(category)")
            try? AVAudioSession.sharedInstance().setCategory(category, mode: .moviePlayback)
            try? AVAudioSession.sharedInstance().setActive(true)
        }
        .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                let isPlaying = (self?.currentlyPlaying?.avPlayer.rate ?? 0) > 0.01
                
                if isPlaying {
                    self?.currentlyPlaying?.play()
                } else {
                    self?.currentlyPlaying?.pause()
                }
                
                if RootViewController.instance.presentingViewController == nil {
                    self?.currentlyLivePip = RootViewController.instance.myPip
                }
            }
            .store(in: &cancellables)
        
//        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
//            .delay(for: 0.5, scheduler: DispatchQueue.main)
//            .sink { [weak self] _ in
//                print(self?.currentlyPlaying?.avPlayer.timeControlStatus.rawValue)
//                if self?.currentlyPlaying?.isPlaying == true, self?.currentlyPlaying?.isLive == true {
//                    self?.currentlyPlaying?.avPlayer.play()
//                    print("PLAYING")
//                }
//            }
//            .store(in: &cancellables)
        
        let commandCenter = MPRemoteCommandCenter.shared()

        // Enable only play and pause
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true

        // Disable everything else
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
            self?.currentlyPlaying?.play()
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.currentlyPlaying?.pause()
            return .success
        }
    }
}
