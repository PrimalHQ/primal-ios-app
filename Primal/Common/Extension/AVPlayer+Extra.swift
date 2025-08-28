//
//  AVPlayer+Extra.swift
//  Primal
//
//  Created by Pavle Stevanović on 24. 7. 2025..
//

import AVKit

extension AVPlayer {
    /// Seeks 15 seconds backward, respecting the start of the seekable range
    func seek15SecondsBackward() {
        guard let item = currentItem else { return }
        
        let current = currentTime()
        let newTime = CMTimeSubtract(current, CMTime(seconds: 15, preferredTimescale: 600))
        
        let minTime = item.seekableTimeRanges.first?.timeRangeValue.start ?? .zero
        let clampedTime = CMTimeMaximum(newTime, minTime)
        
        seek(to: clampedTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    /// Seeks 15 seconds forward, respecting the end of the seekable range
    func seek30SecondsForward() {
        guard let item = currentItem else { return }
        
        let current = currentTime()
        let newTime = CMTimeAdd(current, CMTime(seconds: 30, preferredTimescale: 600))
        
        let maxTime: CMTime
        if let seekable = item.seekableTimeRanges.last?.timeRangeValue {
            maxTime = CMTimeAdd(seekable.start, seekable.duration)
        } else {
            maxTime = item.duration
        }
        
        let clampedTime = CMTimeMinimum(newTime, maxTime)
        
        seek(to: clampedTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
}

