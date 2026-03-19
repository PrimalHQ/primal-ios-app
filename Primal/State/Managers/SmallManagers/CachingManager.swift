//
//  CachingManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 5.12.23..
//

import Combine
import Foundation
import FLAnimatedImage
import Kingfisher

enum CachingError: Error {
    case unableToLoadWebData
}

struct CacheSizeInfo {
    var imagesBytes: UInt64 = 0
    var gifsBytes: UInt64 = 0
    var databaseBytes: UInt64 = 0
    var urlCacheBytes: UInt64 = 0
    var tempFilesBytes: UInt64 = 0

    var totalBytes: UInt64 { imagesBytes + gifsBytes + databaseBytes + urlCacheBytes + tempFilesBytes }

    var formattedTotal: String {
        ByteCountFormatter.string(fromByteCount: Int64(totalBytes), countStyle: .file)
    }
}

final class CachingManager {

    typealias LoadCallback = (Result<FLAnimatedImage, Error>) -> Void

    static let instance = CachingManager()

    let cache = try? AnimatedImageCache(name: "default")

    @Published var cacheSizeInfo = CacheSizeInfo()
    @Published var isCalculating = false

    var loadingCallbacks: [URL: [LoadCallback]] = [:]

    init() {
        ImageCache.default.diskStorage.config.sizeLimit = 1_500_000_000 // 1.5 GB
    }

    // MARK: - Animated Image Loading

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

    // MARK: - Cache Size Calculation

    func recalculate() {
        guard !isCalculating else { return }
        isCalculating = true

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }

            let dbSize = self.databaseFileSize()
            let urlCacheSize = UInt64(URLCache.shared.currentDiskUsage)
            let tempSize = self.directorySize(at: NSTemporaryDirectory())

            let group = DispatchGroup()

            var imagesSize: UInt64 = 0
            var gifsSize: UInt64 = 0

            group.enter()
            ImageCache.default.calculateDiskStorageSize { result in
                if case .success(let size) = result {
                    imagesSize = UInt64(size)
                }
                group.leave()
            }

            if let gifCache = self.cache {
                group.enter()
                gifCache.calculateDiskStorageSize { result in
                    if case .success(let size) = result {
                        gifsSize = UInt64(size)
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) { [weak self] in
                self?.cacheSizeInfo = CacheSizeInfo(
                    imagesBytes: imagesSize,
                    gifsBytes: gifsSize,
                    databaseBytes: dbSize,
                    urlCacheBytes: urlCacheSize,
                    tempFilesBytes: tempSize
                )
                self?.isCalculating = false
            }
        }
    }

    func clearImageCaches(completion: (() -> Void)? = nil) {
        let group = DispatchGroup()

        group.enter()
        ImageCache.default.clearDiskCache { group.leave() }
        ImageCache.default.clearMemoryCache()

        if let gifCache = cache {
            group.enter()
            gifCache.clearDiskCache { group.leave() }
            gifCache.clearMemoryCache()
        }

        group.notify(queue: .main) { [weak self] in
            completion?()
            self?.recalculate()
        }
    }

    // MARK: - File Size Helpers

    private func databaseFileSize() -> UInt64 {
        let fileManager = FileManager.default
        guard let appSupportURL = try? fileManager.url(
            for: .applicationSupportDirectory, in: .userDomainMask,
            appropriateFor: nil, create: false
        ) else { return 0 }

        let dbDir = appSupportURL.appendingPathComponent("Database", isDirectory: true)
        let files = ["db.sqlite", "db.sqlite-wal", "db.sqlite-shm"]

        var total: UInt64 = 0
        for file in files {
            let path = dbDir.appendingPathComponent(file).path
            if let attrs = try? fileManager.attributesOfItem(atPath: path),
               let size = attrs[.size] as? UInt64 {
                total += size
            }
        }
        return total
    }

    private func directorySize(at path: String) -> UInt64 {
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(atPath: path) else { return 0 }

        var total: UInt64 = 0
        while let file = enumerator.nextObject() as? String {
            let fullPath = (path as NSString).appendingPathComponent(file)
            if let attrs = try? fileManager.attributesOfItem(atPath: fullPath),
               let size = attrs[.size] as? UInt64 {
                total += size
            }
        }
        return total
    }
}
