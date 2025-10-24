//
//  SegmentedGaugeView.swift
//  DeepMediAssignmentApp
//
//  Created by 권은빈 on 2025.10.24.
//

import UIKit
import SnapKit

struct MetricScale {
    let min: Double
    let breaks: [Double]
    let max: Double
}

final class SegmentedGaugeView: UIView {
    // 순서: 상태 → 제목 → 값 → 게이지
    private let statusBadge = StatusBadgeView()
    private let statusIcon = StatusIconView()
    private let titleLabel  = UILabel()
    private let valueLabel  = UILabel()

    private let barContainer = UIView()
    private var segmentViews: [UIView] = []

    private let dot = UIView()
    private let meBubble = CalloutBubbleView()

    private let ticksContainer = UIView()
    private var tickLabels: [UILabel] = []
    private var tickCenterXConstraints: [NSLayoutConstraint] = []
    private var dotLeadingConstraint: Constraint!
    private var bubbleCenterXConstraint: Constraint!

    private var metric: MetricType = .d1
    private var scale = MetricScale(min: 0, breaks: [0,0,0], max: 1)
    private var currentValue: Double?

    private let segmentColors: [UIColor] = [.systemBlue, .systemGreen, .systemYellow, .systemRed]
    private let barHeight: CGFloat = 10
    private let dotSize: CGFloat = 20

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setup()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(value: Double, type: MetricType) {
        metric = type
        currentValue = value
        scale = Self.scale(for: type)

        let st = StatusRules.status(of: type, value: value)
        statusBadge.configure(status: st)
        statusIcon.configure(status: st)
        valueLabel.text = formattedValue(type: type, value: value)

        rebuildSegments()
        rebuildTicksIfNeeded()
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard barContainer.bounds.width > 0 else { return }

        let points = [scale.min] + scale.breaks + [scale.max]
        for (i, v) in points.enumerated() where i < tickCenterXConstraints.count {
            tickCenterXConstraints[i].constant = positionX(for: v)
        }

        if let value = currentValue {
            let x = positionX(for: value)
            dotLeadingConstraint.update(offset: x - dotSize/2)
            bubbleCenterXConstraint.update(offset: x)
        }

        bringSubviewToFront(meBubble)
        barContainer.bringSubviewToFront(dot)
    }

    private func setup() {
        addSubview(statusBadge)
        statusBadge.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
        
        addSubview(statusIcon)
        statusIcon.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
        }

        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(statusBadge.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
        }

        valueLabel.font = .systemFont(ofSize: 26, weight: .bold)
        valueLabel.textColor = .label
        addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
        }

        addSubview(barContainer)
        barContainer.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(barHeight)
        }

        dot.backgroundColor = .systemBlue
        dot.layer.cornerRadius = dotSize/2
        dot.layer.borderWidth = 4
        dot.layer.borderColor = UIColor.systemBackground.cgColor
        dot.layer.zPosition = 10
        barContainer.addSubview(dot)
        dot.snp.makeConstraints { make in
            make.centerY.equalTo(barContainer)
            make.size.equalTo(CGSize(width: dotSize, height: dotSize))
            dotLeadingConstraint = make.leading.equalTo(barContainer.snp.leading).constraint
        }

        meBubble.fillColor = .systemBlue
        addSubview(meBubble)
        meBubble.snp.makeConstraints { make in
            make.bottom.equalTo(barContainer.snp.top).offset(-8)
            bubbleCenterXConstraint = make.centerX.equalTo(barContainer.snp.leading).constraint
            make.height.greaterThanOrEqualTo(18)
            make.width.greaterThanOrEqualTo(22)
        }

        addSubview(ticksContainer)
        ticksContainer.snp.makeConstraints { make in
            make.top.equalTo(barContainer.snp.bottom).offset(6)
            make.leading.trailing.equalTo(barContainer)
            make.bottom.equalToSuperview()
            make.height.greaterThanOrEqualTo(14)
        }
    }

    private func rebuildSegments() {
        segmentViews.forEach { $0.removeFromSuperview() }
        segmentViews.removeAll()

        let edges = [scale.min] + scale.breaks + [scale.max]
        var prevRight: ConstraintItem = barContainer.snp.leading

        for i in 0..<4 {
            let seg = UIView()
            seg.backgroundColor = segmentColors[i]
            seg.layer.masksToBounds = true

            barContainer.addSubview(seg)
            segmentViews.append(seg)

            let ratio = CGFloat((edges[i+1] - edges[i]) / (scale.max - scale.min))
            seg.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.leading.equalTo(prevRight)
                make.width.equalTo(barContainer.snp.width).multipliedBy(ratio)
            }
            prevRight = seg.snp.trailing
        }
        segmentViews.last?.snp.makeConstraints { $0.trailing.equalTo(barContainer.snp.trailing) }
        barContainer.layoutIfNeeded()
    }

    private func rebuildTicksIfNeeded() {
        guard tickLabels.isEmpty else { return }
        let points = [scale.min] + scale.breaks + [scale.max]
        for v in points {
            let l = UILabel()
            l.font = .systemFont(ofSize: 11)
            l.textColor = .secondaryLabel
            l.text = formatTick(v)
            l.translatesAutoresizingMaskIntoConstraints = false
            ticksContainer.addSubview(l)

            let cx = l.centerXAnchor.constraint(equalTo: barContainer.leadingAnchor, constant: 0)
            NSLayoutConstraint.activate([
                cx,
                l.topAnchor.constraint(equalTo: ticksContainer.topAnchor),
                l.bottomAnchor.constraint(equalTo: ticksContainer.bottomAnchor)
            ])
            tickLabels.append(l)
            tickCenterXConstraints.append(cx)
        }
    }

    private func positionX(for value: Double) -> CGFloat {
        let clamped = max(scale.min, min(scale.max, value))
        let t = CGFloat((clamped - scale.min) / (scale.max - scale.min))
        return barContainer.bounds.width * t
    }

    private func formatTick(_ v: Double) -> String {
        switch metric {
        case .d1, .d2, .d3: return String(format: "%.0f", v)
        case .d4: return String(format: "%.2f", v)
        }
    }
    private func formattedValue(type: MetricType, value: Double) -> String {
        switch type {
        case .d1, .d2, .d3: return String(format: "%.0f", value)
        case .d4: return String(format: "%.2f", value)
        }
    }

    static func scale(for type: MetricType) -> MetricScale {
        switch type {
        case .d1: return .init(min: 100, breaks: [120, 125, 135], max: 170)
        case .d2: return .init(min: 60, breaks: [75, 90, 100], max: 110)
        case .d3: return .init(min: 20, breaks: [35, 45, 50], max: 70)
        case .d4: return .init(min: 0, breaks: [0.00, 0.20, 0.50], max: 1.00)
        }
    }
}
