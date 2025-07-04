//
//  MainThreadElementTextCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 11.12.24..
//

import Foundation

import UIKit
import Nantes

class MainThreadElementTextCell: ThreadElementBaseCell, RegularFeedElementCell {
    static var cellID: String { "FeedElementTextCell" }
    
    var useShortText: Bool { true }
        
    let selectionTextView = UITextView()
    
    var heightC: NSLayoutConstraint?
    
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(position: .main, style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func update(_ parsedContent: ParsedContent) {
//        mainLabel.attributedText = parsedContent.attributedText
        selectionTextView.attributedText = parsedContent.attributedText
        
        heightC?.isActive = false
        
        heightC = selectionTextView.heightAnchor.constraint(equalToConstant: parsedContent.attributedText.heightForWidth(UIScreen.main.bounds.width - 24) + 20)
        heightC?.priority = .defaultHigh
        heightC?.isActive = true
        
        updateTheme()
    }
    
    override func updateTheme() {
        super.updateTheme()
        
//        mainLabel.font = UIFont.appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular)
    }
}

private extension MainThreadElementTextCell {
    func setup() {
//        secondRow.addSubview(mainLabel)
//        mainLabel
//            .pinToSuperview(edges: .horizontal)
//            .pinToSuperview(edges: .bottom, padding: 5)
//            .pinToSuperview(edges: .top, padding: 8)
        
        secondRow.addSubview(selectionTextView)
        selectionTextView
            .pinToSuperview(edges: .horizontal, padding: -5)
            .pinToSuperview(edges: .top, padding: 3)
            .pinToSuperview(edges: .bottom, padding: -5)
    
        selectionTextView.backgroundColor = .clear
        selectionTextView.linkTextAttributes = [:]
        selectionTextView.isEditable = false
        selectionTextView.isScrollEnabled = false
        selectionTextView.delegate = self
        
//        mainLabel.alpha = 0.01
//        mainLabel.numberOfLines = 0
//        mainLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }
}

extension MainThreadElementTextCell: UITextViewDelegate {
    @available(iOS 17.0, *)
    func textView(_ textView: UITextView, primaryActionFor textItem: UITextItem, defaultAction: UIAction) -> UIAction? {
        guard case .link(let url) = textItem.content else { return nil }
        return .init { [weak self] _ in
            self?.delegate?.postCellDidTap(self!, .url(url))
        }
    }
    
    @available(iOS 17.0, *)
    func textView(_ textView: UITextView, menuConfigurationFor textItem: UITextItem, defaultMenu: UIMenu) -> UITextItem.MenuConfiguration? {
        guard case .link(let url) = textItem.content else { return .init(menu: defaultMenu) }
        
        if url.scheme == "hashtag" {
            let hashtag = url.absoluteString.replacing("hashtag://", with: "")
            return UITextItem.MenuConfiguration(preview: .view(HashtagPreviewView(hashtag: hashtag)), menu: .init(children: [
                UIAction(title: "Open \(hashtag) feed", image: UIImage(systemName: "square.stack.fill"), handler: { [weak self] _ in
                    self?.delegate?.postCellDidTap(self!, .url(url))
                }),
                UIAction(title: "Copy hashtag", image: UIImage(named: "MenuCopyText"), handler: { _ in
                    UIPasteboard.general.string = hashtag
                    RootViewController.instance.view?.showToast("Copied!", extraPadding: 0)
                })
            ]))
        }
        
        if url.scheme == "mention" {
            let mention = url.absoluteString.replacing("mention://", with: "")
            
            return UITextItem.MenuConfiguration(preview: .view(ProfilePreviewView(pubkey: mention)), menu: .init(children: [
                UIAction(title: "Open profile", image: UIImage(systemName: "person.crop.circle.fill"), handler: { [weak self] _ in
                    self?.delegate?.postCellDidTap(self!, .url(url))
                }),
                UIAction(title: "Copy pubkey", image: UIImage(named: "MenuCopyText"), handler: { _ in
                    UIPasteboard.general.string = bech32_pubkey(mention) ?? mention
                    RootViewController.instance.view?.showToast("Copied!", extraPadding: 0)
                })
            ]))
        }
        
        if url.scheme == "highlight" {
            let highlight = url.absoluteString.replacingOccurrences(of: "highlight://", with: "")
            
//            return UITextItem.MenuConfiguration(preview: .view(ProfilePreviewView(pubkey: mention)), menu: .init(children: [
//                UIAction(title: "Open Article", image: UIImage(systemName: "person.crop.circle.fill"), handler: { [weak self] _ in
//                    self?.delegate?.postCellDidTap(self!, .url(url))
//                })
//            ]))
            return nil
        }
        
        return .init(preview: .default, menu: defaultMenu)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        delegate?.postCellDidTap(self, .url(URL))
        return false
    }
}
