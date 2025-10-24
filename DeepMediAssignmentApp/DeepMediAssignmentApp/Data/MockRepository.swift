//
//  MockRepository.swift
//  DeepMediAssignmentApp
//
//  Created by 권은빈 on 2025.10.24.
//

import Foundation
import RxSwift

protocol MeasuresRepository {
    func fetchMeasures() -> [RawMeasure]
}

final class MockRepository: MeasuresRepository {
    
    private let year: Int
    private let month: Int
    private let timeZone: TimeZone
    private let locale: Locale
    
    // 주입 가능한 더미 원천 (기본값은 DummyData.swift의 전역 상수)
    private let d1: [String: [TargetItem]]
    private let d2: [String: [TargetItem]]
    private let d3: [String: [TargetItem]]
    private let d4: [String: [TargetItem]]
    
    init(year: Int, month: Int,
         timeZone: TimeZone = TimeZone(identifier: "Asia/Seoul")!,
         locale: Locale = Locale(identifier: "ko_KR"),
         d1: [String: [TargetItem]] = d1Data,
         d2: [String: [TargetItem]] = d2Data,
         d3: [String: [TargetItem]] = d3Data,
         d4: [String: [TargetItem]] = d4Data) {
        self.year = year
        self.month = month
        self.timeZone = timeZone
        self.locale = locale
        self.d1 = d1; self.d2 = d2; self.d3 = d3; self.d4 = d4
    }
    
    func fetchMeasures() -> [RawMeasure] {
        var all: [RawMeasure] = []
        all += mapDictToRaw(metricType: .d1, dict: d1)
        all += mapDictToRaw(metricType: .d2, dict: d2)
        all += mapDictToRaw(metricType: .d3, dict: d3)
        all += mapDictToRaw(metricType: .d4, dict: d4)
        return all.sorted { $0.timestamp < $1.timestamp }
    }
    
    private func mapDictToRaw(
        metricType: MetricType,
        dict: [String: [TargetItem]]
    ) -> [RawMeasure] {
        var results: [RawMeasure] = []
        for (dayKey, items) in dict {
            guard let day = parseDay(from: dayKey) else { continue }
            for it in items {
                if let date = buildDate(day: day, timeString: it.measureTime) {
                    results.append(RawMeasure(type: metricType, value: it.value, timestamp: date))
                }
            }
        }
        return results
    }
    
    private func parseDay(from key: String) -> Int? {
        Int(key.split(separator: " ").first ?? "")
    }
    
    private func buildDate(day: Int, timeString: String) -> Date? {
        let fmts = ["HH:mm:ss.SSSZ", "HH:mm:ssZ"]
        var cal = Calendar(identifier: .gregorian)
        cal.locale = locale
        cal.timeZone = timeZone
        
        for f in fmts {
            let df = DateFormatter()
            df.locale = locale
            df.timeZone = timeZone
            df.dateFormat = f
            if let t = df.date(from: timeString) {
                let comps = cal.dateComponents(in: timeZone, from: t)
                var final = DateComponents()
                final.calendar = cal
                final.timeZone = timeZone
                final.year = year; final.month = month; final.day = day
                final.hour = comps.hour; final.minute = comps.minute
                final.second = comps.second; final.nanosecond = comps.nanosecond
                return cal.date(from: final)
            }
        }
        return nil
    }
}
