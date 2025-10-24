//
//  StatusRules.swift
//  DeepMediAssignmentApp
//
//  Created by 권은빈 on 2025.10.24.
//

import Foundation

enum StatusRules {
    static func status(of type: MetricType, value: Double) -> Status {
        switch type {
        case .d1:
            if value < 100 { return .danger }
            if value <= 120 { return .normal }
            if value <= 125 { return .attention }
            if value <= 135 { return .warning }
            return .danger
        case .d2:
            if value < 60 { return .danger }
            if value <= 75 { return .normal }
            if value <= 90 { return .attention }
            if value <= 100 { return .warning }
            return .danger
        case .d3:
            if value < 20 { return .danger}
            if value <= 35 { return .normal }
            if value <= 45 { return .attention }
            if value <= 50 { return .warning }
            return .danger
        case .d4:
            return abs(value) < 1e-9 ? .negative : .positive
        }
    }
}

