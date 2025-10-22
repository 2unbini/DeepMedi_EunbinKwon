//
//  Filter.swift
//  DeepMediAssignmentApp
//
//  Created by 권은빈 on 2025.10.22.
//

import Foundation

/// Multi-select filter (empty set == no filter)
enum Filter: Equatable {
    case statuses(Set<Status>)
    static let none: Filter = .statuses([])
}
