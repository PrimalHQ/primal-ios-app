//
//  PostCellNantesDelegate.swift
//  Primal
//
//  Created by Pavle Stevanović on 17.5.24..
//

import Foundation
import Nantes

// This is a helper class necessary to prevent retain cycle because delegate in Nantes isn't defined as "weak"
class PostCellNantesDelegate {
    weak var cell: PostCell?
}

extension PostCellNantesDelegate: NantesLabelDelegate {
    func attributedLabel(_ label: NantesLabel, didSelectLink link: URL) {
        guard let cell else { return }
        cell.delegate?.postCellDidTap(cell, .url(link))
    }
}
