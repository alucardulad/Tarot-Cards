//
//  AppreciationViewController.swift
//  tarot_cards
//
//  Created by 陈柔 on 2026/02/05.
//
//  功能说明：
//  - 卡牌鉴赏模式：展示全部24张塔罗牌的网格视图
//  - 星空粒子特效：深空星星、漂浮光球、流星效果
//  - 呼吸光晕：卡片边缘柔和发光，呼吸效果
//  - 浮动动画：卡片轻微上下浮动，像云在飘
//  - 交互：点击卡片进入详情页

//  视觉特点：
//  - 深紫色渐变背景（2D1344 -> 1E1233 -> 120632）
//  - 紫色氛围，营造神秘感
//  - 星星层次：大星星、中等星星、小星星、微小星星
//  - 光球 + 流星 + 尘埃粒子系统
//

import UIKit
import SnapKit

class AppreciationViewController: UIViewController {

    private let cardManager = TarotCardManager.shared
    private var cards: [TarotCard] = []
    private var selectedCard: TarotCard?

    // 背景渐变层：深紫色系渐变
    private let backgroundLayer = CAGradientLayer()

    // 背景环境光：紫色呼吸效果
    private let ambientLightView = UIView()

    // UICollectionView：卡牌网格视图
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 20
        layout.itemSize = CGSize(width: 100, height: 160)
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: "CardCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()

    // 空状态提示：当卡牌加载失败时显示
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "正在加载塔罗牌..."
        label.textColor = ThemeManager.shared.secondaryColor
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // 设置统一导航栏
        setupUnifiedNavigationBar(title: "星空鉴赏")

        // 设置统一背景特效
        setupPageBackground(hasStarfield: true, hasAmbientLight: true)

        setupUI()                          // 设置UI布局
        loadCards()                        // 加载卡牌数据
        ParticleManager.addDust(to: view)  // 添加尘埃粒子
        // 启动环境光呼吸效果（透明度在0.08到0.15之间循环）
        startAmbientAnimation()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        ParticleManager.updateBounds(for: view)  // 更新粒子尺寸
        updateBackgroundBounds()
    }

    deinit {
        ParticleManager.cleanup(for: view)       // 清理粒子
    }

    // MARK: - 背景特效

    /// 设置背景渐变层
    /// - 颜色方案：深紫色(2D1344) -> 紫(1E1233) -> 深紫(120632)
    /// - 起点和终点：垂直居中
    private func setupBackgroundEffects() {
        let colors = [
            ThemeManager.shared.primaryGradientStart.cgColor,
            UIColor(hex: "1E1233").cgColor,
            ThemeManager.shared.primaryGradientEnd.cgColor
        ]
        backgroundLayer.colors = colors
        backgroundLayer.startPoint = CGPoint(x: 0.5, y: 0)
        backgroundLayer.endPoint = CGPoint(x: 0.5, y: 1)
        backgroundLayer.locations = [0.0, 0.5, 1.0]
        backgroundLayer.frame = view.bounds
        view.layer.insertSublayer(backgroundLayer, at: 0)

        // 环境光晕：紫色，透明度0.08
        ambientLightView.backgroundColor = ThemeManager.shared.secondaryColor
        ambientLightView.alpha = 0.08
        view.addSubview(ambientLightView)
        ambientLightView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.layoutIfNeeded()
        updateBackgroundBounds()
    }

    /// 更新背景渐变层尺寸
    private func updateBackgroundBounds() {
        backgroundLayer.frame = view.bounds
    }

    /// 启动环境光呼吸效果
    /// - 效果：透明度在0.08到0.15之间循环
    private func startAmbientAnimation() {
        UIView.animate(withDuration: 3.0,
                       delay: 0,
                       options: [.repeat, .autoreverse],
                       animations: { [weak self] in
            self?.ambientLightView.alpha = 0.15
        }, completion: nil)
    }

    // MARK: - UI布局

    private func setupUI() {
        view.backgroundColor = .clear

        // 导航栏样式：透明背景 + 紫色指示器
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = ThemeManager.shared.primaryColor
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - 数据加载

    /// 加载所有卡牌数据
    private func loadCards() {
        cards = cardManager.getAllCards()

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            if cards.isEmpty {
                emptyLabel.removeFromSuperview()
                view.addSubview(emptyLabel)
                emptyLabel.snp.makeConstraints { make in
                    make.center.equalToSuperview()
                }
            } else {
                emptyLabel.removeFromSuperview()
                self.collectionView.reloadData()
            }
        }
    }

    // MARK: - 导航

    /// 显示卡牌详情页
    /// - Parameter card: 要查看详情的卡牌
    func showCardDetail(_ card: TarotCard) {
        selectedCard = card
        let detailVC = CardDetailViewController()
        detailVC.card = card
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension AppreciationViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCell
        let card = cards[indexPath.item]
        cell.configure(with: card)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension AppreciationViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let card = cards[indexPath.item]
        showCardDetail(card)
    }
}

