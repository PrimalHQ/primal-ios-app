//
//  CachingManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 5.12.23..
//

import Foundation
import FLAnimatedImage

enum CachingError: Error {
    case unableToLoadWebData
}

final class CachingManager {
    
    typealias LoadCallback = (Result<FLAnimatedImage, Error>) -> Void
    
    static let instance = CachingManager()
    
    let cache = try? AnimatedImageCache(name: "default")
    
    var loadingCallbacks: [URL: [LoadCallback]] = [:]
    
    func getAnimatedImage(_ url: URL, callback: @escaping LoadCallback) {
        guard let cache else {
            fetchAnimatedImage(url, callback: callback)
            return
        }
        
        let key = url.absoluteString
        
        cache.retrieveImage(forKey: key) { result in
            if case .success(let res) = result, let image = res.image {
                DispatchQueue.main.async {
                    callback(.success(image))
                }
                return
            }
            self.fetchAnimatedImage(url, callback: callback)
        }
    }
    
    func fetchAnimatedImage(_ url: URL, callback: @escaping LoadCallback) {
        DispatchQueue.main.async {
            self.loadingCallbacks[url, default: []].append(callback)
            
            guard self.loadingCallbacks[url]?.count == 1 else { return }
            
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data, let anim = FLAnimatedImage(gifData: data) else {
                    DispatchQueue.main.async {
                        for callback in self?.loadingCallbacks[url] ?? [] {
                            callback(.failure(CachingError.unableToLoadWebData))
                        }
                        self?.loadingCallbacks[url] = nil
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self?.cache?.store(anim, forKey: url.absoluteString)
                    for callback in self?.loadingCallbacks[url] ?? [] {
                        callback(.success(anim))
                    }
                    self?.loadingCallbacks[url] = nil
                }
            }.resume()
        }
    }
}
