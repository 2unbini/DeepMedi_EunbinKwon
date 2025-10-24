//
//  StatusBadgeView.swift
//  DeepMediAssignmentApp
//
//  Created by 권은빈 on 2025.10.24.
//

import UIKit
import SnapKit

final class StatusBadgeView: UIView {
    private let imageView = UIImageView()

    init() {
        super.init(frame: .zero)
        setup()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFit

        imageView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
            make.width.equalTo(44)
        }
    }

    func configure(status: Status) {
        imageView.image = UIImage(named: status.assetName)
    }
}
