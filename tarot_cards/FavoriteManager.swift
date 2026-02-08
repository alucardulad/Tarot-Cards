//
//  FavoriteManager.swift
//  tarot_cards
//
//  Created by 陈柔 on 2026/2/8.
//

import Foundation
import SwifterSwift

class FavoriteManager {
    static let shared = FavoriteManager()

    private let favoritesKey = "tarot_favorites"

    private init() {
        // Private init for singleton
    }

    /// 添加卡牌到收藏
    func addFavorite(_ card: TarotCard) {
        var favorites = loadFavorites()

        // 检查是否已收藏
        if favorites.contains(where: { $0.id == card.id }) {
            return // 已经收藏了
        }

        favorites.append(card)
        saveFavorites(favorites)
    }

    /// 从收藏中移除卡牌
    func removeFavorite(_ card: TarotCard) {
        var favorites = loadFavorites()

        favorites.removeAll { $0.id == card.id }

        saveFavorites(favorites)
    }

    /// 切换收藏状态
    func toggleFavorite(_ card: TarotCard) -> Bool {
        var favorites = loadFavorites()

        if let index = favorites.firstIndex(where: { $0.id == card.id }) {
            favorites.remove(at: index)
            saveFavorites(favorites)
            return false // 已取消收藏
        } else {
            favorites.append(card)
            saveFavorites(favorites)
            return true // 已收藏
        }
    }

    /// 检查是否已收藏
    func isFavorite(_ card: TarotCard) -> Bool {
        let favorites = loadFavorites()
        return favorites.contains(where: { $0.id == card.id })
    }

    /// 获取所有收藏的卡牌
    func getAllFavorites() -> [TarotCard] {
        return loadFavorites()
    }

    /// 获取收藏数量
    func getFavoritesCount() -> Int {
        return loadFavorites().count
    }

    /// 清空所有收藏
    func clearAllFavorites() {
        saveFavorites([])
    }

    // MARK: - 私有方法

    private func loadFavorites() -> [TarotCard] {
        guard let data = UserDefaults.standard.data(forKey: favoritesKey),
              let favorites = try? JSONDecoder().decode([TarotCard].self, from: data) else {
            return []
        }
        return favorites
    }

    private func saveFavorites(_ favorites: [TarotCard]) {
        if let data = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }
}
