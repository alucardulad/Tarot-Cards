//
//  ThemeManager.swift
//  tarot_cards
//
//  全局颜色主题管理器
//  Created by 陈柔 & 老萨满
//  Date: 2026-02-09
//

import UIKit

/// 全局颜色主题管理器（单例）
class ThemeManager {

    static let shared = ThemeManager()

    private init() {}

    // MARK: - 主题属性

    /// 当前占卜师ID
    private var currentReaderId: String = "reader_chenrou"

    /// 当前占卜师风格类型
    private(set) var currentReaderStyleType: ReaderStyleType = .gentle

    // MARK: - 主题颜色

    /// 主色
    var primaryColor: UIColor {
        return getCurrentReader().primaryColor
    }

    /// 辅色
    var secondaryColor: UIColor {
        return getCurrentReader().secondaryColor
    }

    // MARK: - 导航栏主题

    /// 导航栏背景色
    var navigationBarBackgroundColor: UIColor {
        return primaryColor.withAlphaComponent(0.95)
    }

    /// 导航栏标题颜色
    var navigationBarTitleColor: UIColor {
        return .white
    }

    /// 导航栏按钮颜色
    var navigationBarButtonColor: UIColor {
        return .white
    }

    // MARK: - 标签栏主题

    /// 标签栏背景色
    var tabBarBackgroundColor: UIColor {
        return UIColor(hex: "2D1344") // 深紫色背景
    }

    /// 标签栏图标颜色（未选中）
    var tabBarIconColor: UIColor {
        return UIColor(hex: "999999")
    }

    /// 标签栏图标颜色（选中）
    var tabBarIconSelectedColor: UIColor {
        return primaryColor
    }

    /// 标签栏标题颜色（未选中）
    var tabBarTitleColor: UIColor {
        return UIColor(hex: "999999")
    }

    /// 标签栏标题颜色（选中）
    var tabBarTitleSelectedColor: UIColor {
        return primaryColor
    }

    // MARK: - 按钮主题

    /// 大色块按钮颜色
    var largeButtonBackgroundColor: UIColor {
        return primaryColor.withAlphaComponent(0.8)
    }

    /// 大色块按钮边框颜色
    var largeButtonBorderColor: UIColor {
        return secondaryColor
    }

    /// 边框按钮颜色
    var borderButtonBackgroundColor: UIColor {
        return primaryColor.withAlphaComponent(0.3)
    }

    /// 胶囊按钮颜色
    var capsuleButtonBackgroundColor: UIColor {
        return primaryColor
    }

    /// 半透明填充按钮背景色
    var semiTransparentButtonBackgroundColor: UIColor {
        return primaryColor.withAlphaComponent(0.4)
    }

    // MARK: - 标签和文字主题

    /// 主标签颜色
    var primaryLabelColor: UIColor {
        return primaryColor
    }

    /// 次要标签颜色
    var secondaryLabelColor: UIColor {
        return secondaryColor
    }

    /// 文字颜色
    var textColor: UIColor {
        return UIColor(hex: "F8F8FF") // 浅白
    }

    /// 文字颜色（灰色）
    var textSecondaryColor: UIColor {
        return UIColor(hex: "CCCCCC")
    }

    // MARK: - 卡片和背景主题

    /// 卡片背景色
    var cardBackgroundColor: UIColor {
        return primaryColor.withAlphaComponent(0.15)
    }

    /// 卡片边框色
    var cardBorderColor: UIColor {
        return primaryColor.withAlphaComponent(0.4)
    }

    /// 卡片标题颜色
    var cardTitleColor: UIColor {
        return secondaryColor
    }

    // MARK: - 渐变主题

    /// 主背景渐变开始色
    var primaryGradientStart: UIColor {
        return primaryColor.withAlphaComponent(0.6)
    }

    /// 主背景渐变结束色
    var primaryGradientEnd: UIColor {
        return secondaryColor.withAlphaComponent(0.6)
    }

    // MARK: - 特殊颜色

    /// 强调色（用于警告、重要信息）
    var accentColor: UIColor {
        return secondaryColor
    }

    // MARK: - 设置主题

    /// 设置占卜师风格类型
    func setReaderStyleType(_ styleType: ReaderStyleType) {
        currentReaderStyleType = styleType
        currentReaderId = getCurrentReader().id

        // 通知所有 ViewController 主题已更新
        NotificationCenter.default.post(name: .themeDidChange, object: nil)
    }

    /// 获取当前占卜师ID
    func getCurrentReaderId() -> String {
        return currentReaderId
    }

    /// 获取当前占卜师
    private func getCurrentReader() -> TarotReader {
        return ReaderManager.shared.getReader(id: currentReaderId) ?? ReaderManager.shared.defaultReader
    }

    /// 保存当前占卜师选择
    func saveCurrentReaderId(_ readerId: String) {
        currentReaderId = readerId

        let reader = ReaderManager.shared.getReader(id: readerId)
        if let styleType = reader?.style.type {
            setReaderStyleType(styleType)
        }
    }

    /// 加载保存的占卜师选择
    func loadSavedReaderId() {
        let savedId = UserDefaults.standard.string(forKey: "selectedReaderId") ?? "reader_chenrou"
        saveCurrentReaderId(savedId)
    }
}

// MARK: - Notification Name

extension Notification.Name {
    static let themeDidChange = Notification.Name("themeDidChange")
}
