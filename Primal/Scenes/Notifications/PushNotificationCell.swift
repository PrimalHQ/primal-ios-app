//
//  PushNotificationCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 15.4.25..
//

import UIKit

extension UIButton.Configuration {
    static func pushNotificationDismissButton() -> UIButton.Configuration {
        var conf = UIButton.Configuration.filled()
        conf.cornerStyle = .capsule
        conf.attributedTitle = .init("Not now", attributes: .init([
            .font: UIFont.appFont(withSize: 14, weight: .semibold),
            .foregroundColor: UIColor.foreground
        ]))
        conf.baseBackgroundColor = .foreground6
        return conf
    }
    
    static func pushNotificationEnableButton() -> UIButton.Configuration {
        var conf = UIButton.Configuration.filled()
        conf.cornerStyle = .capsule
        conf.attributedTitle = .init("Enable", attributes: .init([
            .font: UIFont.appFont(withSize: 14, weight: .semibold),
            .foregroundColor: UIColor.white
        ]))
        conf.baseBackgroundColor = .accent
        return conf
    }
}

protocol PushNotificationCellDelegate: AnyObject {
    func updatedPushNotificationSettings()
}

class PushNotificationCell: UITableViewCell, Themeable {
    
    let titleLabel: UILabel = UILabel("Enable push notifications from Primal", color: .foreground, font: .appFont(withSize: 16, weight: .regular))
    let descLabel: UILabel = UILabel("Get system notifications from Primal. You can also configure this in your system settings.", color: .foreground2, font: .appFont(withSize: 14, weight: .regular))
    
    let dismissButton = UIButton().constrainToSize(width: 100, height: 28)
    let enableButton = UIButton().constrainToSize(width: 100, height: 28)
    let closeButton = UIButton()
    
    weak var delegate: PushNotificationCellDelegate? {
        didSet { updateTheme() }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
                
        let mainStack = UIStackView(axis: .vertical, [
            titleLabel, SpacerView(height: 4),
            descLabel, SpacerView(height: 16),
            UIStackView(arrangedSubviews: [dismissButton, SpacerView(width: 8), enableButton])
        ])
        mainStack.alignment = .leading
        contentView.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 24).pinToSuperview(edges: .top, padding: 12).pinToSuperview(edges: .bottom, padding: 16)
        
        contentView.addSubview(closeButton)
        closeButton.pinToSuperview(edges: [.top, .trailing], padding: 8)
        
        descLabel.numberOfLines = 2
        
        [closeButton, dismissButton].forEach {
            $0.addAction(.init(handler: { [weak self] _ in
                UserDefaults.standard.hideNotificationPermissionForCurrentUser()
                self?.delegate?.updatedPushNotificationSettings()
            }), for: .touchUpInside)
        }
        
        enableButton.addAction(.init(handler: { _ in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
                DispatchQueue.main.async {
                    if granted {
                        UIApplication.shared.registerForRemoteNotifications()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                            guard let tokenData = AppDelegate.shared.pushNotificationsToken else { return }

                            let token = tokenData.map { String(format: "%02.2hhx", $0) }.joined()

                            guard let event = NostrObject.notificationsEnableEvent(token: token) else { return }
                            
                            UserDefaults.standard.notificationEnableEvents.append(event)
                            AppDelegate.shared.updateNotificationsSettings()
                            self?.delegate?.updatedPushNotificationSettings()
                        }
                    } else {
                        UserDefaults.standard.hideNotificationPermissionForCurrentUser()
                        self?.delegate?.updatedPushNotificationSettings()
                    }
                }
            }
        }), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        titleLabel.textColor = .foreground
        descLabel.textColor = .foreground2
        closeButton.tintColor = .foreground5
        
        dismissButton.configuration = .pushNotificationDismissButton()
        enableButton.configuration = .pushNotificationEnableButton()
        
        closeButton.configuration = .simpleImage(.close.withRenderingMode(.alwaysTemplate))
        
        contentView.backgroundColor = .background3
    }
}
