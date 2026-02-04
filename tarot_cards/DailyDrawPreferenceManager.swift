//
//  DailyDrawPreferenceManager.swift
//  tarot_cards
//
//  Created by 小萌 on 2026/2/3.
//

import Foundation

class DailyDrawPreferenceManager {
    
    static let shared = DailyDrawPreferenceManager()
    
    // MARK: - 偏好设置键
    private let dailyDrawPriorityKey = "dailyDrawPriorityEnabled"
    private let reminderIntervalKey = "dailyDrawReminderInterval"
    private let skipTodayKey = "skipDailyDrawToday"
    private let firstLaunchKey = "firstDailyDrawReminderShown"
    
    private init() {}
    
    // MARK: - 主要偏好设置
    
    /// 每日一签优先模式是否启用
    /// 这个控制是否在应用启动时显示每日一签提醒
    var isDailyDrawPriorityEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: dailyDrawPriorityKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: dailyDrawPriorityKey)
        }
    }
    
    /// 提醒间隔（分钟）
    /// 用户可以选择多久提醒一次
    var reminderInterval: TimeInterval {
        get {
            let interval = UserDefaults.standard.double(forKey: reminderIntervalKey)
            return interval > 0 ? interval : 30 * 60 // 默认30分钟
        }
        set {
            UserDefaults.standard.set(newValue, forKey: reminderIntervalKey)
        }
    }
    
    /// 今日是否选择跳过每日一签
    var isSkipToday: Bool {
        get {
            let today = Date().toString(format: "yyyy-MM-dd")
            return UserDefaults.standard.bool(forKey: "\(skipTodayKey)_\(today)")
        }
        set {
            let today = Date().toString(format: "yyyy-MM-dd")
            UserDefaults.standard.set(newValue, forKey: "\(skipTodayKey)_\(today)")
        }
    }
    
    /// 是否显示过首次引导
    var hasShownFirstLaunchReminder: Bool {
        get {
            return UserDefaults.standard.bool(forKey: firstLaunchKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: firstLaunchKey)
        }
    }
    
    // MARK: - 便利方法
    
    /// 检查是否应该显示每日一签提醒
    /// 综合考虑用户偏好、完成状态和时间间隔
    func shouldShowDailyDrawReminder() -> Bool {
        
        // 如果用户关闭了优先模式，不显示提醒
        guard isDailyDrawPriorityEnabled else { return false }
        
        // 如果今日已完成每日一签，不显示提醒
        guard DailyDrawManager.shared.hasDrawnToday() == false else { return false }
        
        // 如果用户今日选择跳过，不显示提醒
        guard isSkipToday == false else { return false }
        
        // 如果是首次使用，显示引导
        if !hasShownFirstLaunchReminder {
            hasShownFirstLaunchReminder = true
            return true
        }
        
        // 根据提醒间隔检查是否应该再次提醒
        let lastReminderTime = UserDefaults.standard.double(forKey: "lastDailyDrawReminderTime")
        let currentTime = Date().timeIntervalSince1970
        
        return currentTime - lastReminderTime >= reminderInterval
    }
    
    /// 记录提醒时间
    func recordReminderTime() {
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "lastDailyDrawReminderTime")
    }
    
    /// 重置今日跳过状态
    func resetSkipToday() {
        let tomorrow = Date().addingTimeInterval(24 * 60 * 60)
        let tomorrowString = tomorrow.toString(format: "yyyy-MM-dd")
        
        // 清除明天的跳过标记（如果存在）
        UserDefaults.standard.set(false, forKey: "\(skipTodayKey)_\(tomorrowString)")
        
        // 清除今天的跳过标记
        isSkipToday = false
    }
    
    // MARK: - 预设偏好
    
    /// 获取推荐设置
    static func getRecommendedSettings() -> (enabled: Bool, interval: TimeInterval) {
        return (enabled: true, interval: 30 * 60) // 30分钟
    }
    
    /// 获取严格模式设置
    static func getStrictModeSettings() -> (enabled: Bool, interval: TimeInterval) {
        return (enabled: true, interval: 5 * 60) // 5分钟
    }
    
    /// 获取宽松模式设置
    static func getLooseModeSettings() -> (enabled: Bool, interval: TimeInterval) {
        return (enabled: false, interval: 60 * 60) // 1小时
    }
}
