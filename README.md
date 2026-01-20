# Tarot Cards

一个用于 iOS 的塔罗牌抽卡示例应用（Swift + UIKit）。

## 简介

该应用可以为用户随机抽取三张塔罗牌，展示牌面、方向（正位/逆位）与牌义，支持动画翻牌、保存最近一次抽卡与抽卡历史。项目使用 SnapKit 进行布局，部分 JSON 数据使用 SwiftyJSON（通过 CocoaPods 管理）。

## 主要功能

- 随机抽取三张牌并显示牌义
- 卡牌翻转动画与再次抽卡（带延迟与动画）
- 保存最近一次问题与抽卡结果到本地（UserDefaults）
- 将抽卡结果追加到历史记录

## 运行环境

- macOS + Xcode（建议 Xcode 13 及以上）
- iOS 13.0+
- 已安装 CocoaPods（用于依赖管理）

## 快速开始

1. 克隆仓库到本地。
2. 在项目根目录打开终端，执行：

```bash
pod install
```

3. 使用生成的 `.xcworkspace` 打开工程：

- 直接在 Finder 中双击 `tarot_cards.xcworkspace`，或
- 在终端中运行 `open tarot_cards.xcworkspace`

4. 在 Xcode 中选择一个模拟器或真机，构建并运行。

## 项目结构（部分）

- `tarot_cards/` — 应用源代码目录：
  - [tarot_cards/ResultViewController.swift](tarot_cards/ResultViewController.swift) — 展示抽卡结果、翻牌动画、保存历史等逻辑。
  - [tarot_cards/DrawViewController.swift](tarot_cards/DrawViewController.swift) — 抽卡界面（入口）。
  - [tarot_cards/TarotCard.swift](tarot_cards/TarotCard.swift) — 塔罗牌模型定义。
  - [tarot_cards/ViewController.swift](tarot_cards/ViewController.swift) — 主视图控制器（如有）。

- `Pods/` — CocoaPods 依赖（已提交于此仓库）。

## 开发说明

- 布局使用 `SnapKit`，约束代码位于 `Pods/SnapKit/Sources`（已通过 CocoaPods 引入）。
- 抽卡数据与牌义保存在项目资源或 plist/JSON 中（参见 `other/tarot_cards.plist`）。
- 抽卡动画与视图逻辑可在 `ResultViewController` 与自定义的 `CardDisplayView` 中查看与修改。

## 本地存储

- 最近问题：`UserDefaults` 键 `lastQuestion`
- 最近一次抽卡：`lastDrawnCards`
- 抽卡历史：`drawHistory`

## 贡献

欢迎提交 Issue 与 PR：

- Fork 本仓库并新建分支实现修复或特性
- 提交 PR 并附上复现步骤与变更说明
