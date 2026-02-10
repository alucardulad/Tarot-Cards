//
//  ThemeManager+UIColor.swift
//  tarot_cards
//
//  ThemeManager 颜色扩展
//  Created by 陈柔 & 老萨满
//  Date: 2026-02-09
//

import UIKit
import Foundation

// MARK: - ReaderCell 颜色

extension ReaderCell {
    func updateWithThemeColors(primary: UIColor, secondary: UIColor) {
        containerView.layer.borderColor = secondary.cgColor
        selectButton.backgroundColor = secondary
        selectButton.setTitleColor(primary, for: .normal)
    }
}

// MARK: - ParticleManager 颜色

extension ParticleManager {
    private func getThemePrimaryColor() -> UIColor {
        return ThemeManager.shared.primaryColor
    }

    private func getThemeSecondaryColor() -> UIColor {
        return ThemeManager.shared.secondaryColor
    }

    private func getThemeBorderColor() -> UIColor {
        return ThemeManager.shared.secondaryColor
    }
}

// MARK: - 统一导航栏配置

extension UIViewController {
    func applyUnifiedNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = ThemeManager.shared.navigationBarBackgroundColor
        appearance.titleTextAttributes = [
            .foregroundColor: ThemeManager.shared.navigationBarTitleColor
        ]

        appearance.largeTitleTextAttributes = [
            .foregroundColor: ThemeManager.shared.navigationBarTitleColor
        ]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
}

// MARK: - 按钮扩展

extension UIButton {
    func applyLargeButtonStyle() {
        backgroundColor = ThemeManager.shared.largeButtonBackgroundColor
        layer.cornerRadius = 22
        layer.borderWidth = 0
        setTitleColor(ThemeManager.shared.primaryColor, for: .normal)
    }

    func applyBorderButtonStyle() {
        backgroundColor = ThemeManager.shared.borderButtonBackgroundColor
        layer.cornerRadius = 22
        layer.borderWidth = 2
        layer.borderColor = ThemeManager.shared.largeButtonBorderColor.cgColor
        setTitleColor(ThemeManager.shared.secondaryColor, for: .normal)
    }

    func applyCapsuleButtonStyle() {
        backgroundColor = ThemeManager.shared.capsuleButtonBackgroundColor
        layer.cornerRadius = 16
        layer.borderWidth = 0
        setTitleColor(ThemeManager.shared.primaryColor, for: .normal)
    }

    func applySemiTransparentButtonStyle() {
        backgroundColor = ThemeManager.shared.semiTransparentButtonBackgroundColor
        layer.cornerRadius = 22
        layer.borderWidth = 2
        layer.borderColor = ThemeManager.shared.secondaryColor.cgColor
        setTitleColor(ThemeManager.shared.secondaryColor, for: .normal)
    }
}

// MARK: - 标签扩展

extension UILabel {
    func applyPrimaryLabelStyle() {
        textColor = ThemeManager.shared.primaryLabelColor
    }

    func applySecondaryLabelStyle() {
        textColor = ThemeManager.shared.secondaryLabelColor
    }

    func applyPrimaryTextStyle() {
        textColor = ThemeManager.shared.textColor
    }

    func applySecondaryTextStyle() {
        textColor = ThemeManager.shared.textSecondaryColor
    }
}

// MARK: - 视图扩展

extension UIView {
    func applyCardStyle() {
        backgroundColor = ThemeManager.shared.cardBackgroundColor
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = ThemeManager.shared.cardBorderColor.cgColor
    }
}
