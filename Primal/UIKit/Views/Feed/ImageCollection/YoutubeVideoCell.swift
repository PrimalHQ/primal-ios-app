//
//  YoutubeVideoCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 4.9.23..
//

import Foundation
import LinkPresentation

final class YoutubeVideoCell: UICollectionViewCell {
    let loadingSpinner = LoadingSpinnerView()
    let videoView = LPLinkView()
    
    var metadataProvider: LPMetadataProvider?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(videoView)
        videoView.pinToSuperview()
        
        contentView.addSubview(loadingSpinner)
        loadingSpinner.constrainToSize(70).centerToSuperview()
        
        contentView.backgroundColor = .background3
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadURL(_ url: String) {
        guard let url: URL = URL(string: url) else { return }

        videoView.isHidden = true
        loadingSpinner.isHidden = false
        loadingSpinner.play()
        
        metadataProvider = LPMetadataProvider()
        metadataProvider?.startFetchingMetadata(for: url) { [weak self] (metadata, error) in
            guard let metadata, let self else { return }
            DispatchQueue.main.async {
                self.videoView.metadata = metadata
                self.videoView.isHidden = false
                
                self.loadingSpinner.stop()
                self.loadingSpinner.isHidden = true
            }
        }
    }
}
