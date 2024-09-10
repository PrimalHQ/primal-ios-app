//
//  ArticleChromeManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 29.7.24..
//

import Foundation
import UIKit

class ArticleChromeManager: AppChromeManager {
    override func setBarsToTransform(_ topTransform: CGFloat, _ botTransform: CGFloat) {
        guard let controller = viewController else { return }
        prevTransformTop = topTransform
        prevTransformBot = botTransform
        
        let topTransform = max(topTransform, -topBarHeight)
        let botTransform = min(-botTransform, bottomBarHeight)
        
        controller.navigationController?.navigationBar.transform = .init(translationX: 0, y: topTransform)
        controller.mainTabBarController?.vStack.transform = .init(translationX: 0, y: botTransform)
        
        let botProgress = (botTransform / bottomBarHeight)
        let xScale = 1 - botProgress
        let yScale = min(1, xScale * 1.1)
        let alpha = (1 - (botProgress * 3)).clamp(0, 1)
        
        extraBottomView?.subviews.first?.alpha = alpha
        extraBottomView?.transform = .init(translationX: 0, y: botTransform).scaledBy(x: xScale, y: yScale)
        extraBottomView?.alpha = (xScale * 2.5).clamped(to: 0...1)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        extraTopView?.transform = .init(
            translationX: 0,
            y: (-(viewController?.scrollView.contentOffset.y ?? 0) - 64).clamped(to: -64...96)
        )
    }
}
