//
//  UITableView+Extra.swift
//  Primal
//
//  Created by Pavle Stevanović on 1.11.24..
//

import UIKit

extension UITableView {
    func isCellFullyVisible(indexPath: IndexPath) -> Bool {
        let cellRect = rectForRow(at: indexPath)
        let fullyVisibleRect = convert(cellRect, to: superview)
        return frame.contains(fullyVisibleRect)
    }
    
    func cellForScreenshot(at indexPath: IndexPath) -> UITableViewCell? {
        if let cell = cellForRow(at: indexPath) { return cell }
        
        guard let cell = dataSource?.tableView(self, cellForRowAt: indexPath) else { return nil }
        
        let targetWidth = bounds.width
        // Let Auto Layout figure out the needed height
        let fittingSize = CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height)
        
        let targetHeight = cell.contentView.systemLayoutSizeFitting(
            fittingSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        
        // Apply frame and force a layout pass
        cell.frame = CGRect(x: 0, y: 0, width: targetWidth, height: targetHeight)
        cell.layoutIfNeeded()

        return cell
    }
}
