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
}
