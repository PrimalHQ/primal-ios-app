//
//  CancelButton.swift
//  Primal
//
//  Created by Pavle D Stevanović on 24.5.23..
//

import UIKit

final class CancelButton: UIButton {
    init() {
        super.init(frame: .zero)
        titleLabel?.font = .appFont(withSize: 16, weight: .medium)
        setTitleColor(.foreground4, for: .normal)
        setTitle("Cancel", for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
