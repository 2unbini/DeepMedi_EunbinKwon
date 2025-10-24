//
//  StatusPriority.swift
//  DeepMediAssignmentApp
//
//  Created by 권은빈 on 2025.10.24.
//

import Foundation

enum StatusPriority {
    static func worse(_ a: Status, _ b: Status) -> Status {
        func rank(_ s: Status) -> Int {
            switch s {
            case .danger: return 3
            case .warning: return 2
            case .attention: return 1
            case .normal: return 0
            case .positive, .negative: return -1
            }
        }
        return rank(a) >= rank(b) ? a : b
    }
}
