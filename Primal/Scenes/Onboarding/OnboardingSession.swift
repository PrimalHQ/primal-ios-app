//
//  OnboardingSession.swift
//  Primal
//
//  Created by Pavle Stevanović on 20.3.24..
//

import Combine
import Kingfisher
import UIKit

struct AccountCreationData {
    var avatar: String = ""
    var banner: String = ""
    var bio: String = ""
    var username: String = ""
    var displayname: String = ""
    var lightningWallet: String = ""
    var nip05: String = ""
    var website: String = ""
}

class OnboardingSession {
    typealias Group = FollowSuggestionsRequest.Response.SuggestionGroup
    typealias Metadata = FollowSuggestionsRequest.Response.Metadata
    
    var avatarURL = "" {
        didSet {
            if let url = URL(string: avatarURL) {
                KingfisherManager.shared.retrieveImage(with: url, completionHandler: nil)
            }
        }
    }
    var bannerURL = "https://m.primal.net/HQTd.jpg"
    
    @Published var isUploadingAvatar = false
    @Published var isUploadingBanner = false
    
    @Published var image: UIImage?
    @Published var bannerImage: UIImage?
    @Published var isUploading = false
    
    @Published var suggestionGroups: [OnboardingSession.Group] = []
    var userMetadata: [String: Metadata] = [:]
    
    @Published var defaultRelays: [String] = bootstrap_relays
    
    var promoCode: String?
    
    var usersToFollow: Set<String> = []
    
    var cancellables: Set<AnyCancellable> = []
    
    static weak var instance: OnboardingSession?
    
    let newUserKeypair: NostrKeypair
    
    init() {
        guard let keypair = NostrKeypair.generate() else {
            fatalError("Unable to generate a new keypair, this shouldn't be possible")
        }
        
        newUserKeypair = keypair
        Self.instance = self
        
        Publishers.CombineLatest($isUploadingAvatar, $isUploadingBanner)
            .map { $0 || $1 }
            .assign(to: \.isUploading, onWeak: self)
            .store(in: &cancellables)
        
        FollowSuggestionsRequest().publisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion  in
                print(completion)
            }, receiveValue: { [weak self] response in
                self?.suggestionGroups = response.suggestions
                self?.userMetadata = response.metadata
            })
            .store(in: &cancellables)
        
        SocketRequest(name: "get_default_relays", payload: nil).publisher()
            .sink { result in
                guard let relays = result.messageArray else { return }
                
                self.defaultRelays = relays
            }
            .store(in: &cancellables)
        
        if let url = URL(string: bannerURL) {
            KingfisherManager.shared.retrieveImage(with: url, completionHandler: nil)
        }
    }
    
    func addPhoto(controller: UIViewController) {
        ImagePickerManager(controller) { [weak self] result in
            guard let self = self, let (image, _) = result.image else { return }
            self.image = image
            self.isUploadingAvatar = true
            
            UploadAssetRequest(asset: result).publisher().receive(on: DispatchQueue.main).sink(receiveCompletion: { [weak self] in
                self?.isUploadingAvatar = false
                switch $0 {
                case .failure(let error):
                    self?.image = nil
                    print(error)
                case .finished:
                    break
                }
            }) { [weak self] urlString in
                self?.avatarURL = urlString
            }
            .store(in: &self.cancellables)
        }
    }
    
    func addBanner(controller: UIViewController) {
        ImagePickerManager(controller) { [weak self] result in
            guard let self = self, let (image, _) = result.image else { return }
            self.bannerImage = image
            self.isUploadingBanner = true
            
            UploadAssetRequest(asset: result).publisher().receive(on: DispatchQueue.main).sink(receiveCompletion: { [weak self] in
                self?.isUploadingBanner = false
                switch $0 {
                case .failure(let error):
                    self?.bannerImage = nil
                    print(error)
                case .finished:
                    break
                }
            }) { [weak self] urlString in
                self?.bannerURL = urlString
            }
            .store(in: &cancellables)
        }
    }
}
