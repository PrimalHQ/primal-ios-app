//
//  PollInputView.swift
//  Primal
//
//  Created by Pavle Stevanović on 25. 2. 2026..
//

import UIKit

class PollInputView: UIView {
    
    let manager: TextViewManager
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(manager: PostingTextViewManager) {
        self.manager = manager
        super.init(frame: .zero)
        
        manager.$pollOptions.sink { poll in
            guard let poll else { return }
            
            
        }
    }
    
}
