//
//  ParticleSystem.swift
//  tarot_cards
//
//  Created by 陈柔 on 2026/02/05.
//
//  功能说明：
//  - 粒子系统：使用Core Animation CAEmitterLayer实现
//  - 多种粒子类型：星星、光球、流星、尘埃
//  - 紫色氛围：所有粒子使用紫色系配色
//  - 性能优化：合理的粒子数量和生命周期

//  粒子系统说明：
//  - CAEmitterLayer：Core Animation粒子发射层
//  - CAEmitterCell：单个粒子定义
//  - 粒子属性：颜色、大小、速度、生命周期、旋转等
//  - 渲染模式：additive（叠加模式，重叠处更亮）
//

import UIKit

class ParticleSystem {

    // MARK: - 深空星星系统

    /**
     从4个不同层级创建星星粒子：
     - 大星星：白色，缓慢移动，带旋转
     - 中等星星：淡白色，中等速度
     - 小星星：浅紫色，快速移动
     - 微小星星：深紫色，最快，最密集
     */
    static func createStarfieldEmitter() -> CAEmitterLayer {
        let emitter = CAEmitterLayer()
        // 增加总体发射率与发射区域以实现密集星空效果
        emitter.birthRate = 40               // 总体发射率提高
        emitter.lifetime = 10.0              // 粒子存活时间略微增加
        emitter.emitterCells = [
            createLargeStarCell(),           // 大星星
            createMediumStarCell(),          // 中等星星
            createSmallStarCell(),           // 小星星
            createTinyStarCell()             // 微小星星
        ]
        emitter.emitterPosition = CGPoint(x: 0, y: 0)
        emitter.emitterSize = CGSize(width: 800, height: 800) // 扩大发射区域（可由 ParticleManager 覆盖为 view 大小）
        emitter.emitterShape = .rectangle
        emitter.emitterMode = .surface
        emitter.fillMode = .backwards        // 粒子生成后留在屏幕
        emitter.renderMode = .additive        // 叠加渲染，更亮
        return emitter
    }

