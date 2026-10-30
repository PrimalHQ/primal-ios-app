






import Foundation
import Nantes


class PostCellNantesDelegate {
    weak var cell: PostCell?
}

extension PostCellNantesDelegate: NantesLabelDelegate {
    func attributedLabel(_ label: NantesLabel, didSelectLink link: URL) {
        guard let cell else { return }
        cell.delegate?.postCellDidTap(cell, .url(link))
    }
}
