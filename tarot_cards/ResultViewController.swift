//
//  ResultViewController.swift
//  tarot_cards
//
//  Created by copilot on 2026/1/20.
//

import UIKit
import SnapKit

class ResultViewController: UIViewController {
    var question: String = ""
    var cards: [TarotCard] = []
    var shouldAutoDraw: Bool = false
    private var redrawButton: UIButton?
    private var cardViews: [CardDisplayView] = []
    private var meaningLabels: [UILabel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "抽卡结果"
        setupUI()
        if shouldAutoDraw && cards.isEmpty {
            cards = TarotCardManager.shared.drawThreeRandomCards()
        }
        displayCards()
        // 默认保存本次问题与抽卡结果
        saveLastQuestion()
        saveLastDrawn()
        // 在首次显示后，把这次抽卡加入历史
        saveToHistory()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 确保离开时保存最后一次抽卡结果与问题
        saveLastQuestion()
        saveLastDrawn()
    }

    private func setupUI() {
        let questionLabel = UILabel()
        questionLabel.text = question.isEmpty ? "你的问题：(未填写)" : "你的问题：\n\(question)"
        questionLabel.numberOfLines = 0
        questionLabel.textAlignment = .center
        questionLabel.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(questionLabel)
        questionLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        let cardsContainer = UIStackView()
        cardsContainer.axis = .horizontal
        cardsContainer.distribution = .fillEqually
        cardsContainer.spacing = 12
        view.addSubview(cardsContainer)
        cardsContainer.snp.makeConstraints { make in
            make.top.equalTo(questionLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(320)
        }

        for _ in 0..<3 {
            let cv = CardDisplayView()
            cardsContainer.addArrangedSubview(cv)
            cardViews.append(cv)
        }

        let meaningContainer = UIStackView()
        meaningContainer.axis = .vertical
        meaningContainer.spacing = 12
        view.addSubview(meaningContainer)
        meaningContainer.snp.makeConstraints { make in
            make.top.equalTo(cardsContainer.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.lessThanOrEqualToSuperview().offset(-16)
        }

        for _ in 0..<3 {
            let lbl = UILabel()
            lbl.numberOfLines = 0
            lbl.font = UIFont.systemFont(ofSize: 14)
            lbl.textColor = .secondaryLabel
            meaningContainer.addArrangedSubview(lbl)
            meaningLabels.append(lbl)
        }

        // 底部居中按钮：再次抽卡
        let bottomRedraw = UIButton(type: .system)
        bottomRedraw.setTitle("再次抽卡", for: .normal)
        bottomRedraw.setTitleColor(.white, for: .normal)
        bottomRedraw.backgroundColor = .systemBlue
        bottomRedraw.layer.cornerRadius = 22
        bottomRedraw.addTarget(self, action: #selector(redrawTapped), for: .touchUpInside)
        view.addSubview(bottomRedraw)
        bottomRedraw.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            make.width.equalTo(160)
            make.height.equalTo(44)
        }
        self.redrawButton = bottomRedraw
    }

    private func displayCards() {
        for (i, card) in cards.enumerated() {
            if i < cardViews.count {
                cardViews[i].configure(with: card)
            }
            if i < meaningLabels.count {
                meaningLabels[i].text = "\(i + 1). \(card.name)【\(card.directionText)】\n\(card.currentMeaning)"
            }
        }
    }

    // MARK: - Redraw (animated)
    @objc private func redrawTapped() {
        performRedraw()
    }

    private func performRedraw() {
        // 显示背面
        for cv in cardViews { cv.showBack() }

        // 生成新卡
        cards = TarotCardManager.shared.drawThreeRandomCards()

        // 禁用按钮
        navigationItem.rightBarButtonItem?.isEnabled = false

        let flipInterval: TimeInterval = 0.6
        for (index, card) in cards.enumerated() {
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

        let totalDelay = Double(cards.count) * flipInterval + 0.2
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay) {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            // 保存并追加历史
            self.saveLastQuestion()
            self.saveLastDrawn()
            self.saveToHistory()
        }
    }

    // MARK: - Persistence
    private func saveLastQuestion() {
        UserDefaults.standard.set(question, forKey: "lastQuestion")
    }

    private func saveLastDrawn() {
        let arr = cards.map { card -> [String: Any] in
            return ["id": card.id, "name": card.name, "image": card.image, "isUpright": card.isUpright, "meaning": card.currentMeaning]
        }
        UserDefaults.standard.set(arr, forKey: "lastDrawnCards")
    }

    private func saveToHistory() {
        var history = UserDefaults.standard.array(forKey: "drawHistory") as? [[String: Any]] ?? []
        let timestamp = Date().timeIntervalSince1970
        let cardsArr = cards.map { card -> [String: Any] in
            return ["id": card.id, "name": card.name, "image": card.image, "isUpright": card.isUpright, "meaning": card.currentMeaning]
        }
        let entry: [String: Any] = [
            "question": question,
            "timestamp": timestamp,
            "cards": cardsArr
        ]
        history.insert(entry, at: 0)
        UserDefaults.standard.set(history, forKey: "drawHistory")
    }
}