// MARK: - CardCell

class CardCell: UICollectionViewCell {

    // MARK: - UI组件

    /// 卡牌图片：圆角矩形，紫色边框
    private let cardImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.layer.borderWidth = 1.5
        imageView.layer.borderColor = ThemeManager.shared.secondaryColor.cgColor
        imageView.layer.shadowColor = ThemeManager.shared.secondaryColor.cgColor
        imageView.layer.shadowOffset = CGSize(width: 0, height: 4)
        imageView.layer.shadowOpacity = 0.4
        imageView.layer.shadowRadius = 10
        return imageView
    }()

    /// 卡牌编号和名称
    private let cardNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = ThemeManager.shared.textColor
        return label
    }()

    /// 卡牌名称（居中）
    private let cardNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = ThemeManager.shared.textColor
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    /// 光晕层：CAShapeLayer，用于边缘发光效果
    private let glowLayer = CAShapeLayer()
    private let glowAnimation = CABasicAnimation(keyPath: "opacity")

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGlowEffect()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI布局

    private func setupUI() {
        contentView.addSubview(cardImageView)
        contentView.addSubview(cardNumberLabel)
        contentView.addSubview(cardNameLabel)

        cardImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.left.equalToSuperview().offset(4)
            make.right.equalToSuperview().offset(-4)
            make.bottom.equalTo(cardNameLabel.snp.top).offset(-4)
        }

        cardNumberLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(6)
            make.right.equalToSuperview().offset(-6)
        }

        cardNameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(6)
            make.right.equalToSuperview().offset(-6)
            make.bottom.equalToSuperview().offset(-4)
        }
    }

    // MARK: - 光晕效果

    /// 设置光晕呼吸动画
    private func setupGlowEffect() {
        glowAnimation.duration = 3.0
        glowAnimation.fromValue = 0.2
        glowAnimation.toValue = 0.6
        glowAnimation.repeatCount = .infinity
        glowAnimation.autoreverses = true
        glowAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        // Configure and add glow layer
        glowLayer.fillColor = ThemeManager.shared.secondaryColor.cgColor
        glowLayer.opacity = 0.15
        contentView.layer.insertSublayer(glowLayer, at: 0)
        // start animation
        glowLayer.add(glowAnimation, forKey: "glowPulse")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateGlowPath()
    }

    /// 更新光晕路径和样式
    private func updateGlowPath() {
        glowLayer.frame = bounds
        glowLayer.path = UIBezierPath(roundedRect: bounds.insetBy(dx: 4, dy: 4), cornerRadius: 12).cgPath
        glowLayer.fillColor = ThemeManager.shared.secondaryColor.cgColor
    }

    // MARK: - 布局变化

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        // 添加轻微浮动效果：上下5像素
        let floatingAnimation = CABasicAnimation(keyPath: "transform.translation.y")
        floatingAnimation.duration = 1.5
        floatingAnimation.fromValue = -5
        floatingAnimation.toValue = 5
        floatingAnimation.repeatCount = .infinity
        floatingAnimation.autoreverses = true
        floatingAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        contentView.layer.add(floatingAnimation, forKey: "floating")
    }

    // MARK: - 配置

    /// 配置卡牌显示
    /// - Parameter card: 卡牌数据
    func configure(with card: TarotCard) {
        cardNumberLabel.text = "第\(card.id)号牌：\(card.name)"
        cardImageView.image = UIImage.init(named: "card_\(card.id)")
        cardNameLabel.text = card.name
    }

    // MARK: - 交互

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        // 点击缩放动画：从1.0到0.98，再回到1.0
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.duration = 0.3
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 0.98
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        let scaleBackAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleBackAnimation.duration = 0.3
        scaleBackAnimation.fromValue = 0.98
        scaleBackAnimation.toValue = 1.0
        scaleBackAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        contentView.layer.add(scaleAnimation, forKey: "pressScaleDown")
        contentView.layer.add(scaleBackAnimation, forKey: "pressScaleUp")

        // 光晕强度增强：从0.15到0.4
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.glowLayer.opacity = 0.4
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        // 光晕恢复：从0.4到0.15
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.glowLayer.opacity = 0.15
        }
    }
}
