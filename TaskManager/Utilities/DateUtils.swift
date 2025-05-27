//
//  DateUtils.swift
//  TaskManager
//
//  Created by Santosh Singh on 22/05/25.
//

import Foundation

extension Date {
    func toReadbleFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy 'at' hh:mm a"
        return formatter.string(from: self)
    }
}
