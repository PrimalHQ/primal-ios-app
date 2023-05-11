//
//  Date+Extra.swift
//  Primal
//
//  Created by Pavle D Stevanović on 2.5.23..
//

import Foundation

extension Date {
    func timeAgoDisplay() -> String {
        var seconds = Date().timeIntervalSince(self)
        
        let years = Int(seconds / 31622400)
        if years > 0 {
            return "\(years)y"
        }
        
        let months = Int(seconds / 2678400)
        if months > 0 {
            return "\(months)mo"
        }
        
        let days = Int(seconds / 86400)
        if days > 0 {
            return "\(days)d"
        }
        
        let hours = Int(seconds / 3600)
        if hours > 0 {
            return "\(hours)h"
        }
        
        let minutes = Int(seconds / 60)
        if minutes > 0 {
            return "\(minutes)m"
        }
        
        if seconds < 0 {
            return "from future"
        }
        
        return "just now"
    }
}
