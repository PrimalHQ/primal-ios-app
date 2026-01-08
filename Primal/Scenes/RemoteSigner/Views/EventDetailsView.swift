//
//  EventDetailsView.swift
//  Primal
//
//  Created by Pavle Stevanović on 29. 12. 2025..
//

import UIKit
import PrimalShared
import GenericJSON

extension SessionEvent {
    var eventDetails: [(title: String, text: String, copyText: String)] {
        var result: [(String, String, String)] = []
        
        if let encryptEvent = self as? SessionEvent.Encrypt {
            result.append(("Plain text", encryptEvent.plainText ?? "", encryptEvent.plainText ?? ""))
            result.append(("Encrypted text", encryptEvent.encryptedText ?? "", encryptEvent.encryptedText ?? ""))
        }
        if let decryptEvent = self as? SessionEvent.Decrypt {
            result.append(("Plain text", decryptEvent.plainText ?? "", decryptEvent.plainText ?? ""))
            result.append(("Encrypted text", decryptEvent.encryptedText ?? "", decryptEvent.encryptedText ?? ""))
        }
        
        if let readPubkey = self as? SessionEvent.GetPublicKey {
            let pubkey = readPubkey.publicKey ?? ""
            let shortPubkey = pubkey.prefix(12) + "..." + pubkey.suffix(12)
            result.append(("Pubkey", shortPubkey.string, pubkey))
        }
        
        guard
            let signEvent = self as? SessionEvent.SignEvent,
            let json: [String: JSON] = signEvent.signedNostrEventJson?.decode() ?? signEvent.unsignedNostrEventJson.decode()
        else { return result }
        
        if let id = json["id"]?.stringValue {
            let shortId = id.prefix(12) + "..." + id.suffix(12)
            result.append(("ID", shortId.string, id))
        }
        
        if let pubkey = json["pubkey"]?.stringValue {
            let shortPubkey = pubkey.prefix(12) + "..." + pubkey.suffix(12)
            result.append(("Pubkey", shortPubkey.string, pubkey))
        }
        
        if let eventKind = json["kind"]?.doubleValue {
            let intKind = Int(eventKind)
            
            if let kindDesc = RemoteSignerManager.instance.permissionsMap[requestTypeId] {
                result.append(("Event kind", "\(intKind) - \(kindDesc)", "\(intKind)"))
            } else {
                result.append(("Event kind", "\(intKind)", "\(intKind)"))
            }
        }
        
        if let createdAt = json["created_at"]?.doubleValue {
            let intCreatedAt = Int(createdAt)
            result.append(("Created at", "\(intCreatedAt)", "\(intCreatedAt)"))
        }
        
        if let tags = json["tags"]?.arrayValue {
            var text = ""
            
            for tag in tags {
                guard let tagArray = tag.arrayValue else { continue }
                
                var lineText = ""
                
                for (index, tagElement) in tagArray.enumerated() {
                    guard let string = tagElement.stringValue else { continue }
                    
                    if lineText.count > 25 {
                        lineText += ", ..."
                        break
                    }
                    
                    if index != 0 {
                        lineText += ", "
                    }
                    
                    if lineText.count + string.count + 2 <= 35 {
                        if index == 0 {
                            lineText.append("\"\(string.uppercased())\"")
                        } else {
                            lineText.append("\"\(string)\"")
                        }
                    } else {
                        let prefixLength = min(30 - lineText.count, 15)
                        lineText.append("\"\(string.prefix(prefixLength))...\"")
                    }
                }
                
                if !lineText.isEmpty {
                    if text.isEmpty {
                        text.append(lineText)
                    } else {
                        text.append("\n" + lineText)
                    }
                }
            }
            
            if !text.isEmpty {
                result.append(("Tags", text, tags.encodeToString() ?? text))
            }
        }
        
        if let content = json["content"]?.stringValue {
            result.append(("Content", content, content))
        }
        
        if let sig = json["sig"]?.stringValue {
            let shortSig = sig.prefix(12) + "..." + sig.suffix(12)
            result.append(("Pubkey", shortSig.string, sig))
        }
        
        return result
    }
}

class EventDetailsView: UIScrollView, Themeable {
    let contentStack = UIStackView(axis: .vertical, [])
    let parentView = UIView()
    
    var spacers: [UIView] = []
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(event: SessionEvent) {
        super.init(frame: .zero)
        
        addSubview(parentView)
        parentView.pinToSuperview(padding: 20)
        parentView.widthAnchor.constraint(equalTo: widthAnchor, constant: -40).isActive = true
        
        parentView.addSubview(contentStack)
        contentStack.pinToSuperview()
        
        parentView.backgroundColor = .background5
        parentView.clipsToBounds = true
        parentView.layer.cornerRadius = 12
        
        guard let first = event.eventDetails.first else {
            contentStack.addArrangedSubview(SpacerView(height: 0))
            return
        }
        
        contentStack.addArrangedSubview(EventDetailsCopyView(title: first.title, text: first.text, copyText: first.copyText))
        
        for (title, text, copyText) in event.eventDetails.dropFirst() {
            let spacer = SpacerView(height: 1, color: .foreground6)
            spacers.append(spacer)
            contentStack.addArrangedSubview(spacer)
            contentStack.addArrangedSubview(EventDetailsCopyView(title: title, text: text, copyText: copyText))
        }
    }

    func updateTheme() {
        contentStack.arrangedSubviews.forEach { ($0 as? Themeable)?.updateTheme() }
        spacers.forEach { $0.backgroundColor = .foreground6 }
        parentView.backgroundColor = .background5
    }
}

class EventDetailsCopyView: UIView, Themeable {
    let titleLabel = UILabel()
    let textLabel = UILabel()
    let copyButton = UIButton(configuration: .simpleImage(.menuImageCopy))
    
    let text: String
    init(title: String, text: String, copyText: String) {
        self.text = text
        super.init(frame: .zero)
        
        let topStack = UIStackView([titleLabel, copyButton])
        topStack.alignment = .center
        
        let mainStack = UIStackView(axis: .vertical, [topStack, textLabel])
        mainStack.spacing = 6
        
        addSubview(mainStack)
        mainStack.pinToSuperview(edges: .vertical, padding: 12).pinToSuperview(edges: .leading, padding: 16).pinToSuperview(edges: .trailing, padding: 12)
        
        titleLabel.font = .appFont(withSize: 16, weight: .semibold)
        titleLabel.text = title
        
        textLabel.numberOfLines = 0
        
        copyButton.addAction(.init(handler: { [weak self] _ in
            self?.showDimmedToastCentered("Copied!")
            UIPasteboard.general.string = copyText
        }), for: .touchUpInside)
        
        updateTheme()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func updateTheme() {
        titleLabel.textColor = .foreground
        copyButton.tintColor = .foreground3
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10
        textLabel.attributedText = .init(string: text, attributes: [
            .font: UIFont.monospacedSystemFont(ofSize: 14, weight: .bold),
            .foregroundColor: UIColor.foreground3,
            .paragraphStyle: style
        ])
    }
}
