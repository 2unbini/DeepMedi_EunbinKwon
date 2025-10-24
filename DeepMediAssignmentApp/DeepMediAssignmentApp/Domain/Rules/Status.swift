//
//  Status.swift
//  DeepMediAssignmentApp
//
//  Created by 권은빈 on 2025.10.24.
//

import Foundation

enum Status {
    case normal, attention, warning, danger
    case negative, positive
    
    var displayText: String {
        switch self {
        case .normal: return "정상"
        case .attention: return "관심"
        case .warning: return "경고"
        case .danger: return "위험"
        case .negative: return "음성"
        case .positive: return "양성"
        }
    }
    
    var assetName: String {
        switch self {
        case .normal: return "normalMark"
        case .attention: return "attentionMark"
        case .warning: return "warningMark"
        case .danger: return "dangerMark"
        case .negative: return "negativeMark"
        case .positive: return "positiveMark"
        }
    }
    
    var iconName: String {
        switch self {
        case .normal: return "normal"
        case .attention: return "attention"
        case .warning: return "warning"
        case .danger: return "danger"
        case .negative: return "negative"
        case .positive: return "positive"
        }
    }
    
}
