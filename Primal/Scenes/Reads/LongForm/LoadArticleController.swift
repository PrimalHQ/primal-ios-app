//
//  LoadArticleController.swift
//  Primal
//
//  Created by Pavle Stevanović on 15.7.24..
//

import Combine
import UIKit

class LoadArticleController: UIViewController, Themeable {
    var articleController: ArticleViewController?
    
    let kind: Int
    let identifier: String
    let pubkey: String
    
    let loadingSpinner = LoadingSpinnerView()
    
    var didLoad = false
    
    var cancellables: Set<AnyCancellable> = []
    
    init(kind: Int, identifier: String, pubkey: String) {
        self.kind = kind
        self.identifier = identifier
        self.pubkey = pubkey
        
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        articleController?.updateTheme()
        view.backgroundColor = .background
        navigationItem.leftBarButtonItem = customBackButton
    }
}

private extension LoadArticleController {
    func setup() {
        load()
        
        view.addSubview(loadingSpinner)
        loadingSpinner.constrainToSize(100).centerToSuperview()
        loadingSpinner.play()
        
        updateTheme()
    }
    
    func load() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
            guard let self, !didLoad else { return }
            load()
        }
        
        SocketRequest(name: "long_form_content_thread_view", payload: [
            "pubkey": .string(pubkey),
            "identifier": .string(identifier),
            "kind": .number(Double(kind)),
            "limit": 100,
            "user_pubkey": .string(IdentityManager.instance.userHexPubkey)
        ])
        .publisher()
        .receive(on: DispatchQueue.main)
        .sink { [weak self] res in
            guard let self, !didLoad, let content = res.getArticles().first(where: {
                $0.event.pubkey == self.pubkey &&
                $0.event.tags.contains(["d", self.identifier]) &&
                $0.event.kind == Int32(self.kind)
            })
            else { return }
            
            self.didLoad = true
            
            let articleVC = ArticleViewController(content: content)
            articleVC.willMove(toParent: self)
            view.addSubview(articleVC.view)
            articleVC.view.pinToSuperview()
            articleVC.didMove(toParent: self)
            addChild(articleVC)
            
            loadingSpinner.stop()
            loadingSpinner.removeFromSuperview()
        }
        .store(in: &cancellables)
    }
}
