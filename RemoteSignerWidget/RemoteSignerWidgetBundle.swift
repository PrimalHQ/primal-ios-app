//
//  RemoteSignerWidgetBundle.swift
//  RemoteSignerWidget
//
//  Created by Pavle Stevanović on 15. 12. 2025..
//

import WidgetKit
import SwiftUI

@main
struct RemoteSignerWidgetBundle: WidgetBundle {
    var body: some Widget {
        RemoteSignerWidgetLiveActivity()
    }
}

extension UIColor {
    static var gradient: [UIColor] { [] }
}
