//
//  CardDetailViewController.swift
//  tarot_cards
//
//  Created by 陈柔 on 2026/02/05.
//
//  功能说明：
//  - 卡牌详情页：展示单张塔罗牌的大图和完整含义
//  - 漂浮光球粒子特效：紫色 + 青色光晕
//  - 呼吸光晕：卡牌周围紫色光晕呼吸效果
//  - 标题渐变：紫色到青色的渐变效果
//  - 交互：返回按钮、填充信息按钮

//  视觉特点：
//  - 深紫色渐变背景
//  - 紫色光晕呼吸（0.2-0.5循环）
//  - 漂浮光球（2个/秒，紫色+青色光晕）
//  - 标题渐变（紫色->青色）
//

import UIKit
import CoreText
import SnapKit
import SwifterSwift

class CardDetailViewController: UIViewController {

    // MARK: - 属性

    /// 当前查看的卡牌
    var card: TarotCard?

    // 背景渐变层：深紫色系
    private let backgroundLayer = CAGradientLayer()

    // 背景环境光：紫色呼吸
    private let ambientLightView = UIView()

    // 卡牌光晕层：CAShapeLayer，用于卡牌周围光晕
    private let cardGlowLayer = CAShapeLayer()
    private let cardGlowAnimation = CABasicAnimation(keyPath: "opacity")

    // 标题渐变图层与文本掩码
    private let titleGradientLayer = CAGradientLayer()
    private let titleMaskLayer = CATextLayer()

    // MARK: - UI组件

