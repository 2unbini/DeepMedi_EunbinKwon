//
//  SlotViewData.swift
//  DeepMediAssignmentApp
//
//  Created by 권은빈 on 2025.10.24.
//

import Foundation

struct SlotViewData {
    struct Row {
        let title: String
        let valueText: String
        let status: Status
        let isHidden: Bool
    }
    let timeText: String
    let source: MergedSlot
    let d3Row: Row
    let bpRow: Row
    let d4Row: Row
}
