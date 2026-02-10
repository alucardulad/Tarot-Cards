//
//  UnifiedNavigation.swift
//  tarot_cards
//
//  Created by 陈柔 on 2026/02/08.
//
//  功能说明：
//  - 统一导航栏配置
//  - 统一按钮样式
//  - 统一背景特效
//

import UIKit
import SnapKit

// MARK: - 统一导航栏配置
extension UIViewController {

    /// 设置统一的导航栏样式
    /// - Parameter title: 导航栏标题
    func setupUnifiedNavigationBar(title: String) {
        self.title = title
        navigationItem.largeTitleDisplayMode = .never

        // 自定义导航栏外观
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = ThemeManager.shared.navigationBarBackgroundColor
        appearance.titleTextAttributes = [
            .foregroundColor: ThemeManager.shared.navigationBarTitleColor,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        appearance.shadowColor = ThemeManager.shared.navigationBarBackgroundColor

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }

    /// 设置顶部简单的导航栏（用于不需要返回按钮的页面）
    func setupSimpleNavigationBar(title: String) {
        self.title = title
        navigationItem.largeTitleDisplayMode = .never

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
}

// MARK: - 统一按钮样式
extension UIButton {

    /// 设置主要按钮样式（实心色块）
    /// - Parameters:
    ///   - title: 按钮标题
    ///   - color: 按钮背景色
    func setupPrimaryButton(title: String, color: UIColor) {
        self.setTitle(title, for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.backgroundColor = color
        self.layer.cornerRadius = 22  // 统一圆角
        self.layer.shadowColor = color.cgColor
        self.layer.shadowRadius = 8
        self.layer.shadowOpacity = 0.6
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
    }

    /// 设置次要按钮样式（边框按钮）
    /// - Parameters:
    ///   - title: 按钮标题
    ///   - color: 边框颜色
    func setupSecondaryButton(title: String, color: UIColor) {
        self.setTitle(title, for: .normal)
        self.setTitleColor(color, for: .normal)
        self.backgroundColor = .clear
        self.layer.cornerRadius = 22
        self.layer.borderWidth = 1
        self.layer.borderColor = color.cgColor
    }

    /// 设置次要按钮样式（灰色背景）
    /// - Parameters:
    ///   - title: 按钮标题
    ///   - color: 背景色
    func setupSecondaryFilledButton(title: String, color: UIColor) {
        self.setTitle(title, for: .normal)
        self.setTitleColor(color, for: .normal)
        self.backgroundColor = color.withAlphaComponent(0.15)
        self.layer.cornerRadius = 22
        self.layer.borderWidth = 1
        self.layer.borderColor = color.cgColor
    }

    /// 设置小按钮样式
    /// - Parameters:
    ///   - title: 按钮标题
    ///   - color: 按钮背景色
    func setupSmallButton(title: String, color: UIColor) {
        self.setTitle(title, for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.backgroundColor = color
        self.layer.cornerRadius = 16  // 小按钮圆角更小
        self.layer.shadowColor = color.cgColor
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
    }
}

// MARK: - 统一背景特效
extension UIViewController {

    /// 设置统一的页面背景
    func setupPageBackground(hasStarfield: Bool = true, hasAmbientLight: Bool = true) {
        // 深紫色渐变背景
        let colors = [
            UIColor(hex: "2D1344").cgColor,
            UIColor(hex: "1E1233").cgColor,
            UIColor(hex: "120632").cgColor
        ]
        let backgroundLayer = CAGradientLayer()
        backgroundLayer.colors = colors
        backgroundLayer.startPoint = CGPoint(x: 0.5, y: 0)
        backgroundLayer.endPoint = CGPoint(x: 0.5, y: 1)
        backgroundLayer.locations = [0.0, 0.5, 1.0]
        backgroundLayer.frame = view.bounds
        view.layer.insertSublayer(backgroundLayer, at: 0)

        // 星空粒子特效
        if hasStarfield {
            ParticleManager.addStarfield(to: view)
        }

        // 环境光呼吸效果
        if hasAmbientLight {
            let ambientLight = UIView()
            ambientLight.backgroundColor = ThemeManager.shared.secondaryColor
            ambientLight.alpha = 0.08
            view.addSubview(ambientLight)
            ambientLight.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            // 启动呼吸动画
            animateAmbientLight(ambientLight)
        }
    }

    /// 启动环境光呼吸动画
    private func animateAmbientLight(_ view: UIView) {
        UIView.animate(withDuration: 3, delay: 0, options: [.repeat, .autoreverse]) {
            view.alpha = 0.15
        }
    }

    /// 设置深色毛玻璃背景
    func setupDarkBlurBackground() {
        if let bg = UIImage(named: "reBG") {
            let bgView = UIImageView(image: bg)
            bgView.contentMode = .scaleAspectFill
            view.insertSubview(bgView, at: 0)
            bgView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.width.equalToSuperview()
            }

            let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
            view.addSubview(blur)
            blur.alpha = 0.2
            blur.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
}

// MARK: - 卡牌展示视图统一样式
extension CardDisplayView {

    /// 统一卡牌样式配置
    static func createDefaultCard() -> CardDisplayView {
        let cardView = CardDisplayView()
        cardView.backgroundColor = .clear
        cardView.layer.cornerRadius = 12
        cardView.clipsToBounds = true
        return cardView
    }
}
