//
//  VideoPlayer.swift
//  Primal
//
//  Created by Pavle Stevanović on 22. 8. 2025..
//

import Foundation
import AVKit

class VideoPlayer: NSObject {
    
    var didInitPlayer = false
    
    private var looper: AVPlayerLooper?
    lazy var avPlayer: AVPlayer = playerWithURL(url)
    
    @Published var isPlaying = false
    
    var shouldPause = false
    
    var url: String
    var userPubkey: String
    var originalURL: String
    
    var live: ParsedLiveEvent?
    var isLive: Bool { live != nil }
    
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
        
        let queuePlayer = AVQueuePlayer()
        
        let item = AVPlayerItem(url: url)
        looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
        
        looper?.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: nil)
        didInitPlayer = true
        queuePlayer.isMuted = true
        return queuePlayer
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
        
        guard let queuePlayer = avPlayer as? AVQueuePlayer else { return }
        
        let item = AVPlayerItem(url: finalURL)
        url = finalURL.absoluteString
        looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
        looper?.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: nil)
    }
}
