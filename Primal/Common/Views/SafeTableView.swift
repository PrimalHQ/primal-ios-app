//
//  SafeTableView.swift
//  Primal
//
//  Created by Pavle Stevanović on 18. 7. 2025..
//

import UIKit

class SafeTableView: UITableView {

    private var shouldReloadWhenVisible = false

    override func reloadData() {
        guard window != nil else {
            // Defer reload until added to window
            shouldReloadWhenVisible = true
            return
        }

        super.reloadData()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        // When added to window, perform any deferred reload
        if window != nil, shouldReloadWhenVisible {
            shouldReloadWhenVisible = false
            super.reloadData()
        }
    }
}
