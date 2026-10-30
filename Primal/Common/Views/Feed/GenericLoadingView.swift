






import UIKit
import Lottie

class GenericLoadingView: LottieAnimationView, Themeable {
    init() {
        super.init(frame: .zero)
        
        loopMode = .loop
        contentMode = .scaleAspectFill
        clipsToBounds = true
        layer.cornerRadius = 12
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        animation = Theme.current.isDarkTheme ? AnimationType.genericSkeleton.animation : AnimationType.genericSkeletonLight.animation
    }
}
