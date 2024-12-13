//
//  MediaTripleCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 13.9.24..
//

import UIKit

protocol MediaTripleCellDelegate: AnyObject {
    func cellDidSelectImage(_ cell: MediaTripleCell, imageIndex: Int)
}

class MediaView: UIView {
    let imageView = MenuImageView()
    let timeLabel = UILabel()
    let videoIcon = UIImageView(image: UIImage(named: "videoIcon"))
    let multipleIcon = UIImageView(image: UIImage(named: "multipleImagesIcon"))
    
    init() {
        super.init(frame: .zero)
        
        addSubview(imageView)
        imageView.pinToSuperview()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true

        let topStack = UIStackView([videoIcon, multipleIcon])
        addSubview(topStack)
        topStack.pinToSuperview(edges: [.top, .trailing], padding: 4)
        topStack.alignment = .center
        
        addSubview(timeLabel)
        timeLabel.pinToSuperview(edges: [.bottom, .leading], padding: 2).constrainToSize(height: 16)
        timeLabel.layer.cornerRadius = 4
        timeLabel.font = .appFont(withSize: 12, weight: .medium)
        timeLabel.textAlignment = .center
        timeLabel.backgroundColor = .black.withAlphaComponent(0.7)
        timeLabel.textColor = .white
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setImage(_ resources: [MediaMetadata.Resource], thumbnails: [String: String]) {
        guard let resource = resources.first else {
            removeImage()
            return
        }
        
        timeLabel.isHidden = true
        multipleIcon.isHidden = resources.count == 1
        
        imageView.url = resource.url
        if resource.url.isVideoURL {
            imageView.kf.setImage(with: URL(string: thumbnails[resource.url] ?? ""))
            videoIcon.isHidden = false
        } else {
            imageView.kf.setImage(with: resource.url(for: .small))
            videoIcon.isHidden = true
        }
    }
    
    func removeImage() {
        imageView.url = ""
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        timeLabel.isHidden = true
        multipleIcon.isHidden = true
        videoIcon.isHidden = true
    }
}

class MediaTripleCell: UITableViewCell {
    var imageViews: [MediaView] = [MediaView(), MediaView(), MediaView()]
    
    weak var delegate: MediaTripleCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        imageViews.first?.constrainToAspect(1, priority: .required)
        imageViews.enumerated().forEach { [weak self] (index, imageView) in
            imageView.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
                guard let self else { return }
                delegate?.cellDidSelectImage(self, imageIndex: index)
            }))
            imageView.imageView.delegate = self
        }
        
        let stack = UIStackView(imageViews)
        stack.spacing = 1
        stack.distribution = .fillEqually
        contentView.addSubview(stack)
        stack.pinToSuperview(edges: [.horizontal]).pinToSuperview(edges: .top, padding: 1)
        let botC = stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        botC.priority = .defaultHigh
        botC.isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupMetadata(_ resources: [ParsedContent], delegate: MediaTripleCellDelegate?) {
        self.delegate = delegate
        
        for (index, imageView) in imageViews.enumerated() {
            if let content = resources[safe: index] {
                imageView.backgroundColor = .background4
                imageView.setImage(content.mediaResources, thumbnails: content.videoThumbnails)
            } else {
                imageView.backgroundColor = .clear
                imageView.removeImage()
            }
        }
    }
}

extension MediaTripleCell: MenuImageViewDelegate {
    func imagePreviewTappedFromImageView(_ imageView: MenuImageView) {
        guard let index = imageViews.firstIndex(where: { $0.imageView == imageView }) else { return }
        delegate?.cellDidSelectImage(self, imageIndex: index)
    }
}