    // 大星星
    private static func createLargeStarCell() -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.contents = createStarImage(size: 10, color: APPConstants.Color.titleColor)
        cell.birthRate = 6                   // 大星星增加密度
        cell.lifetime = 8.0                  // 存活8秒
        cell.emissionRange = 2 * CGFloat.pi  // 全方位发射
        cell.velocity = 5                    // 速度5
        cell.velocityRange = 3               // 速度范围±3
        cell.spin = 0.3                      // 自转0.3弧度/秒
        cell.spinRange = 0.5                 // 自转范围±0.5
        cell.scale = 1.0                     // 初始大小1.0
        cell.scaleRange = 0.3                // 大小范围±0.3
        cell.scaleSpeed = -0.02              // 慢慢变小
        cell.alphaSpeed = -0.2               // 慢慢消失
        cell.color = APPConstants.Color.titleColor.cgColor
        cell.redRange = 0.2
        cell.greenRange = 0.2
        cell.blueRange = 0.2
        return cell
    }

    // 中等星星
    private static func createMediumStarCell() -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.contents = createStarImage(size: 6, color: UIColor(hex: "E0E0FF"))
        cell.birthRate = 8                   // 中等星星更密集
        cell.lifetime = 6.0                  // 存活6秒
        cell.emissionRange = 2 * CGFloat.pi
        cell.velocity = 8                    // 速度8
        cell.velocityRange = 4               // 速度范围±4
        cell.alphaSpeed = -0.25              // 快速消失
        cell.scale = 0.6
        cell.scaleRange = 0.4
        return cell
    }

    // 小星星
    private static func createSmallStarCell() -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.contents = createStarImage(size: 3, color: UIColor(hex: "C0C0FF"))
        cell.birthRate = 12                  // 小星星大量出现
        cell.lifetime = 5.0                  // 存活5秒
        cell.emissionRange = 2 * CGFloat.pi
        cell.velocity = 12                   // 速度12
        cell.velocityRange = 6               // 速度范围±6
        cell.alphaSpeed = -0.3               // 快速消失
        cell.scale = 0.3
        cell.scaleRange = 0.3
        return cell
    }

    // 微小星星
    private static func createTinyStarCell() -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.contents = createStarImage(size: 1.5, color: UIColor(hex: "A0A0FF"))
        cell.birthRate = 30                  // 微小星星非常密集
        cell.lifetime = 4.0                  // 存活4秒
        cell.emissionRange = 2 * CGFloat.pi
        cell.velocity = 15                   // 速度15
        cell.velocityRange = 8               // 速度范围±8
        cell.alphaSpeed = -0.4               // 很快消失
        cell.scale = 0.15
        cell.scaleRange = 0.15
        return cell
    }

    // 星星图像生成：五角星形状
    /// - Parameters:
    ///   - size: 星星大小
    ///   - color: 星星颜色
    /// - Returns: CGImage
    private static func createStarImage(size: CGFloat, color: UIColor) -> CGImage {
        let w = size
        let h = size
        UIGraphicsBeginImageContextWithOptions(CGSize(width: w, height: h), false, 0)
        let context = UIGraphicsGetCurrentContext()!

        context.setFillColor(color.cgColor)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: w/2, y: 0))
        path.addLine(to: CGPoint(x: w*0.6, y: h*0.3))
        path.addLine(to: CGPoint(x: w, y: h*0.5))
        path.addLine(to: CGPoint(x: w*0.6, y: h*0.7))
        path.addLine(to: CGPoint(x: w/2, y: h))
        path.addLine(to: CGPoint(x: w*0.4, y: h*0.7))
        path.addLine(to: CGPoint(x: 0, y: h*0.5))
        path.addLine(to: CGPoint(x: w*0.4, y: h*0.3))
        path.close()
        path.fill()

        let image = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
        UIGraphicsEndImageContext()
        return image!
    }

    // MARK: - 流星系统

    /**
     流星粒子系统：
     - 流星：白色拖尾，快速划过屏幕
     - 每秒0.3个（10秒才出现一个）
     - 拖尾长度：40x4
     - 速度：50-150
     */
    static func createShootingStarEmitter() -> CAEmitterLayer {
        let emitter = CAEmitterLayer()
        emitter.birthRate = 0.3              // 每秒0.3个（10秒一个）
        emitter.lifetime = 2.0               // 存活2秒
        emitter.emitterCells = [createShootingStarCell()]
        emitter.emitterPosition = CGPoint(x: 0, y: 0)
        emitter.emitterSize = CGSize(width: 1, height: 1)
        emitter.emitterShape = .rectangle
        emitter.emitterMode = .surface
        emitter.fillMode = .removed         // 流星消失后不再渲染
        emitter.renderMode = .additive
        return emitter
    }

    private static func createShootingStarCell() -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.contents = createShootingStarImage()
        cell.birthRate = 0.3
        cell.lifetime = 2.0
        cell.emissionRange = 0.3             // 范围很小，只向上方发射
        cell.velocity = 100                  // 速度100
        cell.velocityRange = 50              // 速度范围±50
        cell.spin = -0.5                     // 逆时针旋转
        cell.spinRange = 0.5
        cell.scale = 0.5
        cell.scaleRange = 0.5
        cell.alphaSpeed = -0.5               // 快速消失
        cell.color = APPConstants.Color.titleColor.cgColor
        cell.redRange = 0.2
        cell.greenRange = 0.2
        cell.blueRange = 0.2
        return cell
    }

    // 流星图像：渐变线条
    private static func createShootingStarImage() -> CGImage {
        let w = 40
        let h = 4
        UIGraphicsBeginImageContextWithOptions(CGSize(width: w, height: h), false, 0)
        let context = UIGraphicsGetCurrentContext()!

        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                   colors: [APPConstants.Color.titleColor.cgColor, UIColor.clear.cgColor] as CFArray,
                                   locations: [0.0, 1.0])!

        context.drawLinearGradient(gradient,
                                   start: CGPoint(x: 0, y: 0),
                                   end: CGPoint(x: w, y: 0),
                                   options: [])

        let image = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
        UIGraphicsEndImageContext()
        return image!
    }

    // MARK: - 漂浮光球系统

    /**
     漂浮光球系统：
     - 光球：紫色+青色光晕
     - 速度：2-5（很慢）
     - 大小：0.4
     - 呼吸效果：透明度-0.15（慢慢消失）
     */
    static func createOrbEmitter() -> CAEmitterLayer {
        let emitter = CAEmitterLayer()
        emitter.birthRate = 2                // 每秒2个
        emitter.lifetime = 6.0               // 存活6秒
        emitter.emitterCells = [createOrbCell()]
        emitter.emitterPosition = CGPoint(x: 0, y: 0)
        emitter.emitterSize = CGSize(width: 1, height: 1)
        emitter.emitterShape = .rectangle
        emitter.emitterMode = .surface
        emitter.fillMode = .backwards        // 留在屏幕
        emitter.renderMode = .additive
        return emitter
    }

    private static func createOrbCell() -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.contents = createOrbImage()
        cell.birthRate = 2
        cell.lifetime = 6.0
        cell.emissionRange = 2 * CGFloat.pi
        cell.velocity = 3                    // 很慢
        cell.velocityRange = 2
        cell.spin = 0.2                      // 轻轻旋转
        cell.spinRange = 0.3
        cell.scale = 0.4
        cell.scaleRange = 0.4
        cell.scaleSpeed = -0.015             // 很慢变小
        cell.alphaSpeed = -0.15              // 慢慢消失
        cell.color = APPConstants.Color.explanationColor.cgColor
        cell.redRange = 0.2
        cell.greenRange = 0.2
        cell.blueRange = 0.2
        return cell
    }

    // 光球图像：紫色圆形 + 青色光晕
    private static func createOrbImage() -> CGImage {
        let w = 8
        let h = 8
        UIGraphicsBeginImageContextWithOptions(CGSize(width: w, height: h), false, 0)
        let context = UIGraphicsGetCurrentContext()!

        context.setFillColor(APPConstants.Color.explanationColor.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: w, height: h))

        // 添加柔和光晕
        context.setFillColor(UIColor(hex: "A5F2FF").withAlphaComponent(0.3).cgColor)
        context.fillEllipse(in: CGRect(x: 1, y: 1, width: 6, height: 6))

        let image = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
        UIGraphicsEndImageContext()
        return image!
    }

    // MARK: - 宇宙尘埃系统

    /**
     宇宙尘埃系统：
     - 尘埃：深紫色微点
     - 密度：15个/秒（非常密集）
     - 速度：5-8（很慢）
     - 大小：0.1（非常小）
     */
    static func createDustEmitter() -> CAEmitterLayer {
        let emitter = CAEmitterLayer()
        emitter.birthRate = 15               // 每秒15个
        emitter.lifetime = 10.0              // 存活10秒
        emitter.emitterCells = [createDustCell()]
        emitter.emitterPosition = CGPoint(x: 0, y: 0)
        emitter.emitterSize = CGSize(width: 0, height: 0)
        emitter.emitterShape = .rectangle
        emitter.emitterMode = .surface
        emitter.fillMode = .removed
        emitter.renderMode = .additive
        return emitter
    }

    private static func createDustCell() -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.contents = createDustImage()
        cell.birthRate = 15
        cell.lifetime = 10.0
        cell.emissionRange = 2 * CGFloat.pi
        cell.velocity = 5
        cell.velocityRange = 3
        cell.alphaSpeed = -0.1
        cell.scale = 0.1
        cell.scaleRange = 0.05
        cell.color = UIColor(hex: "5D3FD3").cgColor
        return cell
    }

    private static func createDustImage() -> CGImage {
        let w = 2
        let h = 2
        UIGraphicsBeginImageContextWithOptions(CGSize(width: w, height: h), false, 0)
        let context = UIGraphicsGetCurrentContext()!

        context.setFillColor(UIColor(hex: "5D3FD3").cgColor)
        context.fill(CGRect(x: 0, y: 0, width: w, height: h))

        let image = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
        UIGraphicsEndImageContext()
        return image!
    }
}
