//
//  FLAnimatedImage+User.swift
//  Primal
//
//  Created by Pavle Stevanović on 17.5.24..
//

import Foundation
import FLAnimatedImage
import Kingfisher

extension FLAnimatedImageView {
    func setUserImage(_ user: ParsedUser, feed: Bool = true, size: CGSize? = nil, disableAnimated: Bool = false) {
        tag = tag + 1
        
        guard
            !disableAnimated,
            !feed || ContentDisplaySettings.animatedAvatars,
            user.data.picture.hasSuffix("gif"),
            let url = user.profileImage.url(for: .small)
        else {
            let size = size ?? (frame.size.width < 5 ? CGSize(width: 50, height: 50) : frame.size)
            
            kf.setImage(with: user.profileImage.url(for: size.width < 100 ? .small : .medium), placeholder: UIImage(named: "Profile"), options: [
                .processor(DownsamplingImageProcessor(size: size)),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .transition(.fade(0.2))
            ])
            return
        }
        
        kf.cancelDownloadTask()
        image = UIImage(named: "Profile")
        let oldTag = tag

        CachingManager.instance.fetchAnimatedImage(url) { [weak self] result in
            switch result {
            case .success(let image):
                guard self?.tag == oldTag else { return }
                self?.animatedImage = image
            case .failure(let error):
                print(error)
            }
        }
    }
}
