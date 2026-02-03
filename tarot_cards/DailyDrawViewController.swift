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
    private let meaningView = UIView()
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
    }
    
    private func setupUI() {
        // 标题
        let titleLabel = UILabel()
        titleLabel.text = "✨ 今日运势签"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textColor = APPConstants.Color.titleColor
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
        }
        
        // 占卜师图标
        fortunetellerImageView.contentMode = .scaleAspectFit
        fortunetellerImageView.image = UIImage(systemName: "star.circle.fill")
        fortunetellerImageView.tintColor = .systemPurple
        fortunetellerImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 120, weight: .bold)
        view.addSubview(fortunetellerImageView)
        fortunetellerImageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(120)
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
        view.addSubview(meaningView)
        meaningView.snp.makeConstraints { make in
            make.top.equalTo(drawButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        meaningLabel.numberOfLines = 0
        meaningLabel.font = UIFont.systemFont(ofSize: 16)
        meaningLabel.textColor = APPConstants.Color.bodyColor
        meaningLabel.textAlignment = .center
        meaningView.addSubview(meaningLabel)
        meaningLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        // 历史记录按钮
        historyButton.setTitle("查看历史记录", for: .normal)
        historyButton.setTitleColor(APPConstants.Color.titleColor, for: .normal)
        historyButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        historyButton.addTarget(self, action: #selector(showHistory), for: .touchUpInside)
        view.addSubview(historyButton)
        historyButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
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
        guard !hasDrawnToday else { return }
        
        // 禁用按钮防止重复点击
        drawButton.isEnabled = false
        drawButton.setTitle("正在抽取中...", for: .normal)
        
        // 模拟抽取延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // 抽取一张牌
            let card = self.drawSingleCard()
            
            // 显示结果
            self.showDailyResult(card: card)
            
            // 标记已签到
            DailyDrawManager.shared.markTodayDrawn()
            self.hasDrawnToday = true
            self.updateUIState()
            
            // 显示成功提示
            self.showSuccessAlert()
        }
    }
    
    private func drawSingleCard() -> TarotCard {
        return TarotCardManager.shared.drawOneRandomCards().first!
    }
    
    private func showDailyResult(card: TarotCard) {
        meaningView.isHidden = false
        
        let summary = DailyDrawManager.shared.getTodayFortuneSummary(cards: [card])
        
        let resultText = """
        🎴 今日塔罗牌：\(card.name)
        
        方位：\(card.directionText)
        
        含义：\(card.currentMeaning)
        
        \(summary)
        """
        
        meaningLabel.text = resultText
        
        // 动画效果
        UIView.animate(withDuration: 0.5) {
            self.meaningView.alpha = 1.0
        }
        
        // 保存到今日记录
        DailyDrawManager.shared.saveTodayDraw(cards: [card], analysis: summary)
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(title: "🎉 签到成功！", 
                                    message: "今日运势已保存，记得要好好把握这一天哦！💕", 
                                    preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "好的", style: .default))
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
