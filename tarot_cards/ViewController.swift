//
//  ViewController.swift
//  tarot_cards
//
//  Created by alucardulad on 2026/1/20.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var cardViews: [CardDisplayView] = []
    private var drawnCards: [TarotCard] = []
    private var meaningLabels: [UILabel] = []
    private var redrawButton: UIButton?
    private var questionField: UITextField?
    private var goDrawButton: UIButton?
    // When pushed from homepage with a question, set these to trigger auto-draw
    var incomingQuestion: String?
    var shouldAutoDraw: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupUI()
        loadLastSaved()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if shouldAutoDraw {
            shouldAutoDraw = false
            if let q = incomingQuestion {
                questionField?.text = q
                saveLastQuestion()
            }
            // perform a new draw and save result
            performDrawNewCards(cards: nil)
        }
    }
    
    private func setupUI() {
        // 设置滚动视图
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

        // 去抽卡按钮（从首页进入抽卡页面）
        let goDrawButton = UIButton(type: .system)
        goDrawButton.setTitle("去抽卡", for: .normal)
        goDrawButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        goDrawButton.backgroundColor = .systemBlue
        goDrawButton.setTitleColor(.white, for: .normal)
        goDrawButton.layer.cornerRadius = 8
        goDrawButton.addTarget(self, action: #selector(openDrawPage), for: .touchUpInside)
        contentView.addSubview(goDrawButton)
        self.goDrawButton = goDrawButton
        goDrawButton.snp.makeConstraints { make in
            make.leading.equalTo(questionField.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(questionField)
            make.height.equalTo(40)
        }
        
        // 三张卡牌容器 - 水平堆栈
        let cardsContainer = UIStackView()
        cardsContainer.axis = .horizontal
        cardsContainer.distribution = .fillEqually
        cardsContainer.spacing = 12
        contentView.addSubview(cardsContainer)
        
        // 创建3个卡牌显示视图
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
        redrawButton.backgroundColor = .systemBlue
        redrawButton.setTitleColor(.white, for: .normal)
        redrawButton.layer.cornerRadius = 8
        redrawButton.addTarget(self, action: #selector(drawNewCards), for: .touchUpInside)
        contentView.addSubview(redrawButton)
        self.redrawButton = redrawButton
        redrawButton.snp.makeConstraints { make in
            make.top.equalTo(cardsContainer.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(44)
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
        
        // 为3张卡牌分别创建含义标签
        for i in 0..<3 {
            let meaningLabel = UILabel()
            meaningLabel.numberOfLines = 0
            meaningLabel.font = UIFont.systemFont(ofSize: 14)
            meaningLabel.textColor = .secondaryLabel
            meaningContainer.addArrangedSubview(meaningLabel)
            meaningLabels.append(meaningLabel)
        }
    }
    
    @objc private func drawNewCards() {
        performDrawNewCards(cards: nil)
    }

    /// 主抽卡逻辑（非 objc），可接收外部传入的卡组用于显示
    private func performDrawNewCards(cards: [TarotCard]? = nil) {
        if let cards = cards {
            drawnCards = cards
        } else {
            drawnCards = TarotCardManager.shared.drawThreeRandomCards()
        }
        // 先全部显示背面
        for cardView in cardViews { cardView.showBack() }

        // 禁用按钮，动画完成后再启用
        redrawButton?.isEnabled = false
        redrawButton?.alpha = 0.6

        // 依次翻开，每张间隔
        let flipInterval: TimeInterval = 0.6
        for (index, card) in drawnCards.enumerated() {
            let delay = Double(index) * flipInterval
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if index < self.cardViews.count {
                    self.cardViews[index].flipToCard(card)
                }
                // 更新对应含义文本
                if index < self.meaningLabels.count {
                    self.meaningLabels[index].text = "\(index + 1). \(card.name)【\(card.directionText)】\n\(card.currentMeaning)"
                }
            }
        }

        // 在最后一张动画结束后恢复按钮（多留一点时间以确保动画完成）
        let totalDelay = Double(drawnCards.count) * flipInterval + 0.2
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay) {
            self.redrawButton?.isEnabled = true
            self.redrawButton?.alpha = 1.0
            // 保存最后一次抽卡结果
            self.saveLastDrawn()
        }
    }

    // MARK: - Navigation
    @objc private func openDrawPage() {
        let question = questionField?.text ?? ""
        let drawVC = DrawViewController()
        navigationController?.pushViewController(drawVC, animated: true)
    }

    // MARK: - Persistence
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
                // 显示为上次抽卡结果
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
        self.backgroundColor = .systemGray6
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        
        // 卡牌图片
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.7)
        }
        
        // 卡牌名字
        nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 1
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(4)
            make.trailing.equalToSuperview().offset(-4)
        }
        
        // 方向标记
        directionLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
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
        // 直接配置为显示正面（无动画）
        imageView.image = UIImage(named: card.image)
        nameLabel.text = card.name
        directionLabel.text = card.directionText
        directionLabel.textColor = card.isUpright ? .systemGreen : .systemRed
        imageView.transform = card.isUpright ? .identity : CGAffineTransform(rotationAngle: .pi)
    }

    // 显示背面图片（静态）
    func showBack() {
        imageView.transform = .identity
        imageView.image = UIImage(named: "card_back")
        nameLabel.text = ""
        directionLabel.text = ""
    }

    // 翻卡动画：从背面翻为具体卡牌
    func flipToCard(_ card: TarotCard) {
        // 首先做一个翻转过渡动画替换图片和文本
        UIView.transition(with: self, duration: 0.5, options: [.transitionFlipFromRight], animations: {
            self.imageView.image = UIImage(named: card.image)
        }, completion: { _ in
            // 更新文字和方向颜色
            self.nameLabel.text = card.name
            self.directionLabel.text = card.directionText
            self.directionLabel.textColor = card.isUpright ? .systemGreen : .systemRed
            // 如果逆位，把图片旋转180度
            UIView.animate(withDuration: 0.12) {
                self.imageView.transform = card.isUpright ? .identity : CGAffineTransform(rotationAngle: .pi)
            }
        })
    }
}


