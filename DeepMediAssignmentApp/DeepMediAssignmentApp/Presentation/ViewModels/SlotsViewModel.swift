//
//  SlotsViewModel.swift
//  DeepMediAssignmentApp
//
//  Created by 권은빈 on 2025.10.24.
//

import Foundation
import RxSwift
import RxCocoa

final class SlotsViewModel {
    struct Input {
        let filterTapped: Observable<Filter>
    }
    struct Output {
        let sections: Driver<[DaySectionViewData]>
        let currentFilter: Driver<Filter>
    }
    
    private let repository: MeasuresRepository
    private let disposeBag = DisposeBag()
    
    private let slotsRelay = BehaviorRelay<[MergedSlot]>(value: [])
    private let filterRelay = BehaviorRelay<Filter>(value: .none)
    
    init(repository: MeasuresRepository) {
        self.repository = repository
        load()
    }
    
    func transform(_ input: Input) -> Output {
        input.filterTapped
            .bind(to: filterRelay)
            .disposed(by: disposeBag)
        
        let filtered = Observable
            .combineLatest(slotsRelay.asObservable(), filterRelay.asObservable())
            .map { slots, filter -> [MergedSlot] in
                guard case let .statuses(set) = filter, !set.isEmpty else { return slots }
                return slots.filter { slot in
                    let pairs: [(MetricType, Double?)] = [
                        (.d1, slot.d1),
                        (.d2, slot.d2),
                        (.d3, slot.d3),
                        (.d4, slot.d4)
                    ]
                    return pairs.contains { (type, v) in
                        guard let v = v else { return false }
                        return set.contains(StatusRules.status(of: type, value: v))
                    }
                }
            }
        
        let sections = filtered
            .map { [weak self] slots -> [DaySectionViewData] in
                guard let self = self else { return [] }
                
                let cal = Calendar.current
                let groups = Dictionary(grouping: slots) { cal.startOfDay(for: $0.key.date) }
                let df = DateFormatter()
                
                df.locale = Locale(identifier: "ko_KR")
                df.dateFormat = "MM월 dd일"
                
                return groups.map { (day, items) in
                    let displays = items
                        .sorted { $0.key.date > $1.key.date }
                        .map { self.makeDisplay(from: $0) }
                    return DaySectionViewData(
                        date: day,
                        title: df.string(from: day),
                        items: displays
                    )
                }
                .sorted { $0.date > $1.date }
            }
            .asDriver(onErrorJustReturn: [])
        
        return Output(sections: sections, currentFilter: filterRelay.asDriver())
    }
    
    private func load() {
        let raw = repository.fetchMeasures().sorted { $0.timestamp < $1.timestamp }
        let merged = merge(rawMeasures: raw)
        slotsRelay.accept(merged.sorted { $0.key.date > $1.key.date })
    }
    
    private func merge(rawMeasures: [RawMeasure]) -> [MergedSlot] {
        var dict: [SlotKey: MergedSlot] = [:]
        let cal = Calendar.current
        
        for m in rawMeasures {
            let key = SlotKey.from(date: m.timestamp, calendar: cal)
            var slot = dict[key] ?? MergedSlot(key: key, d1: nil, d2: nil, d3: nil, d4: nil)
            switch m.type {
            case .d1: slot.d1 = m.value
            case .d2: slot.d2 = m.value
            case .d3: slot.d3 = m.value
            case .d4: slot.d4 = m.value
            }
            dict[key] = slot
        }
        
        let result = dict.values.filter { $0.d1 != nil || $0.d2 != nil }
        return result
    }
}

extension SlotsViewModel {
    
    func makeDisplay(from slot: MergedSlot, d3Unit: String = "") -> SlotViewData {
        let tdf = DateFormatter()
        tdf.locale = Locale(identifier: "ko_KR")
        tdf.dateFormat = "HH:mm"
        let timeText = tdf.string(from: slot.key.date)
        
        let d3Text: String
        let d3Hidden: Bool
        let d3Status: Status
        if let v3 = slot.d3 {
            d3Text = String(format: "%.0f%@", v3, d3Unit.isEmpty ? "" : " \(d3Unit)")
            d3Hidden = false
            d3Status = StatusRules.status(of: .d3, value: v3)
        } else {
            d3Text = "-"
            d3Hidden = true
            d3Status = .normal
        }
        
        // d1/d2 (위험>경고>관심>정상 우선순위 두고 심한 것 대표로 표시)
        let bpText: String
        let bpHidden: Bool
        let bpStatus: Status
        if let d1 = slot.d1, let d2 = slot.d2 {
            bpText = "\(Int(d1)) / \(Int(d2))"
            bpHidden = false
            let s1 = StatusRules.status(of: .d1, value: d1)
            let s2 = StatusRules.status(of: .d2, value: d2)
            bpStatus = StatusPriority.worse(s1, s2)
        } else {
            bpText = "-"
            bpHidden = true
            bpStatus = .normal
        }
        
        let d4Text: String
        let d4Hidden: Bool
        let d4Status: Status
        if let v4 = slot.d4 {
            d4Text = v4 <= 1.0 ? String(format: "%.2f%%", v4 * 100) : String(format: "%.2f%%", v4)
            d4Hidden = false
            d4Status = StatusRules.status(of: .d4, value: v4)
        } else {
            d4Text = "-"
            d4Hidden = true
            d4Status = .negative
        }
        
        return SlotViewData(
            timeText: timeText,
            source: slot,
            d3Row: .init(title: "스트레스 지수", valueText: d3Text, status: d3Status, isHidden: d3Hidden),
            bpRow: .init(title: "심혈관 분포", valueText: bpText,  status: bpStatus, isHidden: bpHidden),
            d4Row: .init(title: "알코올", valueText: d4Text,   status: d4Status, isHidden: d4Hidden)
        )
    }
}
