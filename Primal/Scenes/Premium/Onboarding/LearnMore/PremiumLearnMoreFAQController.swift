//
//  PremiumLearnMoreFAQController.swift
//  Primal
//
//  Created by Pavle Stevanović on 19.11.24..
//

import UIKit

class PremiumLearnMoreFAQController: UIViewController {
    let data: [(String, String)] = [
        ("How do I get support?", "Simply email us at support@primal.net and include your Primal Name in the message. Support requests from Premium and Pro users are prioritized and typically handled on the same business day."),
        ("Can I change my Primal Name?", "Yes! If you wish to change your Primal Name, simply use the “Change your Primal Name” option in the Manage Premium section of any Primal app. Your new name will be functional immediately and your old name will be released and available to other users to register."),
        ("Do I have to use my Primal verified name and lightning address?", "No. As a Primal Premium or Pro user you are able to reserve a Primal Name, but you are not required to use it as your nostr verified address (NIP-05), nor the bitcoin lightning address. Simply set any nostr verified address and/or the bitcoin lightning address you wish to use in your Nostr account profile settings."),
        ("I used to be in the Primal Legend tier. Do I get access to Primal Pro now?", "Yes! All Primal Legend users as of June 20, 2025 have been upgraded to Primal Pro—no expiration, no extra cost. It’s our way of thanking you for being an early supporter."),
        ("Do I own my Primal Name indefinitely?", "You have the right to use your Primal Name for the duration of your Primal subscription. After the subscription expires, there is a grace period of 30 days during which your Primal Name will not be available to others to register. Please note that all Primal Names are owned by Primal and rented to users. Primal reserves the right to revoke any name if we determine that the name is trademarked by somebody else, that there is a possible case of impersonation, or for any other case of abuse, as determined by Primal. Please refer to our Terms of Service for details."),
        ("Can I buy multiple Primal Names?", "We are working on adding the capability to manage multiple Primal Names. In the meantime, feel free to reach out to us via support@primal.net and we will try to accommodate."),
        ("Is my payment information associated with my Nostr account?", "No. Primal Premium can be purchased via an iOS App Store in-app purchase, Google Play in-app purchase, or directly over bitcoin lightning via the Primal web app. Regardless of the method of payment, your payment information is not associated with your Nostr account."),
        ("Can I extend my subscription? How does that work?", "Yes, you can extend your subscription using any of the payment methods we support: iOS App Store in-app purchase, Google Play in-app purchase, or directly over bitcoin lightning via the Primal web app. Any payment will extend your subscription by the number of months purchased. For example, if you purchase 3 Months of Primal Premium using the Primal web app, and then subscribe again via your mobile device, your subscription expiry date will be four months in the future, and it will continue to be pushed out with every subsequent monthly payment."),
        ("If I buy Primal Premium on my phone, will I have access to it on the web?", "Yes. Your Primal Premium subscription is assigned to your Nostr account. Therefore, regardless of the way you choose to subscribe, your Primal Premium subscription will be available to you in all Primal apps: web, iOS, Android."),
        ("How does the Nostr contact list backup feature work?", "Primal creates a backup of 100+ most recent versions of your Nostr follow list. If your follow list gets erased or corrupted by another Nostr app, you will be able to restore it using the Contact List Backup tool in the Nostr Tools section for Primal Premium users."),
        ("How does the Nostr account content backup feature work?", "Primal archives the complete history of all your Nostr content. You can rebroadcast any subset of your content to your selected set of relays at any time using the Content Backup tool in the Nostr Tools section for Primal Premium users."),
        ("What other Premium features are coming in the future?", "We are working on a ton of new and exciting features for Primal Premium. We will announce them as we get closer to releasing them. In the meantime, please feel free to reach out and let us know what you would like to see included in Primal Premium. All suggestions are welcome!"),
        ("I’d like to support Primal. Can I do more?", "At Primal, we don’t rely on advertising. We don’t monetize user data. We open source all our work to help the Nostr ecosystem flourish. If you wish to help us continue doing this work, you can purchase a Premium or Pro subscription, or simply leave a 5-star review in the app store. Thank you from the entire Primal Team! 🙏❤️")
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Primal Premium"
        view.backgroundColor = .background
        
        let stack = UIStackView(axis: .vertical, [])
        for (question, answer) in data {
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineSpacing = 6
            paragraph.alignment = .justified
            
            let questionLabel = UILabel()
            questionLabel.numberOfLines = 0
            questionLabel.attributedText = .init(string: question, attributes: [
                .font: UIFont.appFont(withSize: 16, weight: .bold),
                .foregroundColor: UIColor.foreground,
                .paragraphStyle: paragraph
            ])
            stack.addArrangedSubview(questionLabel)
            stack.addArrangedSubview(SpacerView(height: 8))
            
            let descLabel = UILabel()
            descLabel.attributedText = .init(string: answer, attributes: [
                .font: UIFont.appFont(withSize: 16, weight: .regular),
                .foregroundColor: UIColor.foreground3,
                .paragraphStyle: paragraph
            ])
            descLabel.numberOfLines = 0
            
            stack.addArrangedSubview(descLabel)
            stack.addArrangedSubview(SpacerView(height: 30))
        }
        
        let support = UIButton(configuration: .accent("Support Primal", font: .appFont(withSize: 16, weight: .bold)))
        let supportParent = UIView()
        supportParent.addSubview(support)
        support.pinToSuperview(edges: .vertical, padding: 20).centerToSuperview(axis: .horizontal)
        
        stack.addArrangedSubview(supportParent)
        
        let scrollView = UIScrollView()
        scrollView.addSubview(stack)
        stack
            .pinToSuperview(edges: .vertical, padding: 10)
            .pinToSuperview(edges: .horizontal, padding: 20)
        
        view.addSubview(scrollView)
        scrollView.pinToSuperview()
        
        stack.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
        
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentInset = .init(top: 160, left: 0, bottom: 100, right: 0)
        
        support.addAction(.init(handler: { [weak self] _ in
            guard let premiumLearn: PremiumLearnMoreController = self?.findParent() else { return }
            
            premiumLearn.show(PremiumSupportPrimalController(state: WalletManager.instance.premiumState), sender: nil)
        }), for: .touchUpInside)
    }
}
