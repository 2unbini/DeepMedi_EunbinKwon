//
//  DetailViewController.swift
//  DeepMediAssignmentApp
//
//  Created by 권은빈 on 2025.10.24.
//

import UIKit
import SnapKit

final class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let viewModel: DetailViewModel
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var rows: [(MetricType, Double)] = []

    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.dateTitle
        view.backgroundColor = .systemBackground
        setup()
        buildRows()
    }

    private func setup() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(DetailGaugeCell.self, forCellReuseIdentifier: DetailGaugeCell.reuseID)
        tableView.tableHeaderView = makeHeaderView()
        tableView.layoutIfNeeded()
    }

    private func makeHeaderView() -> UIView {
        let container = UIView(frame: .zero)
        let titleLabel = UILabel()
        let timeLabel = UILabel()

        titleLabel.text = "측정 결과"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        timeLabel.text = viewModel.measuredTimeText
        timeLabel.font = .systemFont(ofSize: 14, weight: .medium)
        timeLabel.textColor = .secondaryLabel

        container.addSubview(titleLabel)
        container.addSubview(timeLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(container.snp.leading).offset(24)
            make.top.equalTo(container.snp.top).offset(12)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(8)
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.trailing.lessThanOrEqualTo(container.snp.trailing).offset(-16)
        }
        
        container.snp.makeConstraints { make in
            make.bottom.equalTo(titleLabel.snp.bottom).offset(12)
        }
        
        container.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 52)
        return container
    }

    private func buildRows() {
        rows.removeAll()
        if let v = viewModel.systolic  { rows.append((.d1, v)) }
        if let v = viewModel.diastolic { rows.append((.d2, v)) }
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let (type, value) = rows[indexPath.row]
        let cell = DetailGaugeCell(type: type)
        cell.configure(value: value)
        return cell
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { 150 }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { UITableView.automaticDimension }
}
