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
    
    func timeLeftDisplay() -> String {
        let totalSeconds = Int(timeIntervalSince(Date()))
        guard totalSeconds > 0 else { return "ended" }

        let days = totalSeconds / 86400
        let hours = (totalSeconds % 86400) / 3600
        let minutes = (totalSeconds % 3600) / 60

        var parts: [String] = []
        if days > 0 { parts.append("\(days) day\(days == 1 ? "" : "s")") }
        if hours > 0 { parts.append("\(hours) hour\(hours == 1 ? "" : "s")") }
        if minutes > 0 && days == 0 { parts.append("\(minutes) minute\(minutes == 1 ? "" : "s")") }

        if parts.isEmpty { return "less than a minute left" }
        if parts.count == 1 { return "\(parts[0]) left" }
        return "\(parts[0]) and \(parts[1]) left"
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
    
    func elapsedTimeStringToNow() -> String {
        let endDate = Date()
        let seconds = max(0, Int(endDate.timeIntervalSince(self)))

        switch seconds {
        case 0..<60:
            return "now"

        case 60..<3600:
            let minutes = seconds / 60
            return "\(minutes)m"

        case 3600..<86_400:
            let hours = seconds / 3600
            return "\(hours)h"

        default:
            let days = seconds / 86_400
            return "\(days)d"
        }
    }

}