    // 卡牌大图：圆角，紫色边框，柔和阴影
    private let cardImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = ThemeManager.shared.secondaryColor.cgColor
        imageView.layer.shadowColor = ThemeManager.shared.secondaryColor.cgColor
        imageView.layer.shadowOffset = CGSize(width: 0, height: 10)
        imageView.layer.shadowOpacity = 0.5
        imageView.layer.shadowRadius = 25
        return imageView
    }()

    /// 标题：卡牌编号 + 名称
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = ThemeManager.shared.textColor
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    /// 正位标签
    private let uprightLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = ThemeManager.shared.secondaryColor
        label.textAlignment = .center
        return label
    }()

    /// 正位含义
    private let uprightMeaningLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = ThemeManager.shared.textColor
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    /// 逆位标签
    private let reversedLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = ThemeManager.shared.secondaryColor
        label.textAlignment = .center
        return label
    }()

    /// 逆位含义
    private let reversedMeaningLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = ThemeManager.shared.textColor
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    // 返回按钮：圆形，紫色边框
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("✕", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        button.setTitleColor(ThemeManager.shared.textColor, for: .normal)
        button.backgroundColor = UIColor(hex: "2D1344")
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1.5
        button.layer.borderColor = ThemeManager.shared.secondaryColor.cgColor
        return button
    }()

    // 填充信息按钮：方形，紫色边框
    private lazy var fillButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("📄 填充信息", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button.setTitleColor(ThemeManager.shared.primaryColor, for: .normal)
        button.backgroundColor = UIColor(hex: "2D1344")
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1.5
        button.layer.borderColor = ThemeManager.shared.secondaryColor.cgColor
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // 设置统一导航栏
        setupUnifiedNavigationBar(title: "卡牌详情")

        // 设置统一背景特效
        setupPageBackground(hasStarfield: true, hasAmbientLight: true)

        // 详情页特殊粒子效果（完整混合）
        ParticleManager.addFullEffects(to: view)

        setupUI()                        // 设置UI布局
        updateCardInfo()                 // 更新卡牌信息
        startCardGlowAnimation()         // 启动光晕呼吸动画
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        ParticleManager.updateBounds(for: view)  // 更新粒子尺寸
        updateBackgroundBounds()
        updateCardGlowPath()
        // 更新标题渐变与掩码的大小
        titleGradientLayer.frame = titleLabel.bounds
        titleMaskLayer.frame = titleLabel.bounds
    }

    deinit {
        ParticleManager.cleanup(for: view)  // 清理粒子
    }

    // MARK: - 背景特效

    private func setupBackgroundEffects() {
        let colors = [
            UIColor(hex: "2D1344").cgColor,
            UIColor(hex: "1E1233").cgColor,
            UIColor(hex: "120632").cgColor
        ]
        backgroundLayer.colors = colors
        backgroundLayer.startPoint = CGPoint(x: 0.5, y: 0)
        backgroundLayer.endPoint = CGPoint(x: 0.5, y: 1)
        backgroundLayer.locations = [0.0, 0.5, 1.0]
        backgroundLayer.frame = view.bounds
        view.layer.insertSublayer(backgroundLayer, at: 0)

        ambientLightView.backgroundColor = ThemeManager.shared.secondaryColor
        ambientLightView.alpha = 0.08
        view.addSubview(ambientLightView)
        ambientLightView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        cardGlowLayer.fillColor = ThemeManager.shared.secondaryColor.cgColor
        cardGlowLayer.opacity = 0.2
        view.layer.insertSublayer(cardGlowLayer, at: 1)

        view.layoutIfNeeded()
        updateBackgroundBounds()
        updateCardGlowPath()
    }

    private func updateBackgroundBounds() {
        backgroundLayer.frame = view.bounds
    }

    /// 更新卡牌光晕路径
    private func updateCardGlowPath() {
        // 将光晕层对齐到 cardImageView 的 frame，并在其本地坐标中设置路径
        cardGlowLayer.frame = cardImageView.frame
        cardGlowLayer.path = UIBezierPath(roundedRect: cardGlowLayer.bounds.insetBy(dx: 10, dy: 10), cornerRadius: 30).cgPath
    }

    // MARK: - 光晕动画

    /// 启动卡牌光晕呼吸效果
    /// - 效果：透明度在0.2到0.5之间循环
    private func startCardGlowAnimation() {
        cardGlowAnimation.duration = 3.0
        cardGlowAnimation.fromValue = 0.2
        cardGlowAnimation.toValue = 0.5
        cardGlowAnimation.repeatCount = .infinity
        cardGlowAnimation.autoreverses = true
        cardGlowAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        cardGlowLayer.add(cardGlowAnimation, forKey: "glowPulse")
    }

    // MARK: - UI布局

    private func setupUI() {
        view.backgroundColor = .clear

        // 导航栏：透明背景
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = ThemeManager.shared.secondaryColor
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        // 标题渐变层：紫色->青色（使用掩码实现文字渐变）
        titleGradientLayer.colors = [ThemeManager.shared.secondaryColor.cgColor, ThemeManager.shared.primaryColor.cgColor]
        titleGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        titleGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)

        // 标题文字（使用掩码显示渐变文字）
        let attributedString = NSMutableAttributedString(string: "卡牌鉴赏")
        // 设置文本为空颜色，真实颜色由渐变掩码控制
        attributedString.addAttribute(.foregroundColor, value: UIColor.clear, range: NSRange(location: 0, length: attributedString.length))
        titleLabel.attributedText = attributedString
        titleLabel.layer.masksToBounds = false

        // 配置文本掩码
        titleMaskLayer.string = "卡牌鉴赏"
        titleMaskLayer.alignmentMode = .center
        titleMaskLayer.contentsScale = UIScreen.main.scale
        titleMaskLayer.foregroundColor = UIColor.white.cgColor
        titleMaskLayer.font = CTFontCreateWithName(titleLabel.font.fontName as CFString, titleLabel.font.pointSize, nil)
        titleMaskLayer.fontSize = titleLabel.font.pointSize

        titleGradientLayer.mask = titleMaskLayer
        titleLabel.layer.addSublayer(titleGradientLayer)

        view.addSubview(cardImageView)
        cardImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalToSuperview().multipliedBy(0.45)
        }

        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(cardImageView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }

        view.addSubview(uprightLabel)
        uprightLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }

        view.addSubview(uprightMeaningLabel)
        uprightMeaningLabel.snp.makeConstraints { make in
            make.top.equalTo(uprightLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(25)
            make.right.equalToSuperview().offset(-25)
        }

        view.addSubview(reversedLabel)
        reversedLabel.snp.makeConstraints { make in
            make.top.equalTo(uprightMeaningLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }

        view.addSubview(reversedMeaningLabel)
        reversedMeaningLabel.snp.makeConstraints { make in
            make.top.equalTo(reversedLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(25)
            make.right.equalToSuperview().offset(-25)
            make.bottom.equalToSuperview().offset(-60)
        }

        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(44)
        }

        // 收藏按钮
        let favoriteButton = UIButton(type: .system)
        favoriteButton.setTitle("❤️ 收藏", for: .normal)
        favoriteButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        favoriteButton.setTitleColor(.white, for: .normal)
        favoriteButton.backgroundColor = ThemeManager.shared.secondaryColor
        favoriteButton.layer.cornerRadius = 16
        favoriteButton.layer.shadowColor = ThemeManager.shared.secondaryColor.cgColor
        favoriteButton.layer.shadowRadius = 5
        favoriteButton.layer.shadowOpacity = 0.5
        favoriteButton.layer.shadowOffset = CGSize(width: 0, height: 2)

        view.addSubview(favoriteButton)
        favoriteButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(48)
        }

        view.addSubview(fillButton)
        fillButton.snp.makeConstraints { make in
            make.bottom.equalTo(favoriteButton.snp.top).offset(-12)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }

        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        fillButton.addTarget(self, action: #selector(fillButtonTapped), for: .touchUpInside)
    }

    // MARK: - 数据更新

    private func updateCardInfo() {
        guard let card = card else { return }

        // 更新标题内容通过掩码显示渐变文字，避免直接设置 titleLabel.text 覆盖渐变图层
        let titleText = "第\(card.id)号牌：\(card.name)"
        titleMaskLayer.string = titleText
        let attributed = NSMutableAttributedString(string: titleText)
        attributed.addAttribute(.foregroundColor, value: UIColor.clear, range: NSRange(location: 0, length: attributed.length))
        titleLabel.attributedText = attributed

        uprightLabel.text = "正位"
        uprightMeaningLabel.text = card.upright

        reversedLabel.text = "逆位"
        reversedMeaningLabel.text = card.reversed

        
        cardImageView.image = UIImage.init(named: "card_\(card.id)")
    }

    // MARK: - 交互

    @objc private func closeButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func favoriteButtonTapped() {
        guard let card = card else { return }

        let isFavorite = FavoriteManager.shared.toggleFavorite(card)

        if isFavorite {
            showAlert(message: "已添加到收藏 ❤️")
        } else {
            showAlert(message: "已取消收藏 💔")
        }
    }

    @objc private func fillButtonTapped() {
        showAlert(message: "功能待实现：填充到详细信息的表单中")
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}
