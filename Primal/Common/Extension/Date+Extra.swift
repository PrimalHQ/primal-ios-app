//
//  Date+Extra.swift
//  Primal
//
//  Created by Pavle D Stevanović on 2.5.23..
//

import Foundation

extension Date {
    func timeAgoDisplay(addAgo: Bool = false) -> String {
        let seconds = Date().timeIntervalSince(self)
        
        let years = Int(seconds / 31622400)
        if years > 0 {
            if addAgo { return "\(years)y ago" }
            return "\(years)y"
        }
        
        let months = Int(seconds / 2678400)
        if months > 0 {
            if addAgo { return "\(months)mo ago" }
            return "\(months)mo"
        }
        
        let days = Int(seconds / 86400)
        if days > 0 {
            if addAgo { return "\(days)d ago" }
            return "\(days)d"
        }
        
        let hours = Int(seconds / 3600)
        if hours > 0 {
            if addAgo { return  "\(hours)h ago" }
            return "\(hours)h"
        }
        
        let minutes = Int(seconds / 60)
        if minutes > 0 {
            if addAgo { return "\(minutes)m ago" }
            return "\(minutes)m"
        }
        
        if seconds < 0 {
            return "from future"
        }
        
        return "now"
    }
    
    func timeAgoDisplayLong() -> String {
        let seconds = Date().timeIntervalSince(self)
        
        let years = Int(seconds / 31622400)
        if years > 0 {
            return "\(years) year\(years == 1 ? "" : "s") ago"
        }
        
        let months = Int(seconds / 2678400)
        if months > 0 {
            return "\(months) month\(months == 1 ? "" : "s") ago"
        }
        
        let days = Int(seconds / 86400)
        if days > 0 {
            return "\(days) day\(days == 1 ? "" : "s") ago"
        }
        
        let hours = Int(seconds / 3600)
        if hours > 0 {
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        }
        
        let minutes = Int(seconds / 60)
        if minutes > 0 {
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        }
        
        if seconds < 0 {
            return "in the future"
        }
        
        return "now"
    }
    
    func timeInFutureDisplayLong() -> String {
        let seconds = -Date().timeIntervalSince(self)
        
        let years = Int(seconds / 31622400)
        if years > 0 {
            return "in \(years) year\(years == 1 ? "" : "s")"
        }
        
        let months = Int(seconds / 2678400)
        if months > 0 {
            return "in \(months) month\(months == 1 ? "" : "s")"
        }
        
        let days = Int(seconds / 86400)
        if days > 0 {
            return "in \(days) day\(days == 1 ? "" : "s")"
        }
        
        let hours = Int(seconds / 3600)
        if hours > 0 {
            return "in \(hours) hour\(hours == 1 ? "" : "s")"
        }
        
        let minutes = Int(seconds / 60)
        if minutes > 0 {
            return "in \(minutes) minute\(minutes == 1 ? "" : "s")"
        }
        
        if seconds < 0 {
            return "in the past"
        }
        
        return "now"
    }
    
    func daysAgoDisplay() -> String {
        if Calendar.current.isDateInToday(self) {
            return "today".localizedLowercase
        }
        
        if Calendar.current.isDateInYesterday(self) {
            return "yesterday".localizedLowercase
        }

        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEE, MMM dd, YYYY")

        return formatter.string(from: self)
    }
    
    func isOneHourOld() -> Bool {
        let seconds = -timeIntervalSince(.now)
        return seconds < 3600
    }
    
    func is18YearsOld() -> Bool {
        let calendar = Calendar.current
        let now = Date()
        guard let yearsAgo = calendar.date(byAdding: .year, value: -18, to: now) else { return false }
        return self < yearsAgo
    }
}
