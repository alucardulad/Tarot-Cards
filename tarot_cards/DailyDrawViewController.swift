//
//  DailyDrawViewController.swift
//  tarot_cards
//
//  Created by 小萌 on 2026/2/3.
//

import UIKit
import SnapKit

class DailyDrawViewController: UIViewController {
    
    private let welcomeLabel = UILabel()
    private let streakLabel = UILabel()
    private let drawButton = UIButton(type: .system)
    private let fortunetellerImageView = UIImageView()
    private let meaningView = UIScrollView()
    private let meaningLabel = UILabel()
    private let historyButton = UIButton(type: .system)
    private var hasDrawnToday = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        updateDailyStatus()
        
        // 检查是否今天已经抽过
        hasDrawnToday = DailyDrawManager.shared.hasDrawnToday()
        updateUIState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDailyStatus()
        // 刷新今天是否已签到状态，防止从其他页面返回时状态不同步
        hasDrawnToday = DailyDrawManager.shared.hasDrawnToday()
        updateUIState()
    }
    
    private func setupUI() {
        // 背景图（如果有名为 reBG 的资源则使用）
        if let bg = UIImage(named: "reBG") {
            let bgView = UIImageView(image: bg)
            bgView.contentMode = .scaleAspectFill
            view.insertSubview(bgView, at: 0)
            bgView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
            view.insertSubview(blur, aboveSubview: bgView)
            blur.alpha = 0.18
            blur.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }

        // 标题
        let titleLabel = UILabel()
        titleLabel.text = "✨ 今日运势签"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textColor = APPConstants.Color.titleColor
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.centerX.equalToSuperview()
        }
        
        // 占卜师图标
        fortunetellerImageView.image = UIImage.init(named: "card_back")
        fortunetellerImageView.tintColor = .systemPurple
