//
//  ImageGalleryController.swift
//  Primal
//
//  Created by Pavle Stevanović on 8.12.23..
//

import UIKit

class ImageGalleryController: UIViewController {
    let urls: [String]
    
    let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    let progress: PrimalProgressView = .init()
    
    init(current: String, all: [String] = []) {
        urls = all
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        overrideUserInterfaceStyle = .dark
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.pinToSuperview()
        pageViewController.didMove(toParent: self)
        
        pageViewController.setViewControllers([ImageFullScreenViewController(url: current)], direction: .forward, animated: false)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        if all.count > 1 {
            progress.numberOfPages = all.count
            progress.currentPage = urls.firstIndex(of: current) ?? 0
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
        guard completed, let url = (pageViewController.viewControllers?.first as? ImageFullScreenViewController)?.url, let index = urls.firstIndex(of: url) else { return }
        progress.currentPage = index
        UIView.animate(withDuration: 0.1) {
            self.progress.alpha = 1            
        }
    }
}

extension ImageGalleryController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard
            let oldImageURL = (viewController as? ImageFullScreenViewController)?.url,
            let index = urls.firstIndex(of: oldImageURL),
            let newUrl = urls[safe: index - 1] ?? urls.last // we take urls.last so that we achieve carousel effect
        else {
            return nil
        }
        
        return ImageFullScreenViewController(url: newUrl)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard
            let oldImageURL = (viewController as? ImageFullScreenViewController)?.url,
            let index = urls.firstIndex(of: oldImageURL),
            let newUrl = urls[safe: index + 1] ?? urls.first // we take urls.first so that we achieve carousel effect
        else {
            return nil
        }
        
        return ImageFullScreenViewController(url: newUrl)
    }
}
