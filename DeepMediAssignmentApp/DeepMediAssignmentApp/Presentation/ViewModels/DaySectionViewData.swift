//
//  DaySectionViewData.swift
//  DeepMediAssignmentApp
//
//  Created by 권은빈 on 2025.10.24.
//

import Foundation
import RxDataSources

struct DaySectionViewData {
    let date: Date
    let title: String
    var items: [SlotViewData]
}

extension DaySectionViewData: SectionModelType {
    typealias Item = SlotViewData
    init(original: DaySectionViewData, items: [SlotViewData]) {
        self = original
        self.items = items
    }
}
