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
    // 如果是从历史记录跳转过来，外部可以设置此 id，避免重复新增历史条目
    var historyID: String?
    private var redrawButton: UIButton?
    private var shareButton: UIButton?
    private var cardViews: [CardDisplayView] = []
    private var meaningLabels: [UILabel] = []
    private var analysisLabel: UILabel?
    private let reBGImageView: UIImageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // 设置统一导航栏
        setupUnifiedNavigationBar(title: "抽牌结果")

        view.backgroundColor = .systemBackground
        setupUI()
        if shouldAutoDraw && cards.isEmpty {
            cards = TarotCardManager.shared.drawThreeRandomCards()
        }
        displayCards()
        // 默认保存本次问题与抽卡结果
        saveLastQuestion()
        saveLastDrawn()
        // 在首次显示后，如果不是从历史记录打开，则把这次抽卡加入历史
        if historyID == nil {
            saveToHistory()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 确保离开时保存最后一次抽卡结果与问题
        saveLastQuestion()
        saveLastDrawn()
    }

    private func setupUI() {

        // 添加星空粒子
        ParticleManager.addStarfield(to: view)

        reBGImageView.image = UIImage.reBG
        reBGImageView.contentMode = .center
        view.addSubview(reBGImageView)
        reBGImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        view.addSubview(blur)
        blur.alpha = 0.2
        blur.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 添加环境光呼吸效果
        let ambientLight = UIView()
        ambientLight.backgroundColor = APPConstants.Color.explanationColor
        ambientLight.alpha = 0.08
        view.addSubview(ambientLight)
        ambientLight.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 启动呼吸动画
        animateAmbientLight(ambientLight)

        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        let contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        let questionLabel = UILabel()
        questionLabel.text = question.isEmpty ? "你的问题：(未填写)" : "你的问题：\n\(question)"
        questionLabel.numberOfLines = 0
        questionLabel.textAlignment = .center
        questionLabel.font = UIFont.systemFont(ofSize: 16)
        questionLabel.textColor = APPConstants.Color.titleColor
        contentView.addSubview(questionLabel)
        questionLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        let cardsContainer = UIStackView()
        cardsContainer.axis = .horizontal
        cardsContainer.distribution = .fillEqually
        cardsContainer.spacing = 12
        contentView.addSubview(cardsContainer)
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
        contentView.addSubview(meaningContainer)
        meaningContainer.snp.makeConstraints { make in
            make.top.equalTo(cardsContainer.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        for _ in 0..<3 {
            let lbl = UILabel()
            lbl.numberOfLines = 0
            lbl.font = UIFont.systemFont(ofSize: 14)
            lbl.textColor = APPConstants.Color.explanationColor
            meaningContainer.addArrangedSubview(lbl)
            meaningLabels.append(lbl)
        }

        let analysis = UILabel()
        analysis.numberOfLines = 0
        analysis.font = UIFont.systemFont(ofSize: 14)
        analysis.textColor = APPConstants.Color.bodyColor
        analysis.textAlignment = .left
        analysis.text = "结果解析："
        contentView.addSubview(analysis)
        analysis.snp.makeConstraints { make in
            make.top.equalTo(meaningContainer.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        self.analysisLabel = analysis

        // 底部按钮容器：包含再次抽卡和分享按钮
        let buttonContainer = UIStackView()
        buttonContainer.axis = .horizontal
        buttonContainer.distribution = .fillEqually
        buttonContainer.spacing = 12
        contentView.addSubview(buttonContainer)
        buttonContainer.snp.makeConstraints { make in
            make.top.equalTo(analysis.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-16)
        }

        // 再次抽卡按钮
        let bottomRedraw = UIButton(type: .system)
        bottomRedraw.setTitle("再次抽卡", for: .normal)
        bottomRedraw.setTitleColor(.white, for: .normal)
        bottomRedraw.backgroundColor = APPConstants.Color.explanationColor
        bottomRedraw.layer.cornerRadius = 22
        bottomRedraw.layer.shadowColor = APPConstants.Color.explanationColor.cgColor
        bottomRedraw.layer.shadowRadius = 8
        bottomRedraw.layer.shadowOpacity = 0.6
        bottomRedraw.layer.shadowOffset = CGSize(width: 0, height: 4)
        bottomRedraw.addTarget(self, action: #selector(redrawTapped), for: .touchUpInside)
        buttonContainer.addArrangedSubview(bottomRedraw)
        self.redrawButton = bottomRedraw

        // 分享给闺蜜按钮
        let shareButton = UIButton(type: .system)
        shareButton.setTitle("分享给闺蜜", for: .normal)
        shareButton.setTitleColor(.white, for: .normal)
        shareButton.backgroundColor = APPConstants.Color.explanationColor
        shareButton.layer.cornerRadius = 22
        shareButton.layer.shadowColor = APPConstants.Color.explanationColor.cgColor
        shareButton.layer.shadowRadius = 8
        shareButton.layer.shadowOpacity = 0.6
        shareButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        buttonContainer.addArrangedSubview(shareButton)
        self.shareButton = shareButton
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

        // 合并并显示简短解析文本（随后会向 ChatService 请求更详细的过去/现在/发展解析）
        var analysisText = "结果解析：\n"
        for (i, card) in cards.enumerated() {
            analysisText += "\(i + 1). \(card.name)：\(card.currentMeaning)\n\n"
        }
        analysisLabel?.text = analysisText

        // 调用 ChatService 获取更详细的 Past / Present / Future 解析
        fetchAnalysis()
    }

    // 使用 ChatService 向 chat/completions 发送请求，将 question 与 cards 信息组合为 prompt，要求返回更温柔、更懂用户的解析
    private func fetchAnalysis() {
        // 获取当前选择的占卜师
        let selectedReaderId = UserDefaults.standard.string(forKey: "selectedReaderId") ?? "reader_chenrou"
        let reader = ReaderManager.shared.getReader(id: selectedReaderId) ?? ReaderManager.shared.defaultReader

        // 构建消息
        var messages: [ChatRequestMessage] = []

        // 根据占卜师风格构建system prompt
        let system = ChatRequestMessage(role: "system", content: reader.style.systemPrompt)
        messages.append(system)

        // 根据占卜师风格构建user prompt
        var userContent = reader.style.userPromptTemplate
            .replacingOccurrences(of: "{{question}}", with: question)
            .replacingOccurrences(of: "{{cards}}", with: generateCardsContent())
        let userMsg = ChatRequestMessage(role: "user", content: userContent)
        messages.append(userMsg)

        // 显示 loading 文本
        DispatchQueue.main.async {
            self.analysisLabel?.text = "正在生成解析，请稍候..."
        }

        ChatService.sendText(messages: messages) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let text):
                    self.analysisLabel?.text = text
                    // 保存解析到本地（lastAnalysis）并写入对应历史记录（若来自历史则更新该 id，否则更新最新记录）
                    HistoryManager.shared.saveLastAnalysis(text)
                    if let id = self.historyID {
                        HistoryManager.shared.updateEntry(id: id, with: ["analysis": text])
                    } else if let first = HistoryManager.shared.fetchHistory().first, let id = first["id"] as? String {
                        HistoryManager.shared.updateEntry(id: id, with: ["analysis": text])
                    }
                case .failure(let err):
                    // 如果是服务器返回的错误，尝试解析响应体中的错误信息
                    if case let NetworkError.server(statusCode, data) = err {
                        var serverMsg = ""
                        if let d = data, let s = String(data: d, encoding: .utf8) {
                            serverMsg = s
                        }
                        self.analysisLabel?.text = "解析失败：server(statusCode: \(statusCode), message: \(serverMsg))"
                    } else {
                        self.analysisLabel?.text = "解析失败：\(err)"
                    }
                }
            }
        }
    }

    // MARK: - Helper Methods

    /// 生成牌的文本内容
    private func generateCardsContent() -> String {
        var content = ""
        for (i, card) in cards.enumerated() {
            content += "\(i + 1). \(card.name)【\(card.directionText)】 - \(card.currentMeaning)\n"
        }
        return content
    }

    // MARK: - Redraw (animated)
    @objc private func redrawTapped() {
        performRedraw()
    }

    // MARK: - Share
    @objc private func shareTapped() {
        presentShareSheet()
    }

    private func presentShareSheet() {
        ShareManager.shared.presentShareSheet(
            from: self,
            question: question,
            cards: cards,
            analysis: analysisLabel?.text ?? "塔罗牌解读"
        )
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
            // 翻牌完成后重新请求解析（基于新抽取的卡牌）
            self.fetchAnalysis()
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
        let cardsArr = cards.map { card -> [String: Any] in
            return ["id": card.id, "name": card.name, "image": card.image, "isUpright": card.isUpright, "meaning": card.currentMeaning]
        }
        let analysisText = analysisLabel?.text ?? ""
        // 使用 HistoryManager 保存并处理去重，返回生成的 id，并保存到 self.historyID
        let id = HistoryManager.shared.saveEntry(question: question, cards: cardsArr, analysis: analysisText)
        self.historyID = id
        // 同时保存 lastAnalysis
        HistoryManager.shared.saveLastAnalysis(analysisText)
    }

    // MARK: - 启动环境光呼吸动画
    private func animateAmbientLight(_ view: UIView) {
        UIView.animate(withDuration: 3, delay: 0, options: [.repeat, .autoreverse]) {
            view.alpha = 0.15
        }
    }
}
