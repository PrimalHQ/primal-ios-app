//
//  AnimatedImageCache.swift
//  Primal
//
//  Created by Pavle Stevanović on 5.12.23..
//

import Foundation
import Kingfisher
import FLAnimatedImage

/// Created on the basis of the Kingfisher image cache

extension FLAnimatedImage: CacheCostCalculable {
    public var cacheCost: Int { Int(size.width * size.height) }
}

private extension String {
    func computedKey(with identifier: String) -> String {
        if identifier.isEmpty {
            return self
        } else {
            return appending("@\(identifier)")
        }
    }
}

struct CacheStoreResult {
    public let memoryCacheResult: Result<(), Never>
    public let diskCacheResult: Result<(), Error>
}

public enum AnimatedImageCacheResult {
    case disk(FLAnimatedImage)
    case memory(FLAnimatedImage)
    case none
    
    public var image: FLAnimatedImage? {
        switch self {
        case .disk(let image): return image
        case .memory(let image): return image
        case .none: return nil
        }
    }
    
    public var cacheType: CacheType {
        switch self {
        case .disk: return .disk
        case .memory: return .memory
        case .none: return .none
        }
    }
}

enum AnimatedImageCacheError: Error {
    case unableToSerialize
}

open class AnimatedImageCache {
    public let memoryStorage: MemoryStorage.Backend<FLAnimatedImage>
    
    public let diskStorage: DiskStorage.Backend<Data>
    
    private let ioQueue: DispatchQueue
    
    public typealias DiskCachePathClosure = (URL, String) -> URL

