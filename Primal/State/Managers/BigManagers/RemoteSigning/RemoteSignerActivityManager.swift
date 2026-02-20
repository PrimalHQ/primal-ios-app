//
//  RemoteSignerActivityManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 16. 12. 2025..
//

import Combine
import Foundation
import ActivityKit
import AVFAudio

@available(iOS 16.1, *)
class RemoteSignerActivityManager {
    static let instance = RemoteSignerActivityManager()
    
    var isAudioMuted: Bool = UserDefaults.standard.bool(forKey: "remoteSignerIsAudioMutedKey") {
        didSet {
            UserDefaults.standard.set(isAudioMuted, forKey: "remoteSignerIsAudioMutedKey")
        }
    }
    
    var isAudioAllowed: Bool = UserDefaults.standard.bool(forKey: "remoteSignerIsAudioAllowedKey4") {
        didSet {
            UserDefaults.standard.set(isAudioAllowed, forKey: "remoteSignerIsAudioAllowedKey4")
        }
    }

    var lastPlayedIndex: Int = UserDefaults.standard.integer(forKey: "remoteSignerLastPlayedIndexKey") {
        didSet {
            UserDefaults.standard.set(lastPlayedIndex, forKey: "remoteSignerLastPlayedIndexKey")
        }
    }
    
    var currentlyPlaying: Int? {
        if (VideoPlaybackManager.instance.currentlyPlaying as? RemoteSessionAudioPlayer)?.isPlaying == true {
            return lastPlayedIndex
        }
        return nil
    }
    var soundNames = ["Soft Pulse", "Fireplace", "White Noise", "Gentle Rain"]
    
    var currentSongName: String? {
        soundNames[safe: currentlyPlaying]
    }
    
    var connectedApps: [String] {
        let remoteSessions = RemoteSignerManager.instance.activeSessions.map { $0.name ?? "Unknown" }
        
        guard remoteSessions.isEmpty, NwcServiceManager.shared.isServiceActive else { return remoteSessions }
        
        return ["NWC Service"]
    }
    
    lazy var activity: Activity<RemoteSignerWidgetAttributes>? = .activities.first
    
    var cancellables: Set<AnyCancellable> = []
    
    private init() {
        // Have to do async because of an infinite loop when shutting down the app
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
            
            guard let self else { return }
            Publishers.CombineLatest(RemoteSignerManager.instance.isActivePublisher, NwcServiceManager.shared.isServiceActivePublisher)
                .map { $0 || $1 }
                .removeDuplicates()
                .sink { [weak self] isActive in
                    guard let self else { return }
                    if isActive {
                        startSignerActivity()
                        playSong()
                    } else {
                        endSignerActivity()
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    func startSignerActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
            
        guard activity == nil || activity?.activityState != .active else { return }
        
        let attributes = RemoteSignerWidgetAttributes(
            timeStarted: .now,
            isBlue: true
        )

        let initialContentState = RemoteSignerWidgetAttributes.ContentState(
            connectedApps: connectedApps,
            currentlyPlaying: currentSongName,
            isMuted: isAudioMuted
        )

        do {
            activity = try Activity.request(
                attributes: attributes,
                contentState: initialContentState,
                pushType: .none // Use .token if you plan to update via Push Notifications
            )
        } catch {
            print("Error starting activity: \(error.localizedDescription)")
        }
    }
    
    func updateActivity() {
        guard let activity, activity.activityState == .active else { return }
        
        Task {
            await activity.update(using: .init(
                connectedApps: connectedApps,
                currentlyPlaying: currentSongName,
                isMuted: isAudioMuted
            ))
        }
    }
    
    func endSignerActivity() {
        if let remotePlayer = VideoPlaybackManager.instance.currentlyPlaying as? RemoteSessionAudioPlayer {
            VideoPlaybackManager.instance.currentlyPlaying = nil
        }
        
        guard let activity else { return }
        
        let finalState = RemoteSignerWidgetAttributes.ContentState(
            connectedApps: [],
            currentlyPlaying: nil,
            isMuted: isAudioMuted
        )
            
        Task {
            await activity.end(
                using: finalState,
                dismissalPolicy: .immediate // The activity disappears right away
            )
            
            self.activity = nil
            
            print("Live Activity \(activity.id) ended immediately.")
        }
    }
    
    func nextSong() {
        if lastPlayedIndex + 1 < soundNames.count {
            playSong(index: lastPlayedIndex + 1)
        } else {
            playSong(index: 0)
        }
    }
    
    func prevSong() {
        if lastPlayedIndex - 1 >= 0 {
            playSong(index: lastPlayedIndex - 1)
        } else {
            playSong(index: soundNames.count - 1)
        }
    }
    
    func playSong(index: Int? = nil) {
        let index = index ?? lastPlayedIndex
        
        if !isAudioAllowed {
            updateActivity()
            return
        }
        
        guard
            let name = soundNames[safe: index],
            let player = RemoteSessionAudioPlayer(name: name)
        else { return }
        
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        
        lastPlayedIndex = index
        player.play()
        updateActivity()
    }
    
    func toggleMute() {
        guard let remotePlayer = VideoPlaybackManager.instance.currentlyPlaying as? RemoteSessionAudioPlayer else { return }
        
        isAudioMuted.toggle()
        remotePlayer.setMutedCustom(isAudioMuted)
        
        updateActivity()
    }
}

@available(iOS 16.1, *)
class RemoteSessionAudioPlayer: GenericPlayer<AVAudioPlayer> {
    init?(name: String) {
        guard let path = Bundle.main.path(forResource: name, ofType: "mp3") else { return nil }

        let url = URL(fileURLWithPath: path)

        guard let audioPlayer = try? AVAudioPlayer(contentsOf: url) else { return nil }
            
        audioPlayer.numberOfLoops = -1
        audioPlayer.volume = RemoteSignerActivityManager.instance.isAudioMuted ? 0 : 1
        
        super.init(playerInit: { audioPlayer })
    }
    
    override func setMuted(_ isMuted: Bool) {
        // CUSTOM MUTING
    }
    
    func setMutedCustom(_ isMuted: Bool) {
        underlyingPlayer.isMuted = isMuted
    }
    
    override func pause() {
        if VideoPlaybackManager.instance.currentlyPlaying === self { return } // Disable pausing if there isn't something else playing
        super.pause()
        RemoteSignerActivityManager.instance.updateActivity()
    }
}
