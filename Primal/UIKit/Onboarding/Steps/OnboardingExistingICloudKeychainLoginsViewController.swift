//
//  OnboardingExistingICloudKeychainLoginsViewController.swift
//  Primal
//
//  Created by Nikola Lukovic on 27.6.23..
//

import Foundation
import UIKit
import Kingfisher

final class OnboardingExistingICloudKeychainLoginsViewController : UIViewController {
    var table = UITableView()
    
    private var primalUsers: [PrimalUser] = [] {
        didSet {
            table.reloadData()
        }
    }
    
    init(primalUsers: [PrimalUser]) {
        super.init(nibName: nil, bundle: nil)
        
        setup()
        self.primalUsers = primalUsers
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension OnboardingExistingICloudKeychainLoginsViewController {
    func setup() {

        let backButton = UIButton()
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.title = "iCloud Keychain keys"
        
        view.backgroundColor = .black
        table.backgroundColor = .black
        
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .singleLine
        table.contentInsetAdjustmentBehavior = .never
        table.sectionHeaderHeight = 70
        
        let buttonParent = UIView()
        let cancelButton = FancyButton(title: "Sign in with nsec instead")
        buttonParent.addSubview(cancelButton)
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
        cancelButton
            .pinToSuperview(edges: .horizontal, padding: 36)
            .pinToSuperview(edges: .top, padding: 20)
            .pinToSuperview(edges: .bottom, padding: 30, safeArea: true)
        
        let stack = UIStackView(arrangedSubviews: [table, buttonParent])
        view.addSubview(stack)
        stack.pinToSuperview(safeArea: true)
        
        stack.axis = .vertical
    }
    
    @objc func cancelButtonPressed() {
        let view = OnboardingSigninController()
        show(view, sender: nil)
    }
}

extension OnboardingExistingICloudKeychainLoginsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        primalUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let primalUser = primalUsers[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = primalUser.name
        
        cell.contentConfiguration = content
        
        return cell
    }
}

extension OnboardingExistingICloudKeychainLoginsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let primalUser = primalUsers[indexPath.row]
        
        guard
            let npub = bech32_pubkey(primalUser.pubkey),
            let nsec = ICloudKeychain.instance.getSavedNsec(npub),
            let _ = self.processLogin(nsec) else {
            print("Error logging in with ICloud keychain nsec/npub")
            return
        }
        
        RootViewController.instance.reset()
    }
    
    private func processLogin(_ text: String) -> Keypair? {
        guard let parsed = parse_key(text), !parsed.is_pub // allow only nsec for now
        else {
            return nil
        }
        
        guard process_login(parsed, is_pubkey: parsed.is_pub) else {
            return nil
        }
        
        guard
            let keypair = get_saved_keypair(),
            (try? bech32_decode(keypair.pubkey_bech32)) != nil
        else {
            showErrorMessage("Unable to decode key.")
            return nil
        }
        
        guard let _ = keypair.privkey_bech32 else {
            showErrorMessage("Unable to decode key.")
            return nil
        }
        
        return keypair
    }
}
