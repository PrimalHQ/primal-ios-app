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

class PremiumLearnMoreProController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Primal Pro"
        view.backgroundColor = .background
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 6
        paragraph.alignment = .justified
        
        let descLabel = UILabel()
        descLabel.attributedText = .init(string: """
        Primal Pro is the highest user tier at Primal, designed for content creators and teams. Pro users get access to Primal Studio and gain Legend status on Primal: 
        """, attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .foregroundColor: UIColor.foreground3,
            .paragraphStyle: paragraph
        ])
        descLabel.numberOfLines = 0
        
        let firstDescLabel = UILabel()
        firstDescLabel.attributedText = .init(string: """
        A professional publishing suite for Nostr. Includes authoring tools, media management, smart scheduling, content imports, team collaboration, and content analytics. Available at:
        """, attributes: [
            .font: UIFont.appFont(withSize: 15, weight: .regular),
            .foregroundColor: UIColor.foreground3,
            .paragraphStyle: paragraph
        ])
        firstDescLabel.numberOfLines = 0
        let studioButton = UIButton(configuration: .coloredButton("studio.primal.net", color: .pro), primaryAction: .init(handler: { _ in
            guard let url = URL(string: "https://studio.primal.net") else { return }
            UIApplication.shared.open(url)
        }))
        let firstVStack = UIStackView(axis: .vertical, [
            UILabel("Primal Studio", color: .foreground, font: .appFont(withSize: 16, weight: .semibold)),
            firstDescLabel,
            studioButton
        ])
        firstVStack.alignment = .leading
        
        studioButton.transform = .init(translationX: -12, y: 0)
        
        let firstStack = UIStackView([UIImageView(image: .primalGoldLogo), firstVStack])
        
        let secondDescLabel = UILabel()
        secondDescLabel.attributedText = .init(string: """
        Customizable Legend avatar ring, Legend profile badge and banner, along with the highest level of features, visibility and recognition on Primal.
        """, attributes: [
            .font: UIFont.appFont(withSize: 15, weight: .regular),
            .foregroundColor: UIColor.foreground3,
            .paragraphStyle: paragraph
        ])
        secondDescLabel.numberOfLines = 0
        let secondVStack = UIStackView(axis: .vertical, [
            UILabel("Legend Status", color: .foreground, font: .appFont(withSize: 16, weight: .semibold)),
            secondDescLabel,
        ])
        
        let secondStack = UIStackView([UIImageView(image: .legendPreston), secondVStack])
        [firstStack, secondStack].forEach {
            $0.alignment = .top
            $0.spacing = 18
            $0.isLayoutMarginsRelativeArrangement = true
            $0.insetsLayoutMarginsFromSafeArea = false
            $0.layoutMargins = .init(top: 14, left: 14, bottom: 14, right: 14)
        }
        [firstVStack, secondVStack].forEach { $0.spacing = 4 }
        
        let stack = UIStackView(axis: .vertical, [
            descLabel,
            firstStack,
            secondStack
        ])
        stack.spacing = 10
        view.addSubview(stack)
        stack
            .pinToSuperview(edges: .top, padding: 70, safeArea: true)
            .pinToSuperview(edges: .horizontal, padding: 20)
        
        navigationItem.leftBarButtonItem = customBackButton
    }
}
