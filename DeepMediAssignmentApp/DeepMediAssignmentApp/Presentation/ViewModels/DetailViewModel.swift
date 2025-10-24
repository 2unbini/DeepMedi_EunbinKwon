//
//  DetailViewModel.swift
//  DeepMediAssignmentApp
//
//  Created by 권은빈 on 2025.10.24.
//

import Foundation

final class DetailViewModel {
    let slot: MergedSlot
    init(slot: MergedSlot) { self.slot = slot }

    var systolic: Double?  { slot.d1 }
    var diastolic: Double? { slot.d2 }

    var dateTitle: String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "yyyy년 MM월 dd일"
        return df.string(from: slot.key.date)
    }

    var measuredTimeText: String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "HH:mm"
        return "\(df.string(from: slot.key.date)) 측정"
    }
}
