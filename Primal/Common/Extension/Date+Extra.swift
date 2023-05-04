//
//  Date+Extra.swift
//  Primal
//
//  Created by Pavle D Stevanović on 2.5.23..
//

import Foundation

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
