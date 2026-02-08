//
//  UIColor+Hex.swift
//  tarot_cards
//
//  Created by 陈柔 on 2026/02/05.
//
//  功能说明：
//  - UIColor十六进制初始化器
//  - 支持不带#前缀和带#前缀
//  - 可选alpha透明度
//  - 非可选初始化器：用于已知有效的颜色
//
//  使用示例：
//  - UIColor(hex: "7D3FE1")        // 不带#，可选返回nil
//  - UIColor(hex: "7D3FE1", alpha: 0.8) // 带透明度
//  - UIColor.hex("7D3FE1")          // 非可选，已知有效的颜色
//

import UIKit
import SwifterSwift

extension UIColor {
    /**
     十六进制颜色初始化器（可选）
     - 支持格式：RGB值（6位）或ARGB值（8位）
     - 不带#前缀
     - 非法值返回nil
     - 示例：
       - UIColor(hex: "7D3FE1")  // 0x7D3FE1
       - UIColor(hex: "7D3FE1FF") // 0x7D3FE1FF（带alpha）
     - Returns: UIColor或nil
     */
    convenience init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0

        var rgbValue: UInt64 = 0

        if scanner.scanHexInt64(&rgbValue) {
            let r = (rgbValue & 0xFF0000) >> 16
            let g = (rgbValue & 0x00FF00) >> 8
            let b = rgbValue & 0x0000FF

            self.init(
                red: CGFloat(r) / 0xFF,
                green: CGFloat(g) / 0xFF,
                blue: CGFloat(b) / 0xFF,
                alpha: 1.0
            )
        } else {
            return nil
        }
    }

    /**
     十六进制颜色初始化器（带透明度，可选）
     - 支持格式：RGB值或ARGB值
     - 不带#前缀
     - 非法值返回nil
     - 示例：
       - UIColor(hex: "7D3FE1", alpha: 0.8)  // 紫色，80%透明度
     */
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        let hex = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        var rgbValue: UInt64 = 0

        if hex.hasPrefix("#") {
            var startIndex = hex.index(hex.startIndex, offsetBy: 1)
            var endIndex = hex.endIndex
            if hex.count > 7 {
                endIndex = hex.index(startIndex, offsetBy: 7)
            }
            let hexString = String(hex[startIndex..<endIndex])
            Scanner(string: hexString).scanHexInt64(&rgbValue)
        } else {
            Scanner(string: hex).scanHexInt64(&rgbValue)
        }

        let r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: alpha)
    }

    /**
     非可选十六进制颜色初始化器
     - 已知有效的颜色，不会返回nil
     - 无效颜色返回白色
     - 示例：
       - APPConstants.Color.titleColor = UIColor.hex("F8F8FF")  // 不会失败
     */
    static func hex(_ hex: String) -> UIColor {
        guard let color = UIColor(hex: hex) else {
            return UIColor.white
        }
        return color
    }
}