//        fortunetellerImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 120, weight: .bold)
        view.addSubview(fortunetellerImageView)
        fortunetellerImageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(291/2)
            make.height.equalTo(512/2)
        }
        
        // 欢迎语
        welcomeLabel.numberOfLines = 0
        welcomeLabel.textAlignment = .center
        welcomeLabel.font = UIFont.systemFont(ofSize: 18)
        welcomeLabel.textColor = APPConstants.Color.bodyColor
        view.addSubview(welcomeLabel)
        welcomeLabel.snp.makeConstraints { make in
            make.top.equalTo(fortunetellerImageView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        // 连续签到天数
        streakLabel.numberOfLines = 0
        streakLabel.textAlignment = .center
        streakLabel.font = UIFont.italicSystemFont(ofSize: 16)
        streakLabel.textColor = APPConstants.Color.explanationColor
        view.addSubview(streakLabel)
        streakLabel.snp.makeConstraints { make in
            make.top.equalTo(welcomeLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        // 抽卡按钮
        drawButton.setTitle("抽取今日运势", for: .normal)
        drawButton.setTitleColor(.white, for: .normal)
        drawButton.backgroundColor = .systemPurple
        drawButton.layer.cornerRadius = 25
        drawButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        drawButton.addTarget(self, action: #selector(drawDailyFortune), for: .touchUpInside)
        drawButton.layer.shadowColor = UIColor.systemPurple.cgColor
        drawButton.layer.shadowRadius = 10
        drawButton.layer.shadowOpacity = 0.5
        drawButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        view.addSubview(drawButton)
        drawButton.snp.makeConstraints { make in
            make.top.equalTo(streakLabel.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        
        // 含义展示区域
        meaningView.backgroundColor = UIColor.systemGray.withAlphaComponent(0.1)
        meaningView.layer.cornerRadius = 15
        meaningView.isHidden = true
        meaningView.alpha = 0 // 初始透明，便于淡入动画
        view.addSubview(meaningView)
        meaningView.snp.makeConstraints { make in
            make.top.equalTo(drawButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            // 限制底部，避免无限扩展并允许内部滚动
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60)
        }
        
        meaningLabel.numberOfLines = 0
        meaningLabel.font = UIFont.systemFont(ofSize: 16)
        meaningLabel.textColor = APPConstants.Color.bodyColor
        meaningLabel.textAlignment = .center
        meaningView.addSubview(meaningLabel)
        // 将 label 约束到 scroll view 的 contentLayoutGuide，使其成为可滚动内容
        meaningLabel.snp.makeConstraints { make in
            make.top.equalTo(meaningView.contentLayoutGuide.snp.top).offset(16)
            make.leading.equalTo(meaningView.contentLayoutGuide.snp.leading).offset(16)
            make.trailing.equalTo(meaningView.contentLayoutGuide.snp.trailing).offset(-16)
            make.bottom.equalTo(meaningView.contentLayoutGuide.snp.bottom).offset(-16)
            // 宽度与可见区域一致，避免横向滚动
            make.width.equalTo(meaningView.frameLayoutGuide.snp.width).offset(-32)
        }
        
//        // 历史记录按钮
        historyButton.setTitle("查看历史记录", for: .normal)
        historyButton.setTitleColor(APPConstants.Color.titleColor, for: .normal)
        historyButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        historyButton.addTarget(self, action: #selector(showHistory), for: .touchUpInside)
        view.addSubview(historyButton)
        historyButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.centerX.equalToSuperview()
        }
    }
    
    private func updateDailyStatus() {
        let now = Date()
        let hour = Calendar.current.component(.hour, from: now)
        
        var welcomeText = ""
        if hour < 6 {
            welcomeText = "深夜好呀~ 主人还在看运势吗？夜晚的星星特别美呢~ ✨"
        } else if hour < 12 {
            welcomeText = "早上好呀~ 新的一天开始了，想知道今天的运势如何吗？🌅"
        } else if hour < 18 {
            welcomeText = "下午好呀~ 今天过得怎么样？要不要看看今天的运势指引？☀️"
        } else {
            welcomeText = "晚上好呀~ 一天辛苦啦！来看看今天的运势总结吧~ 🌙"
        }
        
        welcomeLabel.text = welcomeText
        
        // 更新连续签到天数
        let streak = DailyDrawManager.shared.getConsecutiveDays()
        if streak > 1 {
            streakLabel.text = "🔥 连续签到 \(streak) 天啦！坚持就是胜利哦！💪"
        } else {
            streakLabel.text = "🌟 今天也要记得来看看运势哦~"
        }
    }
    
    private func updateUIState() {
        if hasDrawnToday {
            drawButton.setTitle("今日已签到", for: .normal)
            drawButton.backgroundColor = .systemGray
            drawButton.isEnabled = false
        } else {
            drawButton.setTitle("抽取今日运势", for: .normal)
            drawButton.backgroundColor = .systemPurple
            drawButton.isEnabled = true
        }
    }
    
    @objc private func drawDailyFortune() {
#if !DEBUG
        // 线上/非调试模式下，若已签到则禁止再次抽取
        guard !hasDrawnToday else { return }
#endif
        
        // 禁用按钮防止重复点击
        drawButton.isEnabled = false
        drawButton.setTitle("正在抽取中...", for: .normal)
        
        // 模拟抽取延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            // 抽取一张牌（安全返回）
            guard let card = self.drawSingleCard() else {
                // 恢复按钮并提示错误
                self.drawButton.isEnabled = true
                self.updateUIState()
                let alert = UIAlertController(title: "出错了", message: "未能抽到卡牌，请稍后重试。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .default))
                self.present(alert, animated: true)
                return
            }

            // 显示结果（初始简短信息）
            self.showDailyResult(card: card)

            // 标记已签到
            DailyDrawManager.shared.markTodayDrawn()
            self.hasDrawnToday = true
            self.updateUIState()

            // 显示成功提示
            self.showSuccessAlert()
        }
    }
    
    private func drawSingleCard() -> TarotCard? {
        return TarotCardManager.shared.drawOneRandomCards().first
    }
    
    private func showDailyResult(card: TarotCard) {
        // 先显示基础信息，随后异步获取更详细解析并更新
        meaningView.isHidden = false
        meaningView.alpha = 0

        let summary = DailyDrawManager.shared.getTodayFortuneSummary(cards: [card])

        let initialText = """
        🎴 今日塔罗牌：\(card.name)

        方位：\(card.directionText)

        含义：\(card.currentMeaning)

        \(summary)
        """

        meaningLabel.text = initialText

        // 淡入动画
        UIView.animate(withDuration: 0.5) {
            self.meaningView.alpha = 1.0
        }

        // 用 fortunetellerImageView 做翻转替换，保持原始约束尺寸不变
        fortunetellerImageView.contentMode = .scaleAspectFill
        fortunetellerImageView.clipsToBounds = true
        UIView.transition(with: fortunetellerImageView, duration: 0.5, options: [.transitionFlipFromRight], animations: {
            self.fortunetellerImageView.image = UIImage(named: card.image)
        }, completion: { _ in
            // 根据正逆位微调图片旋转以表示方向
            UIView.animate(withDuration: 0.12) {
                self.fortunetellerImageView.transform = card.isUpright ? .identity : CGAffineTransform(rotationAngle: .pi)
            }
        })

        // 先保存简要信息，随后当 ChatService 返回更详尽解析时再更新并保存
        DailyDrawManager.shared.saveTodayDraw(cards: [card], analysis: summary)

        // 请求更详细解析（与 ResultViewController 风格一致）
        fetchAnalysisFor(card: card)
    }

    // 使用 ChatService 为单张牌获取更详细的今日运势解析，并更新展示与保存
    private func fetchAnalysisFor(card: TarotCard) {
        var messages: [ChatRequestMessage] = []
        let system = ChatRequestMessage(role: "system", content: "你是经验丰富的塔罗牌解读师。请根据用户给出的塔罗牌信息，返回结构化的中文解析，不要输出其他无关内容。")
        messages.append(system)

        let userContent = "牌面信息：\n1. \(card.name) 【\(card.directionText)】 - \(card.currentMeaning)\n\n请基于上述信息给出“今日运势”的解析，并在最后给出总结（中文）。"
        let userMsg = ChatRequestMessage(role: "user", content: userContent)
        messages.append(userMsg)

        DispatchQueue.main.async {
            // 可在界面上提示正在生成更详细解析
            // 这里简单在现有文本下追加 loading 提示
            self.meaningLabel.text = (self.meaningLabel.text ?? "") + "\n\n正在生成更详细解析，请稍候..."
        }

        ChatService.sendText(messages: messages) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let text):
                    // 更新展示并保存完整解析
                    self.meaningLabel.text = text
                    DailyDrawManager.shared.saveTodayDraw(cards: [card], analysis: text)
                case .failure(let err):
                    // 失败时保留已有简要文本并附上错误提示
                    self.meaningLabel.text = (self.meaningLabel.text ?? "") + "\n\n生成解析失败：\(err)"
                }
            }
        }
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(title: "🎉 签到成功！", 
                                    message: "今日运势已保存，记得要好好把握这一天哦！💕\n\n现在可以去随心所欲地占卜啦~", 
                                    preferredStyle: .alert)
        
        // 查看今日运势详情
        let viewDetailsAction = UIAlertAction(title: "查看详情", style: .default) { [weak self] _ in
            // 用户可以查看今天的运势详情
        }
        viewDetailsAction.setValue(UIColor.systemPurple, forKey: "titleTextColor")
        alert.addAction(viewDetailsAction)
        
        // 去随意抽卡
        let casualDrawAction = UIAlertAction(title: "去随意抽卡", style: .default) { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        }
        casualDrawAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        alert.addAction(casualDrawAction)
        
        // 简单确认
        let okAction = UIAlertAction(title: "好的", style: .cancel)
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
    
    @objc private func showHistory() {
        let historyVC = DailyDrawHistoryViewController()
        navigationController?.pushViewController(historyVC, animated: true)
    }
}

// 日期格式化扩展
extension Date {
    func toString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func weekdayName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }
}
