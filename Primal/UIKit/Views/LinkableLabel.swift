//
//  LinkableLabel.swift
//  Primal
//
//  Created by Pavle D Stevanović on 26.4.23..
//

import UIKit

protocol LinkableLabelDelegate: AnyObject {
    func didTapURL(_ url: URL)
    func didTapOutsideURL()
}

final class LinkableLabel: UILabel {
    
    var links: [(NSRange, URL)] = []
    weak var delegate: LinkableLabelDelegate?
    
    override var text: String? {
        didSet {
//            updateLinks()
        }
    }
    
    init() {
        super.init(frame: .zero)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setText(_ attributedText: NSAttributedString) {
        
    }
    
}
private extension LinkableLabel {    
    @objc func tapped(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else { return }
        
        for (range, url) in links {
            if didTapAttributedTextInRange(range, gesture: gesture) {
                delegate?.didTapURL(url)
                return
            }
        }
        delegate?.didTapOutsideURL()
    }
    
    func updateLinks() {
        guard
            let input = text,
            let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        else {
            return
        }
        
        links = []
        
        let matches = detector.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
        for match in matches {
            guard let range = Range(match.range, in: input) else { continue }
            let urlString = input[range]
            if let url = URL(string: String(urlString)) {
                links.append((match.range, url))
                print(url)
            }
        }

        let attrString = NSMutableAttributedString(attributedString: attributedText ?? .init(string: input))
        for (range, _) in links {
            attrString.addAttributes([
                .foregroundColor: UIColor(rgb: 0xCA079F)
            ], range: range)
        }
        attributedText = attrString
    }
    
    func didTapAttributedTextInRange(_ targetRange: NSRange, gesture: UITapGestureRecognizer) -> Bool {
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: bounds.size)
        let textStorage = NSTextStorage(attributedString: attributedText!)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = numberOfLines
        let labelSize = bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = gesture.location(in: self)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(
            x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
            y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y
        )
        let locationOfTouchInTextContainer = CGPoint(
            x: locationOfTouchInLabel.x - textContainerOffset.x,
            y: locationOfTouchInLabel.y - textContainerOffset.y
        )
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        return NSLocationInRange(indexOfCharacter, targetRange)
    }

}
