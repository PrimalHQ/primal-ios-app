//
//  ReplyPhotoPreviewView.swift
//  Primal
//
//  Created by Pavle Stevanović on 12.5.26..
//

import UIKit
import Photos
import PhotosUI

final class ReplyPhotoPreviewView: UIView {
    static let intrinsicHeight: CGFloat = 240

    var onAssetSelected: ((ImagePickerResult) -> Void)?
    var onRequestPresentingViewController: (() -> UIViewController?)?

    private let headerLabel = UILabel()
    private let collectionView: UICollectionView
    private let chip = UIButton(type: .system)

    private var fetchResult: PHFetchResult<PHAsset>?
    private let cachingImageManager = PHCachingImageManager()
    private let thumbnailSize = CGSize(width: 100, height: 100)
    private var currentStatus: PHAuthorizationStatus = .notDetermined
    private var isObservingLibrary = false

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: Self.intrinsicHeight)
    }

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.itemSize = CGSize(width: 100, height: 100)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: .zero)
        setupViews()
        refreshAuthState()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    deinit {
        if isObservingLibrary {
            PHPhotoLibrary.shared().unregisterChangeObserver(self)
        }
    }

    func refreshAuthState() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        currentStatus = status
        switch status {
        case .authorized:
            headerLabel.text = "Recent photos"
            headerLabel.isUserInteractionEnabled = false
            applyAuthorizedLayout()
            fetchAssets()
            startObservingIfNeeded()
        case .limited:
            headerLabel.text = "Primal has limited access to your photos"
            headerLabel.isUserInteractionEnabled = true
            applyAuthorizedLayout()
            fetchAssets()
            startObservingIfNeeded()
        case .notDetermined, .denied, .restricted:
            applyChipLayout()
            fetchResult = nil
            cachingImageManager.stopCachingImagesForAllAssets()
            collectionView.reloadData()
        @unknown default:
            applyChipLayout()
        }
    }
}

private extension ReplyPhotoPreviewView {
    func setupViews() {
        backgroundColor = .clear

        headerLabel.font = .appFont(withSize: 14, weight: .regular)
        headerLabel.textColor = .foreground
        headerLabel.textAlignment = .center
        headerLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(headerTapped)))

        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.register(ReplyPhotoCell.self, forCellWithReuseIdentifier: ReplyPhotoCell.reuseIdentifier)

        var chipConfig = UIButton.Configuration.filled()
        chipConfig.title = "Allow photo access"
        chipConfig.baseBackgroundColor = .background3
        chipConfig.baseForegroundColor = .foreground
        chipConfig.cornerStyle = .capsule
        chipConfig.contentInsets = .init(top: 8, leading: 16, bottom: 8, trailing: 16)
        var titleAttr = AttributeContainer()
        titleAttr.font = .appFont(withSize: 14, weight: .medium)
        chipConfig.attributedTitle = AttributedString("Allow photo access", attributes: titleAttr)
        chip.configuration = chipConfig
        chip.addAction(.init(handler: { [weak self] _ in self?.chipTapped() }), for: .touchUpInside)
        
        addSubview(headerLabel)
        addSubview(collectionView)
        addSubview(chip)

        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        chip.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            headerLabel.heightAnchor.constraint(equalToConstant: 20),

            collectionView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 36),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 100),

            chip.centerXAnchor.constraint(equalTo: centerXAnchor),
            chip.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
    }

    func applyAuthorizedLayout() {
        headerLabel.isHidden = false
        collectionView.isHidden = false
        chip.isHidden = true
    }

    func applyChipLayout() {
        headerLabel.isHidden = true
        collectionView.isHidden = true
        chip.isHidden = false
    }

    func fetchAssets() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.predicate = NSPredicate(
            format: "mediaType == %d OR mediaType == %d",
            PHAssetMediaType.image.rawValue,
            PHAssetMediaType.video.rawValue
        )
        fetchResult = PHAsset.fetchAssets(with: options)
        collectionView.reloadData()
    }

    func startObservingIfNeeded() {
        guard !isObservingLibrary else { return }
        PHPhotoLibrary.shared().register(self)
        isObservingLibrary = true
    }

    @objc func headerTapped() {
        guard currentStatus == .limited else { return }
        guard let vc = onRequestPresentingViewController?() else { return }
        PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: vc)
    }

    func chipTapped() {
        switch currentStatus {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] _ in
                DispatchQueue.main.async { self?.refreshAuthState() }
            }
        case .denied, .restricted:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        default:
            break
        }
    }

    func handleSelection(at indexPath: IndexPath) {
        guard let asset = fetchResult?.object(at: indexPath.item) else { return }
        guard let cell = collectionView.cellForItem(at: indexPath) as? ReplyPhotoCell else { return }
        cell.showLoading()

        Task { [weak self, weak cell] in
            do {
                let result = try await PHAssetPickerLoader.load(asset: asset)
                await MainActor.run {
                    cell?.hideLoading()
                    self?.onAssetSelected?(result)
                }
            } catch {
                await MainActor.run { cell?.hideLoading() }
            }
        }
    }
}

