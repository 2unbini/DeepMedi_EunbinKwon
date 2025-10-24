//
//  DetailGaugeCell.swift
//  DeepMediAssignmentApp
//
//  Created by 권은빈 on 2025.10.24.
//

import UIKit
import SnapKit

final class DetailGaugeCell: UITableViewCell {
    static let reuseID = "DetailGaugeCell"
    
    private let gauge: SegmentedGaugeView
    private let type: MetricType
    
    init(type: MetricType,
         style: UITableViewCell.CellStyle = .default,
         reuseIdentifier: String? = DetailGaugeCell.reuseID) {
        self.type = type
        self.gauge = SegmentedGaugeView(title: type == .d1 ? "최고 심혈관 분포" : "최저 심혈관 분포")
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layoutIfNeeded()
    }
    
    func setup() {
        selectionStyle = .none
        contentView.addSubview(gauge)
        gauge.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(contentView.snp.width).multipliedBy(0.8)
            make.top.equalToSuperview().offset(18)
            make.bottom.equalToSuperview().offset(-14)
        }
    }
    
    func configure(value: Double) {
        gauge.configure(value: value, type: type)
    }
}
