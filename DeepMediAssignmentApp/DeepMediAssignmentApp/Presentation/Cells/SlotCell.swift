//
//  SlotCell.swift
//  DeepMediAssignmentApp
//
//  Created by 권은빈 on 2025.10.24.
//

import UIKit
import SnapKit

final class SlotCell: UITableViewCell {
    static let reuseID = "SlotCell"

    private let card = UIView()

    private let timeLabel = UILabel()

    private let d3Title = UILabel()
    private let d3Value = UILabel()
    private let d3Tag   = StatusBadgeView()
    private let d3Row   = UIStackView()

    private let bpTitle = UILabel()
    private let bpValue = UILabel()
    private let bpTag   = StatusBadgeView()
    private let bpRow   = UIStackView()

    private let d4Title = UILabel()
    private let d4Value = UILabel()
    private let d4Tag   = StatusBadgeView()
    private let d4Row   = UIStackView()

    private let vStack = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .default
        setup()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear

        contentView.addSubview(card)
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = 16
        card.layer.masksToBounds = true
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.systemGray5.cgColor

        card.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(contentView.snp.width).multipliedBy(0.8)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }

        timeLabel.font = .systemFont(ofSize: 13, weight: .medium)
        timeLabel.textColor = .secondaryLabel
        card.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(card.snp.top).offset(10)
            make.leading.equalTo(card.snp.leading).offset(12)
        }

        // 임의 데이터 이름
        func styleTitle(_ l: UILabel) {
            l.font = .systemFont(ofSize: 16, weight: .semibold)
            l.textColor = .secondaryLabel
            l.setContentHuggingPriority(.required, for: .horizontal)
        }
        [d3Title, bpTitle, d4Title].forEach(styleTitle)
        d3Title.text = "스트레스 지수"
        bpTitle.text = "심혈관 분포"
        d4Title.text = "알코올"

        func styleValue(_ l: UILabel) {
            l.font = .systemFont(ofSize: 22, weight: .bold)
            l.textColor = .label
            l.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }
        [d3Value, bpValue, d4Value].forEach(styleValue)

        [d3Row, bpRow, d4Row].forEach {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.spacing = 8
        }
        [(d3Row, d3Title, d3Value, d3Tag),
         (bpRow, bpTitle, bpValue, bpTag),
         (d4Row, d4Title, d4Value, d4Tag)].forEach { row, t, v, tag in
            row.addArrangedSubview(t)
            row.addArrangedSubview(UIView())
            row.addArrangedSubview(v)
            row.addArrangedSubview(tag)
        }

        vStack.axis = .vertical
        vStack.spacing = 16
        [d3Row, bpRow, d4Row].forEach { vStack.addArrangedSubview($0) }
        card.addSubview(vStack)
        vStack.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }

    func configure(display: SlotViewData) {
        timeLabel.text = display.timeText
        d3Row.isHidden = display.d3Row.isHidden
        d3Value.text   = display.d3Row.valueText
        d3Tag.configure(status: display.d3Row.status)

        bpRow.isHidden = display.bpRow.isHidden
        bpValue.text   = display.bpRow.valueText
        bpTag.configure(status: display.bpRow.status)

        d4Row.isHidden = display.d4Row.isHidden
        d4Value.text   = display.d4Row.valueText
        d4Tag.configure(status: display.d4Row.status)
    }
}