extension ReplyPhotoPreviewView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fetchResult?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReplyPhotoCell.reuseIdentifier, for: indexPath)
        guard let cell = cell as? ReplyPhotoCell, let asset = fetchResult?.object(at: indexPath.item) else { return cell }

        cell.configure(asset: asset)
        let assetID = asset.localIdentifier
        cell.representedAssetIdentifier = assetID

        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .opportunistic

        cell.imageRequestID = cachingImageManager.requestImage(
            for: asset,
            targetSize: thumbnailSize,
            contentMode: .aspectFill,
            options: options
        ) { [weak cell] image, _ in
            guard let cell, cell.representedAssetIdentifier == assetID else { return }
            cell.setImage(image)
        }

        return cell
    }
}

extension ReplyPhotoPreviewView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleSelection(at: indexPath)
    }
}

extension ReplyPhotoPreviewView: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let assets = indexPaths.compactMap { fetchResult?.object(at: $0.item) }
        guard !assets.isEmpty else { return }
        cachingImageManager.startCachingImages(
            for: assets,
            targetSize: thumbnailSize,
            contentMode: .aspectFill,
            options: nil
        )
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        let assets = indexPaths.compactMap { fetchResult?.object(at: $0.item) }
        guard !assets.isEmpty else { return }
        cachingImageManager.stopCachingImages(
            for: assets,
            targetSize: thumbnailSize,
            contentMode: .aspectFill,
            options: nil
        )
    }
}

extension ReplyPhotoPreviewView: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            guard let oldResult = self.fetchResult else {
                self.refreshAuthState()
                return
            }
            guard let details = changeInstance.changeDetails(for: oldResult) else { return }
            self.fetchResult = details.fetchResultAfterChanges

            if details.hasIncrementalChanges {
                self.collectionView.performBatchUpdates({
                    if let removed = details.removedIndexes, !removed.isEmpty {
                        self.collectionView.deleteItems(at: removed.map { IndexPath(item: $0, section: 0) })
                    }
                    if let inserted = details.insertedIndexes, !inserted.isEmpty {
                        self.collectionView.insertItems(at: inserted.map { IndexPath(item: $0, section: 0) })
                    }
                    if let changed = details.changedIndexes, !changed.isEmpty {
                        self.collectionView.reloadItems(at: changed.map { IndexPath(item: $0, section: 0) })
                    }
                })
            } else {
                self.collectionView.reloadData()
            }
        }
    }
}

final class ReplyPhotoCell: UICollectionViewCell {
    static let reuseIdentifier = "ReplyPhotoCell"

    var representedAssetIdentifier: String?
    var imageRequestID: PHImageRequestID?

    private let imageView = UIImageView()
    private let videoBadge = UIImageView(image: .videoPlay)
    private let loadingOverlay = UIView()
    private let spinner = UIActivityIndicatorView(style: .medium)

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .background3
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        imageView.pinToSuperview()

        videoBadge.contentMode = .scaleAspectFit
        videoBadge.isHidden = true
        contentView.addSubview(videoBadge)
        videoBadge
            .constrainToSize(24)
            .pinToSuperview(edges: .leading, padding: 6)
            .pinToSuperview(edges: .bottom, padding: 6)

        loadingOverlay.backgroundColor = .background.withAlphaComponent(0.5)
        loadingOverlay.isHidden = true
        contentView.addSubview(loadingOverlay)
        loadingOverlay.pinToSuperview()

        spinner.color = .foreground
        spinner.hidesWhenStopped = true
        loadingOverlay.addSubview(spinner)
        spinner.centerToSuperview()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        if let id = imageRequestID {
            PHImageManager.default().cancelImageRequest(id)
            imageRequestID = nil
        }
        representedAssetIdentifier = nil
        imageView.image = nil
        videoBadge.isHidden = true
        hideLoading()
    }

    func configure(asset: PHAsset) {
        videoBadge.isHidden = asset.mediaType != .video
    }

    func setImage(_ image: UIImage?) {
        imageView.image = image
    }

    func showLoading() {
        loadingOverlay.isHidden = false
        spinner.startAnimating()
    }

    func hideLoading() {
        spinner.stopAnimating()
        loadingOverlay.isHidden = true
    }
}
