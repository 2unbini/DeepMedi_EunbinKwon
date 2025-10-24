//
//  CalloutBubbleView.swift
//  DeepMediAssignmentApp
//
//  Created by 권은빈 on 2025.10.24.
//

import UIKit

final class CalloutBubbleView: UIView {
    private let label = UILabel()
    var fillColor: UIColor = .label { didSet { setNeedsDisplay() } }
    var triangleSize = CGSize(width: 10, height: 6) { didSet { setNeedsDisplay() } }
    var cornerRadius: CGFloat = 9 { didSet { setNeedsDisplay() } }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let contentHeight = bounds.height - triangleSize.height
        label.frame = CGRect(x: 6, y: 0, width: bounds.width - 12, height: contentHeight)
    }
    
    override var intrinsicContentSize: CGSize {
        let s = label.intrinsicContentSize
        return CGSize(width: max(22, s.width + 12), height: max(18, s.height + triangleSize.height))
    }
    
    override func draw(_ rect: CGRect) {
        let w = rect.width
        let h = rect.height
        let bodyH = h - triangleSize.height
        
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: w, height: bodyH),
                                cornerRadius: cornerRadius)
        let midX = w / 2
        path.move(to: CGPoint(x: midX - triangleSize.width/2, y: bodyH))
        path.addLine(to: CGPoint(x: midX + triangleSize.width/2, y: bodyH))
        path.addLine(to: CGPoint(x: midX, y: h))
        path.close()
        
        fillColor.setFill()
        path.fill()
    }
    
    func setup() {
        label.text = "나"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 13, weight: .bold)
        addSubview(label)
    }
}
