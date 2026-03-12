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

struct ParsedSuggestionGroup {
    var name: String
    var coverUrl: String
    var people: [ParsedSuggestionPerson]
}

struct ParsedSuggestionPerson {
    var pubkey: String
    var user: ParsedUser
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
    
    var bannerURL = "https://blossom.primal.net/c15e22a2a8d1c7971f86adc758f944f3cbec6ef791fafd2604d85ee6beadaabb.png"
    
    @Published var isUploadingAvatar = false
    @Published var isUploadingBanner = false
    
    @Published var image: UIImage?
    @Published var bannerImage: UIImage?
    @Published var isUploading = false
    
    @Published var parsedGroups: [ParsedSuggestionGroup] = []
    
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
                self?.parsedGroups = response.suggestions.map { group in
                    ParsedSuggestionGroup(
                        name: group.name,
                        coverUrl: group.coverUrl,
                        people: group.people.map { person in
                            let nostrContent = response.metadata[person.pubkey].flatMap {
                                NostrContent(kind: Int32($0.kind), content: $0.content, id: $0.id, created_at: Double($0.created_at), pubkey: $0.pubkey, sig: "", tags: [])
                            }
                            let primalUser = PrimalUser(nostrUser: nostrContent) ?? PrimalUser(pubkey: person.pubkey)
                            return ParsedSuggestionPerson(pubkey: person.pubkey, user: ParsedUser(data: primalUser))
                        }
                    )
                }
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
            guard let self = self, let imageRes = result as? ImageMediaPickerResult else { return }

            self.image = imageRes.image
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
            guard let self = self, let imageRes = result as? ImageMediaPickerResult else { return }
            self.bannerImage = imageRes.image
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
