//
//  PremiumLearnMoreWhyController.swift
//  Primal
//
//  Created by Pavle Stevanović on 7.11.24..
//

import UIKit

class PremiumLearnMoreWhyController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Primal Premium"
        view.backgroundColor = .background
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 6
        paragraph.alignment = .justified
        
        let descLabel = UILabel()
        descLabel.attributedText = .init(string: """
        Become a Nostr power user and help shape the future! Open protocols like Nostr give us the opportunity to regain control over our online lives.
        
        At Primal, we don’t rely on advertising. We don’t monetize user data. Our users are our customers. Our sole focus is to make the best possible product for our users. We open source all our work to help the Nostr ecosystem flourish. By signing up for Primal Premium, you are enabling us to continue building for Nostr.
        
        Be the change you want to see in the world. If you don’t want to be the product, consider being the customer.
        """, attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .foregroundColor: UIColor.foreground3,
            .paragraphStyle: paragraph
        ])
        descLabel.numberOfLines = 0
        
        let stack = UIStackView(axis: .vertical, [
            UILabel("Why Get Primal Premium?", color: .foreground, font: .appFont(withSize: 16, weight: .bold)),
            descLabel,
        ])
        stack.spacing = 10
        view.addSubview(stack)
        stack
            .pinToSuperview(edges: .top, padding: 70, safeArea: true)
            .pinToSuperview(edges: .horizontal, padding: 20)
        
        navigationItem.leftBarButtonItem = customBackButton
    }
}
