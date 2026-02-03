//
//  DailyDrawManager.swift
//  tarot_cards
//
//  Created by 小萌 on 2026/2/3.
//

import Foundation
import UserNotifications

class DailyDrawManager {
    
    static let shared = DailyDrawManager()
    
    private let dailyDrawKey = "dailyDrawDate"
    private let dailyDrawRecordKey = "dailyDrawRecord"
    private let consecutiveDaysKey = "consecutiveDays"
    
    private init() {
        setupNotifications()
    }
    
    /// 设置每日提醒通知
    private func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                self.scheduleDailyNotification()
            }
        }
    }
    
    /// 安排每日提醒通知
    private func scheduleDailyNotification() {
        let content = UNMutableNotificationContent()
        content.title = "✨ 今日运势签到了吗？"
        content.body = "亲爱的主人，今天想不想看看今天的运势如何呀？点击打开小萌的塔罗牌app~ 💕"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "TODAY_DRAW"
        
        // 每天早上9点提醒
        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: "dailyTarotDraw", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("通知设置失败: \(error)")
            } else {
                print("每日提醒通知已设置")
            }
        }
    }
    
    /// 检查今天是否已经签到
    func hasDrawnToday() -> Bool {
        let today = self.todayString()
        let lastDrawDate = UserDefaults.standard.string(forKey: dailyDrawKey)
        return today == lastDrawDate
    }
    
    /// 获取当前日期字符串
    private func todayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    private func yesterdayString() -> String {
        let yesterday = Date().addingTimeInterval(-24 * 60 * 60)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: yesterday)
    }
    
    /// 标记今天已签到
    func markTodayDrawn() {
        let today = self.todayString()
        UserDefaults.standard.set(today, forKey: dailyDrawKey)
        
        // 更新连续签到天数
        let previousStreak = UserDefaults.standard.integer(forKey: consecutiveDaysKey)
        let lastDrawDate = UserDefaults.standard.string(forKey: "lastDrawDate")
        
        if lastDrawDate == self.yesterdayString() {
            // 连续签到
            let newStreak = previousStreak + 1
            UserDefaults.standard.set(newStreak, forKey: consecutiveDaysKey)
        } else if lastDrawDate != today {
            // 断签了，重新开始
            UserDefaults.standard.set(1, forKey: consecutiveDaysKey)
        }
        
        UserDefaults.standard.set(today, forKey: "lastDrawDate")
        
        // 保存今日抽卡记录
        saveTodayDraw()
    }
    
    /// 获取连续签到天数
    func getConsecutiveDays() -> Int {
        return UserDefaults.standard.integer(forKey: consecutiveDaysKey)
    }
    
    /// 获取今日抽卡记录
    func getTodayDraw() -> [String: Any]? {
        let today = self.todayString()
        return UserDefaults.standard.dictionary(forKey: "\(dailyDrawRecordKey)_\(today)")
    }
    
    /// 保存今日抽卡记录
    func saveTodayDraw(cards: [TarotCard]? = nil, analysis: String? = nil) {
        let today = self.todayString()
        
        var record: [String: Any] = [:]
        record["date"] = today
        record["timestamp"] = Date().timeIntervalSince1970
        
        if let cards = cards {
            let cardsData = cards.map { card -> [String: Any] in
                return [
                    "id": card.id,
                    "name": card.name,
                    "image": card.image,
                    "isUpright": card.isUpright,
                    "meaning": card.currentMeaning
                ]
            }
            record["cards"] = cardsData
        }
        
        if let analysis = analysis {
            record["analysis"] = analysis
        }
        
        UserDefaults.standard.set(record, forKey: "\(dailyDrawRecordKey)_\(today)")
    }
    
    /// 获取签到历史
    func getDrawHistory() -> [[String: Any]] {
        let today = self.todayString()
        var history: [[String: Any]] = []
        
        // 获取最近30天的记录
        for i in 0..<30 {
            let date = Date().addingTimeInterval(-Double(i * 24 * 60 * 60)).toString(format: "yyyy-MM-dd")
            if let record = UserDefaults.standard.dictionary(forKey: "\(dailyDrawRecordKey)_\(date)") {
                history.append(record)
            }
        }
        
        return history.reversed()
    }
    
    /// 获取今日运势总结（简化版）
    func getTodayFortuneSummary(cards: [TarotCard]) -> String {
        let today = Date()
        let weekday = Calendar.current.component(.weekday, from: today)
        
        let weekdayMessages = [
            "星期日": "今天是充满希望的日子，你的运势像阳光一样灿烂~ ☀️",
            "星期一": "新的一周开始了，带着满满的能量去迎接挑战吧！💪",
            "星期二": "今天是适合制定计划的日子，你的想法会很有价值~ 📝",
            "星期三": "今天是社交的好日子，会遇到有趣的人和事~ 🎉",
            "星期四": "今天适合做重要的决定，你的直觉很准确~ ✨",
            "星期五": "今天的心情会特别好，适合和朋友分享快乐~ 🌈",
            "星期六": "今天是放松的好日子，好好享受周末的美好~ 🌸"
        ]
        
        let weekdayName = weekdayMessages.keys.first { today.weekdayName().contains($0) } ?? "星期一"
        let baseMessage = weekdayMessages[weekdayName] ?? "今天是充满可能性的一天~ ✨"
        
        // 根据抽到的牌给出更具体的建议
        let positiveCards = cards.filter { $0.isUpright }
        let uprightCount = positiveCards.count
        
        if uprightCount == 3 {
            return "\(baseMessage) 三张牌都是正位，今天真的是你的幸运日！要抓住每一个机会哦！🍀"
        } else if uprightCount == 2 {
            return "\(baseMessage) 大部分牌都很好，今天会是很顺利的一天，小细节要注意一下~ 💕"
        } else if uprightCount == 1 {
            return "\(baseMessage) 今天需要更多的耐心和细心，但机会还是很多的！加油！🌟"
        } else {
            return "\(baseMessage) 今天需要特别的谨慎，但这也是一个成长的机会，相信自己！💪"
        }
    }
    
    }