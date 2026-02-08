//
//  ViewController.swift
//  tarot_cards
//
//  Created by alucardulad on 2026/1/20.
//
//  功能说明：
//  - 首页：每日塔罗牌主界面
//  - 抽卡功能：随机抽取3张牌
//  - 每日一签：单卡占卜
//  - 鉴赏模式入口：点击进入鉴赏页面
//  - 历史记录：查看之前的抽卡记录
//
//  视觉特点：
//  - 深紫色渐变背景
//  - 星空粒子特效（星星 + 光球）
//  - 环境光呼吸效果
//

import UIKit
import SnapKit
import SwifterSwift

class ViewController: UIViewController {

    // MARK: - 属性

    // 滚动视图
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // 卡牌显示视图（3张牌）
    private var cardViews: [CardDisplayView] = []

    // 背景渐变层（用于深紫色渐变）
    private let backgroundLayer = CAGradientLayer()

    // 环境光覆盖视图（轻微呼吸光）
    private let ambientLightView: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // 抽卡结果
    private var drawnCards: [TarotCard] = []

    // 含义标签
    private var meaningLabels: [UILabel] = []

    // 重新抽卡按钮
    private var redrawButton: UIButton?

    // 问题输入框
    private var questionField: UITextField?

    // 去抽卡按钮
    private var goDrawButton: UIButton?

    // 从首页传来的问题和自动抽卡标志
    var incomingQuestion: String?
    var shouldAutoDraw: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // 设置统一导航栏
        setupUnifiedNavigationBar(title: "每日塔罗牌")

        // 设置统一背景特效
        setupPageBackground(hasStarfield: true, hasAmbientLight: true)
        view.backgroundColor = .clear
        setupUI()                        // 设置UI
        loadLastSaved()                  // 加载上次保存的数据
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        ParticleManager.updateBounds(for: view)  // 更新粒子尺寸
        updateBackgroundBounds()
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

