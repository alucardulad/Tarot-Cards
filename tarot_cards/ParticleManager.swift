//
//  ParticleManager.swift
//  tarot_cards
//
//  Created by 陈柔 on 2026/02/06.
//
//  功能说明：
//  - 粒子特效管理器：封装ParticleSystem，提供简单API
//  - 支持多种粒子效果：星空、光球、流星、尘埃
//  - 自动生命周期管理：在 deinit 时自动清理
//  - 零配置使用：一行代码添加效果

//  使用方式：
//  // 添加星空粒子
//  ParticleManager.addStarfield(to: view)

//  // 添加光球粒子
//  ParticleManager.addOrbs(to: view)

//  // 移除所有粒子
//  ParticleManager.removeParticles(from: view)

//  视觉特点：
//  - 深紫色氛围
//  - 多种粒子类型混合
//  - 性能优化（合理的粒子数量）
//

import UIKit

class ParticleManager {

    // MARK: - 星空粒子

    /**
     添加深空星星粒子效果
     - 效果：多种星星混合（大星星、中等星星、小星星、微小星星）
     - 颜色：白色、淡白、浅紫、深紫
     - 位置：整个屏幕发射
     - 性能：每秒8个粒子，存活8秒
     */
    static func addStarfield(to view: UIView) {
        let particleLayer = ParticleSystem.createStarfieldEmitter()
        particleLayer.emitterPosition = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        particleLayer.frame = view.bounds
        particleLayer.emitterSize = view.bounds.size
        particleLayer.emitterShape = .rectangle
        view.layer.addSublayer(particleLayer)
        
        // 添加清理标记
        objc_setAssociatedObject(view, &associatedKeys.starfieldKey, particleLayer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    // MARK: - 光球粒子

    /**
     添加漂浮光球粒子效果
     - 效果：紫色光球 + 青色光晕
     - 速度：缓慢（2-5像素/秒）
     - 位置：整个屏幕发射
     - 性能：每秒2个粒子，存活6秒
     */
    static func addOrbs(to view: UIView) {
        let particleLayer = ParticleSystem.createOrbEmitter()
        particleLayer.emitterPosition = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        particleLayer.frame = view.bounds
        particleLayer.emitterSize = view.bounds.size
        particleLayer.emitterShape = .rectangle
        view.layer.addSublayer(particleLayer)
        
        objc_setAssociatedObject(view, &associatedKeys.orbsKey, particleLayer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    // MARK: - 流星粒子

    /**
     添加流星粒子效果
     - 效果：白色拖尾，快速划过
     - 频率：每秒0.3个（约10秒一个）
     - 位置：整个屏幕发射
     - 性能：每秒0.3个粒子，存活2秒
     */
    static func addShootingStars(to view: UIView) {
        let particleLayer = ParticleSystem.createShootingStarEmitter()
        particleLayer.emitterPosition = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        particleLayer.frame = view.bounds
        particleLayer.emitterSize = view.bounds.size
        particleLayer.emitterShape = .rectangle
        view.layer.addSublayer(particleLayer)
        
        objc_setAssociatedObject(view, &associatedKeys.shootingStarsKey, particleLayer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    // MARK: - 宇宙尘埃粒子

    /**
     添加宇宙尘埃粒子效果
     - 效果：深紫色微点
     - 密度：非常密集（每秒15个）
     - 位置：整个屏幕发射
     - 性能：每秒15个粒子，存活10秒
     */
    static func addDust(to view: UIView) {
        let particleLayer = ParticleSystem.createDustEmitter()
        particleLayer.emitterPosition = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        particleLayer.frame = view.bounds
        particleLayer.emitterSize = view.bounds.size
        particleLayer.emitterShape = .rectangle
        view.layer.addSublayer(particleLayer)
        
        objc_setAssociatedObject(view, &associatedKeys.dustKey, particleLayer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    // MARK: - 混合粒子效果

    /**
     添加完整的星空混合粒子效果
     - 包含：星星 + 光球 + 流星 + 尘埃
     - 适合：主界面、鉴赏页等需要沉浸式效果的页面
     */
    static func addFullEffects(to view: UIView) {
        addStarfield(to: view)
        addOrbs(to: view)
        addShootingStars(to: view)
        addDust(to: view)
    }

    // MARK: - 移除粒子

    /**
     移除所有粒子效果
     - 参数：
       - view: 添加粒子的视图
     */
    static func removeParticles(from view: UIView) {
        if let layer = objc_getAssociatedObject(view, &associatedKeys.starfieldKey) as? CAEmitterLayer {
            layer.removeAllAnimations()
            layer.removeFromSuperlayer()
        }

        if let layer = objc_getAssociatedObject(view, &associatedKeys.orbsKey) as? CAEmitterLayer {
            layer.removeAllAnimations()
            layer.removeFromSuperlayer()
        }

        if let layer = objc_getAssociatedObject(view, &associatedKeys.shootingStarsKey) as? CAEmitterLayer {
            layer.removeAllAnimations()
            layer.removeFromSuperlayer()
        }

        if let layer = objc_getAssociatedObject(view, &associatedKeys.dustKey) as? CAEmitterLayer {
            layer.removeAllAnimations()
            layer.removeFromSuperlayer()
        }
    }

    /**
     移除单个粒子效果
     - 参数：
       - view: 添加粒子的视图
       - effectType: 粒子类型
     */
    static func removeParticle(type effectType: EffectType, from view: UIView) {
        switch effectType {
        case .starfield:
            if let layer = objc_getAssociatedObject(view, &associatedKeys.starfieldKey) as? CAEmitterLayer {
                layer.removeAllAnimations()
                layer.removeFromSuperlayer()
            }
        case .orbs:
            if let layer = objc_getAssociatedObject(view, &associatedKeys.orbsKey) as? CAEmitterLayer {
                layer.removeAllAnimations()
                layer.removeFromSuperlayer()
            }
        case .shootingStars:
            if let layer = objc_getAssociatedObject(view, &associatedKeys.shootingStarsKey) as? CAEmitterLayer {
                layer.removeAllAnimations()
                layer.removeFromSuperlayer()
            }
        case .dust:
            if let layer = objc_getAssociatedObject(view, &associatedKeys.dustKey) as? CAEmitterLayer {
                layer.removeAllAnimations()
                layer.removeFromSuperlayer()
            }
        }
    }

    // MARK: - 生命周期管理

    /**
     在视图布局变化时更新粒子层尺寸
     - 参数：
       - view: 视图
     */
    static func updateBounds(for view: UIView) {
        if let layer = objc_getAssociatedObject(view, &associatedKeys.starfieldKey) as? CAEmitterLayer {
            layer.frame = view.bounds
            layer.emitterPosition = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
            layer.emitterSize = view.bounds.size
            layer.emitterShape = .rectangle
        }

        if let layer = objc_getAssociatedObject(view, &associatedKeys.orbsKey) as? CAEmitterLayer {
            layer.frame = view.bounds
            layer.emitterPosition = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
            layer.emitterSize = view.bounds.size
            layer.emitterShape = .rectangle
        }

        if let layer = objc_getAssociatedObject(view, &associatedKeys.shootingStarsKey) as? CAEmitterLayer {
            layer.frame = view.bounds
            layer.emitterPosition = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
            layer.emitterSize = view.bounds.size
            layer.emitterShape = .rectangle
        }

        if let layer = objc_getAssociatedObject(view, &associatedKeys.dustKey) as? CAEmitterLayer {
            layer.frame = view.bounds
            layer.emitterPosition = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
            layer.emitterSize = view.bounds.size
            layer.emitterShape = .rectangle
        }
    }

    /**
     自动清理函数：在 deinit 时调用
     - 需要在 ViewController 的 deinit 中调用
     */
    static func cleanup(for view: UIView) {
        removeParticles(from: view)
    }

    // MARK: - 枚举类型

    enum EffectType {
        case starfield
        case orbs
        case shootingStars
        case dust
    }
}

// MARK: - 关联对象键

private enum associatedKeys {
    static var starfieldKey: UInt8 = 0
    static var orbsKey: UInt8 = 1
    static var shootingStarsKey: UInt8 = 2
    static var dustKey: UInt8 = 3
}
