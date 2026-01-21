//
//  HistoryManager.swift
//  tarot_cards
//
//  Created by copilot on 2026/1/21.
//

import Foundation

final class HistoryManager {
    static let shared = HistoryManager()
    private init() {}

    private let storageKey = "drawHistory"
    private let lastAnalysisKey = "lastAnalysis"

    func formattedTimestamp() -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "zh_CN")
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return fmt.string(from: Date())
    }

    func fetchHistory() -> [[String: Any]] {
        return UserDefaults.standard.array(forKey: storageKey) as? [[String: Any]] ?? []
    }

    func saveHistory(_ history: [[String: Any]]) {
        UserDefaults.standard.set(history, forKey: storageKey)
    }

    @discardableResult
    func saveEntry(question: String, cards: [[String: Any]], analysis: String?) -> String {
        var history = fetchHistory()
        let id = formattedTimestamp()
        let timestamp = Date().timeIntervalSince1970
        let entry: [String: Any] = [
            "id": id,
            "question": question,
            "timestamp": timestamp,
            "cards": cards,
            "analysis": analysis ?? ""
        ]

        if let existingIndex = history.firstIndex(where: { ($0["id"] as? String) == id }) {
            history[existingIndex] = entry
        } else {
            history.insert(entry, at: 0)
        }
        saveHistory(history)
        return id
    }

    func updateEntry(id: String, with fields: [String: Any]) {
        var history = fetchHistory()
        guard let idx = history.firstIndex(where: { ($0["id"] as? String) == id }) else { return }
        var entry = history[idx]
        for (k, v) in fields { entry[k] = v }
        history[idx] = entry
        saveHistory(history)
    }

    func deleteEntry(id: String) {
        var history = fetchHistory()
        history.removeAll(where: { ($0["id"] as? String) == id })
        saveHistory(history)
    }

    func saveLastAnalysis(_ text: String) {
        UserDefaults.standard.set(text, forKey: lastAnalysisKey)
    }

    func lastAnalysis() -> String? {
        return UserDefaults.standard.string(forKey: lastAnalysisKey)
    }
}
