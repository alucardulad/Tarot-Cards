//
//  ConstantsConfig.swift
//  tarot_cards
//
//  Created by alucardulad on 2026/1/21.
//

import Foundation
import SwifterSwift

struct APPConstants {
    struct Color {
        // 原有颜色
        static let titleColor: UIColor = UIColor(hex: "F8F8FF")!
        static let bodyColor: UIColor = UIColor(hex: "F5C518")!
        static let explanationColor: UIColor = UIColor(hex: "7DF9FF")!
        static let btnS: UIColor = UIColor(hex: "0A1F2E")!
        static let btnE: UIColor = UIColor(hex: "003B5C")!
        static let btnT: UIColor = UIColor(hex: "A5F2FF")!

        // 导航栏
        static let navBackgroundColor: UIColor = UIColor(hex: "2D1344")!  // 深紫
        static let navTitleColor: UIColor = .white
        static let navShadowColor: UIColor = UIColor.white.withAlphaComponent(0.1)

        // 底部标签栏
        static let tabBarBackgroundColor: UIColor = UIColor(hex: "2D1344")!
        static let tabBarShadowColor: UIColor = UIColor.black.withAlphaComponent(0.2)

        // 标签图标
        static let tabIconNormal: UIColor = UIColor.white.withAlphaComponent(0.5)
        static let tabIconSelected: UIColor = UIColor(hex: "A5F2FF")!  // 青紫色

        // 标签文字
        static let tabTitleNormal: UIColor = UIColor.white.withAlphaComponent(0.6)
        static let tabTitleSelected: UIColor = UIColor(hex: "A5F2FF")!
    }
}
