//
//  SlotKey.swift
//  DeepMediAssignmentApp
//
//  Created by 권은빈 on 2025.10.20.
//

import Foundation

struct SlotKey: Hashable, Comparable {
    let date: Date

    static func from(date: Date, calendar: Calendar = .current) -> SlotKey {
        let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let normalized = calendar.date(from: comps) ?? date
        return SlotKey(date: normalized)
    }

    static func < (lhs: SlotKey, rhs: SlotKey) -> Bool { lhs.date < rhs.date }
}

