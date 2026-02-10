//
//  TabBarController.swift
//  tarot_cards
//
//  Created by 陈柔 on 2026/02/08.
//
//  功能说明：
//  - 统一的底部标签栏入口
//  - 包含四个主要功能页面
//  - 统一的标签栏样式配置
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 配置标签页
        configureViewControllers()

        // 自定义标签栏样式
        configureTabBarAppearance()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // 确保主题已应用
        applyTheme()
    }

    // MARK: - 配置标签页

    private func configureViewControllers() {
        let viewControllers = [
            createDailyTarotTab(),
            createDrawHistoryTab(),
            createAppreciationTab(),
            createFavoritesTab(),
            createReaderSelectTab()
        ]

        self.viewControllers = viewControllers
    }

    // MARK: - 创建每日塔罗标签页
    private func createDailyTarotTab() -> UIViewController {
        let viewController = ViewController()
        viewController.tabBarItem = UITabBarItem(
            title: "每日塔罗",
            image: UIImage(systemName: "star.fill"),
            selectedImage: UIImage(systemName: "star.fill")
        )
        return viewController
    }

    // MARK: - 创建占卜记录标签页
    private func createDrawHistoryTab() -> UIViewController {
        let viewController = DrawViewController()
        viewController.tabBarItem = UITabBarItem(
            title: "占卜记录",
            image: UIImage(systemName: "history"),
            selectedImage: UIImage(systemName: "history.fill")
        )
        return viewController
    }

    // MARK: - 创建星空鉴赏标签页
    private func createAppreciationTab() -> UIViewController {
        let viewController = AppreciationViewController()
        viewController.tabBarItem = UITabBarItem(
            title: "星空鉴赏",
            image: UIImage(systemName: "sparkles"),
            selectedImage: UIImage(systemName: "sparkles.fill")
        )
        return viewController
    }

    // MARK: - 创建我的收藏标签页
    private func createFavoritesTab() -> UIViewController {
        let viewController = FavoritesViewController()
        viewController.tabBarItem = UITabBarItem(
            title: "我的收藏",
            image: UIImage(systemName: "heart.fill"),
            selectedImage: UIImage(systemName: "heart.fill")
        )
        return viewController
    }

    // MARK: - 创建占卜师选择标签页
    private func createReaderSelectTab() -> UIViewController {
        let viewController = ReaderSelectViewController()
        viewController.tabBarItem = UITabBarItem(
            title: "占卜师",
            image: UIImage(systemName: "person.3.fill"),
            selectedImage: UIImage(systemName: "person.3.fill")
        )
        return viewController
    }

    // MARK: - 配置标签栏样式

    private func configureTabBarAppearance() {
        // 对于iOS 13以下设备
        if #available(iOS 13.0, *) {
            applyTheme()

            tabBar.scrollEdgeAppearance = tabBar.standardAppearance
        }
    }

    // MARK: - 应用主题

    private func applyTheme() {
        guard #available(iOS 13.0, *) else { return }

        let appearance = tabBar.standardAppearance

        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = ThemeManager.shared.tabBarBackgroundColor
        appearance.shadowColor = UIColor(hex: "000000").withAlphaComponent(0.2)

        appearance.stackedLayoutAppearance.normal.iconColor = ThemeManager.shared.tabBarIconColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: ThemeManager.shared.tabBarTitleColor
        ]

        appearance.stackedLayoutAppearance.selected.iconColor = ThemeManager.shared.tabBarIconSelectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: ThemeManager.shared.tabBarTitleSelectedColor
        ]

        tabBar.standardAppearance = appearance
    }
}
