//
//  ImageGalleryController.swift
//  Primal
//
//  Created by Pavle Stevanović on 8.12.23..
//

import UIKit

protocol ImageGalleryMediaController {
    var media: MediaMetadata.Resource { get }
}

class ImageGalleryController: UIViewController {
    let media: [MediaMetadata.Resource]
    
    let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    let progress: PrimalProgressView = .init()
    
    convenience init(current: String, all: [String] = []) {
        self.init(current: .init(url: current), all: all.map({ .init(url: $0) }))
    }
    
    init(current: MediaMetadata.Resource, all: [MediaMetadata.Resource] = []) {
        media = all
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        overrideUserInterfaceStyle = .dark
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.pinToSuperview()
        pageViewController.didMove(toParent: self)
        
        pageViewController.setViewControllers([controllerForMedia(current)], direction: .forward, animated: false)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        if all.count > 1 {
            progress.numberOfPages = all.count
            progress.currentPage = media.firstIndex(of: current) ?? 0
            view.addSubview(progress)
            progress.pinToSuperview(edges: .bottom, padding: 0, safeArea: true).centerToSuperview(axis: .horizontal)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    func present(from vc: UIViewController, imageView: UIImageView) {
        guard let imageVC = pageViewController.viewControllers?.compactMap({ $0 as? ImageFullScreenViewController }).first else {
            vc.present(self, animated: true)
            return
        }
        imageVC.prepareForAnimation()
        vc.present(self, animated: false) {
            imageVC.animateTransitionFrom(imageView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ImageGalleryController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed, let url = (pageViewController.viewControllers?.first as? ImageGalleryMediaController)?.media, let index = media.firstIndex(of: url) else { return }
        progress.currentPage = index
        UIView.animate(withDuration: 0.1) {
            self.progress.alpha = 1
        }
    }
}

extension ImageGalleryController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard
            let oldMedia = (viewController as? ImageGalleryMediaController)?.media,
            let index = media.firstIndex(of: oldMedia),
            let newMedia = media[safe: index - 1] ?? media.last // we take urls.last so that we achieve carousel effect
        else {
            return nil
        }
        
        return controllerForMedia(newMedia)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard
            let oldImage = (viewController as? ImageGalleryMediaController)?.media,
            let index = media.firstIndex(of: oldImage),
            let newMedia = media[safe: index + 1] ?? media.first // we take urls.first so that we achieve carousel effect
        else {
            return nil
        }
        
        return controllerForMedia(newMedia)
    }
    
    func controllerForMedia(_ media: MediaMetadata.Resource) -> UIViewController {
        if media.url.isVideoURL {
            return ImageGalleryVideoController(media: media)
        }
        return ImageFullScreenViewController(media: media)
    }
}
