//
//  VideoPlayer.swift
//  Primal
//
//  Created by Pavle Stevanović on 22. 8. 2025..
//

import Combine
import Foundation
import AVKit

class VideoPlayer: NSObject {
    
    var didInitPlayer = false
    
    lazy var avPlayer: AVPlayer = playerWithURL(url)
    
    @Published var isPlaying = false
    
    var shouldPause = false
    
    var url: String
    var userPubkey: String
    var originalURL: String
    
    var live: ParsedLiveEvent?
    var isLive: Bool { live != nil }
    
    var cancellables: Set<AnyCancellable> = []
    
    init(url: String, originalURL: String, userPubkey: String, live: ParsedLiveEvent? = nil) {
        self.url = url
        self.originalURL = originalURL
        self.userPubkey = userPubkey
        self.live = live
        super.init()
        
        if ContentDisplaySettings.autoPlayVideos {
            _ = avPlayer // Force init
        }
    }
    
    deinit {
        
    }
    
    func play() {
        shouldPause = false
        isPlaying = true
        
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
        
        if isLive {
            let player = AVPlayer(url: url)
            player.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
            return player
        }
        
        let player = AVPlayer(url: url)
        player.actionAtItemEnd = .none
        player.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: nil)
        player.isMuted = true
        
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
//            .receive(on: DispatchQueue.main)
            .sink { [weak player] _ in
                player?.seek(to: .zero)
            }
            .store(in: &cancellables)
        
        didInitPlayer = true
        return player
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard
            keyPath == "status", 
            let item = object as? AVPlayerLooper,
            case .failed = item.status
        else { return }
        
        (object as? NSObject)?.removeObserver(self, forKeyPath: "status")
                
        attemptBlossomLoad()
    }
    
    @objc private func playerItemFailed(_ notification: Notification) {
        if let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? NSError {
            print("AVPlayerItemFailedToPlayToEndTime: \(error.localizedDescription)")
        }
        attemptBlossomLoad()
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
        avPlayer.removeObserver(self, forKeyPath: "status")
        avPlayer = .init(playerItem: item)
        url = finalURL.absoluteString
        avPlayer.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: nil)
    }
}