    public init(
        memoryStorage: MemoryStorage.Backend<FLAnimatedImage>,
        diskStorage: DiskStorage.Backend<Data>)
    {
        self.memoryStorage = memoryStorage
        self.diskStorage = diskStorage
        let ioQueueName = "com.AnimatedImageCache.ioQueue.\(UUID().uuidString)"
        ioQueue = DispatchQueue(label: ioQueueName)

        let notifications: [(Notification.Name, Selector)]
        notifications = [
            (UIApplication.didReceiveMemoryWarningNotification, #selector(clearMemoryCache)),
            (UIApplication.willTerminateNotification, #selector(cleanExpiredDiskCache)),
            (UIApplication.didEnterBackgroundNotification, #selector(backgroundCleanExpiredDiskCache))
        ]
        notifications.forEach {
            NotificationCenter.default.addObserver(self, selector: $0.1, name: $0.0, object: nil)
        }
    }

    public convenience init(
        name: String,
        cacheDirectoryURL: URL? = nil,
        diskCachePathClosure: DiskCachePathClosure? = nil
    ) throws
    {
        if name.isEmpty {
            fatalError("[Kingfisher] You should specify a name for the cache. A cache with empty name is not permitted.")
        }

        let memoryStorage = AnimatedImageCache.createMemoryStorage()

        let config = AnimatedImageCache.createConfig(
            name: name, cacheDirectoryURL: cacheDirectoryURL, diskCachePathClosure: diskCachePathClosure
        )
        let diskStorage = try DiskStorage.Backend<Data>(config: config)
        self.init(memoryStorage: memoryStorage, diskStorage: diskStorage)
    }

    private static func createMemoryStorage() -> MemoryStorage.Backend<FLAnimatedImage> {
        let totalMemory = ProcessInfo.processInfo.physicalMemory
        let costLimit = totalMemory / 4
        let memoryStorage = MemoryStorage.Backend<FLAnimatedImage>(config:
            .init(totalCostLimit: (costLimit > Int.max) ? Int.max : Int(costLimit)))
        return memoryStorage
    }

    private static func createConfig(
        name: String,
        cacheDirectoryURL: URL?,
        diskCachePathClosure: DiskCachePathClosure? = nil
    ) -> DiskStorage.Config
    {
        var diskConfig = DiskStorage.Config(
            name: name,
            sizeLimit: 0,
            directory: cacheDirectoryURL
        )
        if let closure = diskCachePathClosure {
            diskConfig.cachePathBlock = closure
        }
        return diskConfig
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Storing Images

    func store(_ image: FLAnimatedImage,
                    original: Data? = nil,
                    forKey key: String,
                    toDisk: Bool = true,
                    completionHandler: ((CacheStoreResult) -> Void)? = nil)
    {
        let callbackQueue = CallbackQueue.mainCurrentOrAsync
        
        // Memory storage should not throw.
        memoryStorage.store(value: image, forKey: key, expiration: .never)
        
        guard toDisk else {
            if let completionHandler = completionHandler {
                let result = CacheStoreResult(memoryCacheResult: .success(()), diskCacheResult: .success(()))
                callbackQueue.execute { completionHandler(result) }
            }
            return
        }
        
        ioQueue.async {
            if let data = image.data {
                self.syncStoreToDisk(
                    data,
                    forKey: key,
                    callbackQueue: callbackQueue,
                    expiration: .never,
                    writeOptions: .noFileProtection,
                    completionHandler: completionHandler)
            } else {
                guard let completionHandler = completionHandler else { return }
                
                let diskError = AnimatedImageCacheError.unableToSerialize
                let result = CacheStoreResult(
                    memoryCacheResult: .success(()),
                    diskCacheResult: .failure(diskError))
                callbackQueue.execute { completionHandler(result) }
            }
        }
    }
    
    func storeToDisk(
        _ data: Data,
        forKey key: String,
        expiration: StorageExpiration? = nil,
        callbackQueue: CallbackQueue = .untouch,
        completionHandler: ((CacheStoreResult) -> Void)? = nil)
    {
        ioQueue.async {
            self.syncStoreToDisk(
                data,
                forKey: key,
                callbackQueue: callbackQueue,
                expiration: expiration,
                completionHandler: completionHandler)
        }
    }
    
    private func syncStoreToDisk(
        _ data: Data,
        forKey key: String,
        callbackQueue: CallbackQueue = .untouch,
        expiration: StorageExpiration? = nil,
        writeOptions: Data.WritingOptions = [],
        completionHandler: ((CacheStoreResult) -> Void)? = nil)
    {
        let result: CacheStoreResult
        do {
            try self.diskStorage.store(value: data, forKey: key, expiration: expiration, writeOptions: writeOptions)
            result = CacheStoreResult(memoryCacheResult: .success(()), diskCacheResult: .success(()))
        } catch {
            let diskError: KingfisherError
            if let error = error as? KingfisherError {
                diskError = error
            } else {
                diskError = .cacheError(reason: .cannotConvertToData(object: data, error: error))
            }
            
            result = CacheStoreResult(
                memoryCacheResult: .success(()),
                diskCacheResult: .failure(diskError)
            )
        }
        if let completionHandler = completionHandler {
            callbackQueue.execute { completionHandler(result) }
        }
    }

    // MARK: Removing Images
    open func removeImage(forKey key: String,
                          processorIdentifier identifier: String = "",
                          fromMemory: Bool = true,
                          fromDisk: Bool = true,
                          callbackQueue: CallbackQueue = .untouch,
                          completionHandler: (() -> Void)? = nil)
    {
        let computedKey = key.computedKey(with: identifier)

        if fromMemory {
            memoryStorage.remove(forKey: computedKey)
        }
        
        if fromDisk {
            ioQueue.async{
                try? self.diskStorage.remove(forKey: computedKey)
                if let completionHandler = completionHandler {
                    callbackQueue.execute { completionHandler() }
                }
            }
        } else {
            if let completionHandler = completionHandler {
                callbackQueue.execute { completionHandler() }
            }
        }
    }

    open func retrieveImage(
        forKey key: String,
        callbackQueue: CallbackQueue = .mainCurrentOrAsync,
        completionHandler: ((Result<AnimatedImageCacheResult, KingfisherError>) -> Void)?)
    {
        // No completion handler. No need to start working and early return.
        guard let completionHandler = completionHandler else { return }

        // Try to check the image from memory cache first.
        if let image = retrieveImageInMemoryCache(forKey: key) {
            callbackQueue.execute { completionHandler(.success(.memory(image))) }
        } else {
            // Begin to disk search.
            self.retrieveImageInDiskCache(forKey: key, callbackQueue: callbackQueue) {
                result in
                switch result {
                case .success(let image):

                    guard let image = image else {
                        // No image found in disk storage.
                        callbackQueue.execute { completionHandler(.success(.none)) }
                        return
                    }

                    self.store(image, forKey: key, toDisk: false) { _ in
                        callbackQueue.execute { completionHandler(.success(.disk(image))) }
                    }
                case .failure(let error):
                    callbackQueue.execute { completionHandler(.failure(error)) }
                }
            }
        }
    }

    open func retrieveImageInMemoryCache(forKey key: String) -> FLAnimatedImage? { memoryStorage.value(forKey: key, extendingExpiration: .expirationTime(.never)) }

    func retrieveImageInDiskCache(forKey key: String, callbackQueue: CallbackQueue = .untouch, completionHandler: @escaping (Result<FLAnimatedImage?, KingfisherError>) -> Void) {
        let loadingQueue: CallbackQueue = .dispatch(ioQueue)
        loadingQueue.execute {
            do {
                var image: FLAnimatedImage? = nil
                if let data = try self.diskStorage.value(forKey: key, extendingExpiration: .expirationTime(.never)) {
                    image = FLAnimatedImage(gifData: data)
                }
                callbackQueue.execute { completionHandler(.success(image)) }
            } catch let error as KingfisherError {
                callbackQueue.execute { completionHandler(.failure(error)) }
            } catch {
                assertionFailure("The internal thrown error should be a `KingfisherError`.")
            }
        }
    }

    // MARK: Cleaning
    /// Clears the memory & disk storage of this cache. This is an async operation.
    ///
    /// - Parameter handler: A closure which is invoked when the cache clearing operation finishes.
    ///                      This `handler` will be called from the main queue.
    public func clearCache(completion handler: (() -> Void)? = nil) {
        clearMemoryCache()
        clearDiskCache(completion: handler)
    }
    
    /// Clears the memory storage of this cache.
    @objc public func clearMemoryCache() {
        memoryStorage.removeAll()
    }
    
    /// Clears the disk storage of this cache. This is an async operation.
    ///
    /// - Parameter handler: A closure which is invoked when the cache clearing operation finishes.
    ///                      This `handler` will be called from the main queue.
    open func clearDiskCache(completion handler: (() -> Void)? = nil) {
        ioQueue.async {
            do {
                try self.diskStorage.removeAll()
            } catch _ { }
            if let handler = handler {
                DispatchQueue.main.async { handler() }
            }
        }
    }
    
    /// Clears the expired images from memory & disk storage. This is an async operation.
    open func cleanExpiredCache(completion handler: (() -> Void)? = nil) {
        cleanExpiredMemoryCache()
        cleanExpiredDiskCache(completion: handler)
    }

    /// Clears the expired images from disk storage.
    open func cleanExpiredMemoryCache() {
        memoryStorage.removeExpired()
    }
    
    /// Clears the expired images from disk storage. This is an async operation.
    @objc func cleanExpiredDiskCache() {
        cleanExpiredDiskCache(completion: nil)
    }

    /// Clears the expired images from disk storage. This is an async operation.
    ///
    /// - Parameter handler: A closure which is invoked when the cache clearing operation finishes.
    ///                      This `handler` will be called from the main queue.
    open func cleanExpiredDiskCache(completion handler: (() -> Void)? = nil) {
        ioQueue.async {
            do {
                var removed: [URL] = []
                let removedExpired = try self.diskStorage.removeExpiredValues()
                removed.append(contentsOf: removedExpired)

                if !removed.isEmpty {
                    DispatchQueue.main.async {
                        let cleanedHashes = removed.map { $0.lastPathComponent }
                        notify(.KingfisherDidCleanDiskCache, self, userInfo: [KingfisherDiskCacheCleanedHashKey: cleanedHashes])
                    }
                }

                if let handler = handler {
                    DispatchQueue.main.async { handler() }
                }
            } catch {}
        }
    }

    @objc public func backgroundCleanExpiredDiskCache() {
        func endBackgroundTask(_ task: inout UIBackgroundTaskIdentifier) {
            UIApplication.shared.endBackgroundTask(task)
            task = UIBackgroundTaskIdentifier.invalid
        }
        
        var backgroundTask: UIBackgroundTaskIdentifier!
        backgroundTask = UIApplication.shared.beginBackgroundTask {
            endBackgroundTask(&backgroundTask!)
        }
        
        cleanExpiredDiskCache {
            endBackgroundTask(&backgroundTask!)
        }
    }

    func imageCachedType(forKey key: String) -> CacheType
    {
        if memoryStorage.isCached(forKey: key) { return .memory }
        if diskStorage.isCached(forKey: key) { return .disk }
        return .none
    }
    
    public func isCached(forKey key: String) -> Bool { imageCachedType(forKey: key).cached }
    
    open func hash(forKey key: String) -> String { diskStorage.cacheFileURL(forKey: key).lastPathComponent }
    
    open func calculateDiskStorageSize(completion handler: @escaping ((Result<UInt, KingfisherError>) -> Void)) {
        ioQueue.async {
            do {
                let size = try self.diskStorage.totalSize()
                DispatchQueue.main.async { handler(.success(size)) }
            } catch let error as KingfisherError {
                DispatchQueue.main.async { handler(.failure(error)) }
            } catch {
                assertionFailure("The internal thrown error should be a `KingfisherError`.")
            }
        }
    }
    
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    open var diskStorageSize: UInt {
        get async throws {
            try await withCheckedThrowingContinuation { continuation in
                calculateDiskStorageSize { result in
                    continuation.resume(with: result)
                }
            }
        }
    }
    
    open func cachePath(forKey key: String) -> String { diskStorage.cacheFileURL(forKey: key).path }
}
