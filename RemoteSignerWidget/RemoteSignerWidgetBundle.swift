






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