        ambientLightView.backgroundColor = APPConstants.Color.explanationColor
        ambientLightView.alpha = 0.08
        view.addSubview(ambientLightView)
        ambientLightView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.layoutIfNeeded()
        updateBackgroundBounds()
    }

    private func updateBackgroundBounds() {
        backgroundLayer.frame = view.bounds
    }

    // MARK: - UI布局

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        // 标题
        let titleLabel = UILabel()
        titleLabel.text = "每日塔罗牌"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        // 入口按钮容器
        let entryButtonsContainer = UIStackView()
        entryButtonsContainer.axis = .horizontal
        entryButtonsContainer.distribution = .fillEqually
        entryButtonsContainer.spacing = 16
        contentView.addSubview(entryButtonsContainer)
        entryButtonsContainer.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        // 鉴赏模式按钮（更明显的大按钮）
        let appreciationButton = UIButton(type: .system)
        appreciationButton.setTitle("✨ 星空鉴赏", for: .normal)
        appreciationButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        appreciationButton.setupPrimaryButton(title: "星空鉴赏", color: APPConstants.Color.explanationColor)
        appreciationButton.addTarget(self, action: #selector(openAppreciation), for: .touchUpInside)
        entryButtonsContainer.addArrangedSubview(appreciationButton)

        // 收藏按钮（更明显的大按钮）
        let favoritesButton = UIButton(type: .system)
        favoritesButton.setTitle("❤️ 我的收藏", for: .normal)
        favoritesButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        favoritesButton.setupPrimaryButton(title: "我的收藏", color: APPConstants.Color.explanationColor)
        favoritesButton.addTarget(self, action: #selector(openFavorites), for: .touchUpInside)
        entryButtonsContainer.addArrangedSubview(favoritesButton)

        // 问题输入框
        let questionField = UITextField()
        questionField.borderStyle = .roundedRect
        questionField.placeholder = "请输入你的问题（可选）"
        contentView.addSubview(questionField)
        self.questionField = questionField
        questionField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-120)
            make.height.equalTo(40)
        }

        // 去抽卡按钮
        let goDrawButton = UIButton(type: .system)
        goDrawButton.setTitle("去抽卡", for: .normal)
        goDrawButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        goDrawButton.setupSmallButton(title: "去抽卡", color: APPConstants.Color.explanationColor)
        goDrawButton.addTarget(self, action: #selector(openDrawPage), for: .touchUpInside)
        contentView.addSubview(goDrawButton)
        self.goDrawButton = goDrawButton
        goDrawButton.snp.makeConstraints { make in
            make.leading.equalTo(questionField.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(questionField)
            make.height.equalTo(36)
        }

        // 三张卡牌容器
        let cardsContainer = UIStackView()
        cardsContainer.axis = .horizontal
        cardsContainer.distribution = .fillEqually
        cardsContainer.spacing = 12
        contentView.addSubview(cardsContainer)

        for i in 0..<3 {
            let cardView = CardDisplayView()
            cardsContainer.addArrangedSubview(cardView)
            cardViews.append(cardView)
        }

        cardsContainer.snp.makeConstraints { make in
            make.top.equalTo(questionField.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(300)
        }

        // 重新抽卡按钮
        let redrawButton = UIButton(type: .system)
        redrawButton.setTitle("再次抽卡", for: .normal)
        redrawButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        redrawButton.setupSmallButton(title: "再次抽卡", color: APPConstants.Color.explanationColor)
        redrawButton.addTarget(self, action: #selector(drawNewCards), for: .touchUpInside)
        contentView.addSubview(redrawButton)
        self.redrawButton = redrawButton
        redrawButton.snp.makeConstraints { make in
            make.top.equalTo(cardsContainer.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.equalTo(140)
            make.height.equalTo(40)
        }

        // 含义描述容器
        let meaningContainer = UIStackView()
        meaningContainer.axis = .vertical
        meaningContainer.spacing = 16
        contentView.addSubview(meaningContainer)
        meaningContainer.snp.makeConstraints { make in
            make.top.equalTo(redrawButton.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-20)
        }

        for i in 0..<3 {
            let meaningLabel = UILabel()
            meaningLabel.numberOfLines = 0
            meaningLabel.font = UIFont.systemFont(ofSize: 14)
            meaningLabel.textColor = .secondaryLabel
            meaningContainer.addArrangedSubview(meaningLabel)
            meaningLabels.append(meaningLabel)
        }
    }

    // MARK: - 抽卡逻辑

    @objc private func drawNewCards() {
        performDrawNewCards(cards: nil)
    }

    private func performDrawNewCards(cards: [TarotCard]? = nil) {
        if let cards = cards {
            drawnCards = cards
        } else {
            drawnCards = TarotCardManager.shared.drawThreeRandomCards()
        }

        for cardView in cardViews { cardView.showBack() }

        redrawButton?.isEnabled = false
        redrawButton?.alpha = 0.6

        let flipInterval: TimeInterval = 0.6
        for (index, card) in drawnCards.enumerated() {
            let delay = Double(index) * flipInterval
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if index < self.cardViews.count {
                    self.cardViews[index].flipToCard(card)
                }
                if index < self.meaningLabels.count {
                    self.meaningLabels[index].text = "\(index + 1). \(card.name)【\(card.directionText)】\n\(card.currentMeaning)"
                }
            }
        }

        let totalDelay = Double(drawnCards.count) * flipInterval + 0.2
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay) {
            self.redrawButton?.isEnabled = true
            self.redrawButton?.alpha = 1.0
            self.saveLastDrawn()
        }
    }

    // MARK: - 导航

    @objc private func openDrawPage() {
        let question = questionField?.text ?? ""
        let drawVC = DrawViewController()
        navigationController?.pushViewController(drawVC, animated: true)
    }

    @objc private func openAppreciation() {
        let appreciationVC = AppreciationViewController()
        navigationController?.pushViewController(appreciationVC, animated: true)
    }

    @objc private func openFavorites() {
        let favoritesVC = FavoritesViewController()
        navigationController?.pushViewController(favoritesVC, animated: true)
    }

    // MARK: - 持久化

    private func saveLastQuestion() {
        let q = questionField?.text ?? ""
        UserDefaults.standard.set(q, forKey: "lastQuestion")
    }

    private func saveLastDrawn() {
        let arr = drawnCards.map { card -> [String: Any] in
            return ["id": card.id, "name": card.name, "image": card.image, "isUpright": card.isUpright, "meaning": card.currentMeaning]
        }
        UserDefaults.standard.set(arr, forKey: "lastDrawnCards")
    }

    private func loadLastSaved() {
        if let q = UserDefaults.standard.string(forKey: "lastQuestion") {
            questionField?.text = q
        }

        if let arr = UserDefaults.standard.array(forKey: "lastDrawnCards") as? [[String: Any]], arr.count == 3 {
            var cards: [TarotCard] = []
            for dict in arr {
                if let id = dict["id"] as? Int,
                   let name = dict["name"] as? String,
                   let image = dict["image"] as? String,
                   let isUpright = dict["isUpright"] as? Bool {
                    var card = TarotCard(id: id, name: name, image: image, upright: dict["meaning"] as? String ?? "", reversed: "")
                    card.isUpright = isUpright
                    cards.append(card)
                }
            }
            if cards.count == 3 {
                self.performDrawNewCards(cards: cards)
            }
        }
    }
}

// MARK: - CardDisplayView

class CardDisplayView: UIView {
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let directionLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }

    private func setupSubviews() {
        self.backgroundColor = .clear
        self.layer.cornerRadius = 8
        self.clipsToBounds = true

        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.7)
        }

        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 1
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(4)
            make.trailing.equalToSuperview().offset(-4)
        }

        directionLabel.font = UIFont.boldSystemFont(ofSize: 14)
        directionLabel.textAlignment = .center
        addSubview(directionLabel)
        directionLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
            make.leading.equalToSuperview().offset(4)
            make.trailing.equalToSuperview().offset(-4)
            make.bottom.lessThanOrEqualToSuperview().offset(-4)
        }
    }

    func configure(with card: TarotCard) {
        imageView.image = UIImage(named: card.image)
        nameLabel.text = card.name
        directionLabel.text = card.directionText
        directionLabel.textColor = card.isUpright ? .systemGreen : .systemRed
        nameLabel.textColor = APPConstants.Color.bodyColor
        imageView.transform = card.isUpright ? .identity : CGAffineTransform(rotationAngle: .pi)
    }

    func showBack() {
        imageView.transform = .identity
        imageView.image = UIImage(named: "card_back")
        nameLabel.text = ""
        directionLabel.text = ""
    }

    func flipToCard(_ card: TarotCard) {
        UIView.transition(with: self, duration: 0.5, options: [.transitionFlipFromRight], animations: {
            self.imageView.image = UIImage(named: card.image)
        }, completion: { _ in
            self.nameLabel.text = card.name
            self.directionLabel.text = card.directionText
            self.directionLabel.textColor = card.isUpright ? .systemGreen : .systemRed
            UIView.animate(withDuration: 0.12) {
                self.imageView.transform = card.isUpright ? .identity : CGAffineTransform(rotationAngle: .pi)
            }
        })
    }
}
