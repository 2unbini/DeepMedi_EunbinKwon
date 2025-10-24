//
//  FilterBar.swift
//  DeepMediAssignmentApp
//
//  Created by 권은빈 on 2025.10.24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class FilterBar: UIView {
    private let stack = UIStackView()
    private let disposeBag = DisposeBag()
    
    private let allButton = UIButton(type: .system)
    private var statusButtons: [(status: Status, button: UIButton)] = []
    
    private var selected: Set<Status> = [] {
        didSet { emit() }
    }
    
    private let tapSubject = PublishSubject<Filter>()
    var filterTapped: Observable<Filter> { tapSubject.asObservable() }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setup() {
        backgroundColor = .systemBackground
        addSubview(stack)
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.snp.makeConstraints { make in make.edges.equalToSuperview().inset(12)
        }
        
        configureChip(allButton, title: "전체")
        allButton.addTarget(self, action: #selector(didTapAll), for: .touchUpInside)
        stack.addArrangedSubview(allButton)
        
        let order: [Status] = [.normal, .attention, .warning, .danger, .negative, .positive]
        for st in order {
            let btn = UIButton(type: .system)
            configureChip(btn, title: st.displayText)
            btn.addAction(
                UIAction(handler: { [weak self] _ in self?.toggle(st) }),
                for: .touchUpInside
            )
            stack.addArrangedSubview(btn)
            statusButtons.append((st, btn))
        }
        reflect(filter: .none)
    }
    
    private func configureChip(_ btn: UIButton, title: String) {
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        btn.layer.cornerRadius = 8
        btn.backgroundColor = .secondarySystemBackground
    }
    
    @objc private func didTapAll() {
        selected.removeAll()
        reflect(filter: .none)
        emit()
    }
    
    private func toggle(_ st: Status) {
        if selected.contains(st) { selected.remove(st) } else { selected.insert(st) }
        reflect(filter: .statuses(selected))
    }
    
    private func emit() { tapSubject.onNext(.statuses(selected)) }
    
    func reflect(filter: Filter) {
        let activeSet: Set<Status>
        if case let .statuses(set) = filter { activeSet = set } else { activeSet = [] }
        
        allButton.backgroundColor = activeSet.isEmpty ? UIColor.systemGray4 : UIColor.secondarySystemBackground
        
        for (st, btn) in statusButtons {
            let isActive = activeSet.contains(st)
            btn.backgroundColor = isActive ? UIColor.systemGray4 : UIColor.secondarySystemBackground
        }
    }
}
