//
//  SlotsViewController.swift
//  DeepMediAssignmentApp
//
//  Created by 권은빈 on 2025.10.24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit

final class SlotsViewController: UIViewController, UITableViewDelegate {
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private var headerContainer = UIView()
    private var headerFilterBar = FilterBar()
    
    private let viewModel: SlotsViewModel
    private let disposeBag = DisposeBag()
    
    private lazy var dataSource = RxTableViewSectionedReloadDataSource<DaySectionViewData>(
        configureCell: { _, tableView, indexPath, display in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: SlotCell.reuseID,
                for: indexPath
            ) as! SlotCell
            cell.configure(display: display)
            return cell
        },
        titleForHeaderInSection: { ds, idx in ds.sectionModels[idx].title }
    )
    
    init(viewModel: SlotsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonDisplayMode = .minimal
        setup()
        setupHeader()
        bind()
    }
    
    private func setup() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaInsets.top)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        tableView.register(SlotCell.self, forCellReuseIdentifier: SlotCell.reuseID)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    private func bind() {
        let input = SlotsViewModel.Input(
            filterTapped: headerFilterBar.filterTapped
        )
        let output = viewModel.transform(input)
        
        output.sections
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(SlotViewData.self)
            .subscribe(onNext: { [weak self] display in
                guard let self = self else { return }
                let vm = DetailViewModel(slot: display.source)
                let vc = DetailViewController(viewModel: vm)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)
        
        output.currentFilter
            .drive(onNext: { [weak self] f in self?.headerFilterBar.reflect(filter: f) })
            .disposed(by: disposeBag)
    }
    
    private func setupHeader() {
        let titleLabel = UILabel()
        titleLabel.text = "측정 기록"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        
        headerContainer.addSubview(titleLabel)
        headerContainer.addSubview(headerFilterBar)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(headerContainer.snp.top).offset(12)
            make.leading.equalTo(headerContainer.snp.leading).offset(24)
        }
        
        headerFilterBar.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalTo(headerContainer.snp.leading)
            make.trailing.equalTo(headerContainer.snp.trailing)
            make.bottom.equalTo(headerContainer.snp.bottom)
        }
        
        let width = view.bounds.width
        let target = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let height = headerContainer.systemLayoutSizeFitting(
            target,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        headerContainer.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        tableView.tableHeaderView = headerContainer
    }
}
