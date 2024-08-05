//
//  LongFormQuoteView.swift
//  Primal
//
//  Created by Pavle Stevanović on 29.5.24..
//

import UIKit

class LongFormQuoteView: UIStackView, Themeable {
    let label  = UILabel()
    let border = SpacerView(width: 4)
    
    var text: String {
        didSet {
            updateTheme()
        }
    }
    
    init(_ text: String = "") {
        self.text = text
        super.init(frame: .zero)
        
        addArrangedSubview(border)
        addArrangedSubview(label)
        
        spacing = 12
        
        border.layer.cornerRadius = 2
        
        label.numberOfLines = 0
        
        updateTheme()
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        border.backgroundColor = .foreground4
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 6
        
        label.attributedText = NSAttributedString(string: text, attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .foregroundColor: UIColor.foreground,
            .paragraphStyle: paragraph
        ])
    }
}
