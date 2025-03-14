//
//  AppDelegate.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.4.23..
//

import Combine
import UIKit
import AVFAudio
import GRDB
import PrimalShared

struct ServerContentSettings: Codable {
    var show_primal_support: Bool
}

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var cancellables: Set<AnyCancellable> = []
    
    static var contentSettings: ServerContentSettings?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        URLCache.shared.diskCapacity = 1_000_000_000
        
        UserDefaults.standard.register(defaults: [
            .autoPlayVideosKey:     true,
            .animatedAvatarsKey:    true,
            .fullScreenFeedKey:     false,
            .autoDarkModeKey:       true,
            .hugeFontKey:           true,
        ])
        
        UserDefaults.standard.removeObject(forKey: .smartContactListKey)
        UserDefaults.standard.removeObject(forKey: .smartContactDefaultListKey)
        UserDefaults.standard.removeObject(forKey: .cachedUsersDefaultsKey)
        UserDefaults.standard.removeObject(forKey: .checkedNipsKey)
        UserDefaults.standard.removeObject(forKey: "isLatestFeedFirstKey")
        
        UITableView.appearance().sectionHeaderTopPadding = 0
        
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        
        PrimalEndpointsManager.instance.checkIfNecessary()
        
        _ = SmartContactsManager.instance
        ArticleWebViewCache.setup()
        
        SocketRequest(name: "client_config", payload: nil).publisher()
            .receive(on: DispatchQueue.main)
            .sink { res in
                guard let settings: ServerContentSettings = res.events.compactMap({ $0["content"]?.stringValue?.decode() }).first else { return }
                Self.contentSettings = settings
            }
            .store(in: &cancellables)

        PrimalInitializer.shared.doInit(appName: "ios", userAgent: "iOS_APP", showLog: false)
        
        let repo = RepositoryFactory.shared.createFeedRepository()
        
        Task {
            do {
                try await repo.fetchConversation(userId: "88cc134b1a65f54ef48acc1df3665063d3ea45f04eab8af4646e561c5ae99079", noteId: "fbd89c5b9a163a46b2441f7f89897cdb7acde5a322ae944ef3e6261f6d0f33a7")
                print("fetched")
            } catch {
                print(error)
            }
        }
        
        
        repo
            .observeConversation(userId: "88cc134b1a65f54ef48acc1df3665063d3ea45f04eab8af4646e561c5ae99079", noteId: "fbd89c5b9a163a46b2441f7f89897cdb7acde5a322ae944ef3e6261f6d0f33a7")
            .toPublisher()
            .sink { obj in
                print(obj)
                
                
                
//                first.nostrUris.first?.referencedUser.
//                PrimalShared.FeedPost
            }
            .store(in: &cancellables)
        
        
        
        return true
    }

    // MARK: - UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
