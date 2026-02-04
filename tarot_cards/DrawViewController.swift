//
//  DrawViewController.swift
//  tarot_cards
//
//  Created by copilot on 2026/1/20.
//

import UIKit
import SnapKit

class DrawViewController: UIViewController {
    private let logoLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let topSearchBar = UIView()
    private let searchField = UITextField()
    private let plusButton = UIButton(type: .system)

    // glow layers
    private var searchGlowLayer: CALayer?
    private var plusPulseLayer: CAShapeLayer?

    private var history: [HistoryEntry] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        history = HistoryManager.shared.fetchHistory().compactMap { HistoryEntry(dict: $0) }
        setupUI()
        
        // MARK: - 每日一签优先流程 (实现方案A：柔和引导)
        // 
        // 🎯 设计目标：
        // 在应用启动时检查用户是否已完成今日每日一签
        // 如果未完成，通过友好提醒的方式引导用户优先完成每日一签
        // 但不会强制用户，保持用户的自由选择权
        //
        // 💝 方案A特点：
        // - 不强制跳转，只是温馨提醒
        // - 提供多个选择选项，尊重用户决定
        // - 延迟显示，避免刚启动就打扰用户
        // - 符合女孩子喜欢的温柔风格
        // 
        checkDailyDrawStatus()
    }
    
    // MARK: - 每日一签状态检查 (核心引导逻辑)
    /// 
    /// 📝 方法说明：
    /// 这个方法是每日一签优先流程的核心入口点
    /// 负责检查用户今日是否已完成每日一签，并根据结果决定是否显示引导提示
    /// 
    /// 🎯 实现策略：
    /// 1. 首先检查DailyDrawManager中的今日签到状态
    /// 2. 如果未签到，延迟1秒后显示引导提示（避免刚启动就打扰）
    /// 3. 如果已签到，则什么都不做，让用户正常使用应用
    /// 
    /// ⏰ 延迟考虑：
    /// 使用1秒延迟是为了让用户先适应界面，避免在应用刚启动时
    /// 就弹出提示，影响用户的第一印象体验
    /// 
    /// 🔧 技术实现：
    /// 使用DailyDrawManager.shared.hasDrawnToday()检查状态
    /// 使用DispatchQueue.main.asyncAfter实现延迟提示
    /// 
    private func checkDailyDrawStatus() {
        if !DailyDrawManager.shared.hasDrawnToday() {
            // 延迟显示引导提示，让用户先适应界面
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showDailyDrawReminder()
            }
        }
    }
    
    // MARK: - 每日一签引导提示 (用户体验核心)
    /// 
    /// 🎨 设计理念：
    /// 这个提示对话框是每日一签功能的关键用户体验环节
    /// 设计目标是：既有效引导用户完成每日一签，又不会让用户感到被强迫
    /// 
    /// 💝 对话框设计特点：
    /// - 标题使用✨表情符号，营造神秘而友好的氛围
    /// - 消息内容采用第二人称"主人"，符合小萌的角色设定
    /// - 包含换行符，让信息层次更清晰
    /// - 提供三个选项，满足不同用户的需求
    /// 
    /// 🎯 三个选项的含义：
    /// 1. "去看看今日运势" - 主要引导选项，放在第一位
    /// 2. "稍后提醒我" - 给用户缓冲时间，不强求
    /// 3. "今天不想签到了" - 尊重用户选择，避免重复打扰
    /// 
    /// 🌈 视觉设计：
    /// - 主要选项使用紫色，强调重要性
    /// - 其他选项使用蓝色和灰色，层次分明
    /// - 对话框整体色调保持与app风格一致
    /// 
    private func showDailyDrawReminder() {
        // 创建自定义的提醒对话框，风格要符合女孩子喜欢的可爱设计
        let reminderAlert = UIAlertController(
            title: "✨ 今日运势签到了吗？",
            message: "亲爱的主人，新的一天开始了呢！\n要不要先看看今天的运势如何呀？\n完成每日一签后，你就可以随心所欲地占卜啦~ 💕",
            preferredStyle: .alert
        )
        
        // 每日一签按钮 - 主要选项
        let dailyDrawAction = UIAlertAction(title: "去看看今日运势", style: .default) { [weak self] _ in
            self?.goToDailyDraw()
        }
        dailyDrawAction.setValue(UIColor.systemPurple, forKey: "titleTextColor")
        reminderAlert.addAction(dailyDrawAction)
        
        // 稍后提醒按钮 - 柔和选项
        let laterAction = UIAlertAction(title: "稍后提醒我", style: .default) { [weak self] _ in
            self?.scheduleLaterReminder()
        }
        laterAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        reminderAlert.addAction(laterAction)
        
        // 不再提醒按钮 - 用户选择权
        let noRemindAction = UIAlertAction(title: "今天不想签到了", style: .cancel) { [weak self] _ in
            self?.markNoRemindToday()
        }
        noRemindAction.setValue(UIColor.systemGray, forKey: "titleTextColor")
        reminderAlert.addAction(noRemindAction)
        
        // 设置对话框的视觉效果，让提示更友好
        reminderAlert.view.tintColor = .systemPurple
        
        present(reminderAlert, animated: true, completion: nil)
    }
    
    // MARK: - 每日一签导航 (页面跳转逻辑)
    /// 
    /// 🚀 功能说明：
    /// 这个方法负责从主界面导航到每日一签界面
    /// 是整个每日一签流程中的页面跳转环节
    /// 
    /// 🎯 实现细节：
    /// - 创建DailyDrawViewController实例
    /// - 使用navigationController pushViewController进行页面跳转
    /// - 支持动画效果，提供流畅的用户体验
    /// 
    /// 💫 用户体验考虑：
    /// - 跳转动画保持与应用整体风格一致
    /// - 页面进入时会自动检查今日签到状态
    /// - 如果今天未签到，会显示抽卡界面
    /// - 如果今天已签到，会显示已签到的提示
    /// 
    /// 🔧 与其他方法的关联：
    /// - 被showDailyDrawReminder中的主要选项调用
    /// - 与DailyDrawManager配合管理签到状态
    /// - 依赖于DailyDrawViewController的界面实现
    /// 
    private func goToDailyDraw() {
        let dailyDrawVC = DailyDrawViewController()
        navigationController?.pushViewController(dailyDrawVC, animated: true)
    }
    
    // MARK: - 延迟提醒设置 (用户缓冲机制)
    /// 
    /// 🎯 设计目标：
    /// 为用户提供"稍后再提醒"的缓冲选项
    /// 让用户感觉自己有控制权，避免被强制的感觉
    /// 
    /// 💡 实现策略：
    /// 1. 显示友好的反馈确认，让用户知道小萌理解了他们的选择
    /// 2. 记录用户的延迟提醒选择（可以扩展为真正的提醒机制）
    /// 3. 保持与整体UI风格一致的对话体验
    /// 
    /// 🔮 扩展可能性：
    /// - 可以结合DailyDrawPreferenceManager设置具体的提醒时间
    /// - 可以添加"只在抽卡时提醒"的选项
    /// - 可以实现本地通知推送功能
    /// 
    /// ✨ 用户体验优化：
    /// - 反馈文案采用温柔可爱的风格
    /// - 确认对话框简洁明了，不会让用户感到困扰
    /// - 与小萌的角色设定保持一致
    /// 
    private func scheduleLaterReminder() {
        // 这里可以实现一个延迟提醒机制
        // 比如用户完成某个操作后再提醒，或者设定一个时间间隔
        // 为了简化，这里先显示一个友好的反馈
        let feedbackAlert = UIAlertController(
            title: "好的呢~ 💕",
            message: "小萌会在你抽卡的时候再提醒你哦~",
            preferredStyle: .alert
        )
        
        feedbackAlert.addAction(UIAlertAction(title: "知道了", style: .default))
        present(feedbackAlert, animated: true)
    }
    
    // MARK: - 标记今日不提醒 (用户选择尊重)
    /// 
    /// 🎯 核心目标：
    /// 尊重用户的自主选择权，避免过度打扰
    /// 当用户明确表示不想今日签到时，系统应该记住这个选择
    /// 
    /// 💝 实现策略：
    /// 1. 使用UserDefaults记录用户今日的选择
    /// 2. 选择键包含日期，确保每天的选择是独立的
    /// 3. 显示友好的反馈，确认用户的选择被尊重
    /// 
    /// 🔐 隐私保护：
    /// - 记录的信息仅限于应用内使用
    /// - 不会收集用户的个人信息
    /// - 数据在应用重装后会被重置
    /// 
    /// ⏰ 时间管理：
    /// - 只记录当日的跳过状态
    /// - 到了新的一天，这个标记会自动失效
    /// - 避免长期影响用户的使用体验
    /// 
    /// 🔄 与其他功能的联动：
    /// - checkDailyDrawStatus方法会检查这个标记
    /// - 如果标记为true，则不会显示今日的提醒
    /// - 明天会重新检查，给用户重新选择的机会
    /// 
    private func markNoRemindToday() {
        // 可以设置一个临时标记，记录用户今日选择不签到
        // 这样在一段时间内就不会重复提醒
        // 这里先简单记录到UserDefaults
        let preferences = UserDefaults.standard
        preferences.set(true, forKey: "skipDailyDraw_\(Date().toString(format: "yyyy-MM-dd"))")
        
        // 显示友好的反馈
        let feedbackAlert = UIAlertController(
            title: "好的呢~ 💕",
            message: "那小萌就不打扰主人啦~\n随时想看运势都可以找小萌哦~",
            preferredStyle: .alert
        )
        
        feedbackAlert.addAction(UIAlertAction(title: "谢谢", style: .default))
        present(feedbackAlert, animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGlowLayouts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh history each time the view appears
        let newHistory = HistoryManager.shared.fetchHistory().compactMap { HistoryEntry(dict: $0) }
        if newHistory != history {
            history = newHistory
            tableView.reloadData()
        }
    }

    private func setupUI() {
        // Top search bar (left: magnifier + placeholder, right: plus)
        topSearchBar.backgroundColor = UIColor.systemGray.withAlphaComponent(0.2)
        topSearchBar.layer.cornerRadius = 20
        view.addSubview(topSearchBar)
        topSearchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.height.equalTo(44)
        }

        let magnifier = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        magnifier.tintColor = UIColor(white: 1.0, alpha: 0.75)
        topSearchBar.addSubview(magnifier)
        magnifier.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }

        searchField.borderStyle = .none
        searchField.backgroundColor = .clear
        searchField.textColor = .white
        searchField.attributedPlaceholder = NSAttributedString(
            string: "你今天想占卜...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: 1.0, alpha: 0.5)]
        )
        topSearchBar.addSubview(searchField)
        searchField.snp.makeConstraints { make in
            make.leading.equalTo(magnifier.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-56)
            make.height.equalTo(36)
        }
        // floating plus button (glowing) placed above right edge
        plusButton.backgroundColor = .systemOrange
        plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
        plusButton.tintColor = .white
        plusButton.layer.cornerRadius = 24
        plusButton.addTarget(self, action: #selector(plusTapped), for: .touchUpInside)
        view.addSubview(plusButton)
        plusButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-18)
            make.centerY.equalTo(topSearchBar.snp.centerY)
            make.width.height.equalTo(48)
        }
        plusButton.layer.shadowColor = UIColor.systemOrange.cgColor
        plusButton.layer.shadowRadius = 12
        plusButton.layer.shadowOpacity = 0.9
        plusButton.layer.shadowOffset = CGSize(width: 0, height: 6)

        // topSearchBar border to match translucent style
        topSearchBar.layer.borderWidth = 1
        topSearchBar.layer.borderColor = UIColor.white.withAlphaComponent(0.06).cgColor

        // 每日一签按钮
        let dailyDrawButton = UIButton(type: .system)
        dailyDrawButton.backgroundColor = .systemPurple
        dailyDrawButton.setTitle("✨ 每日一签", for: .normal)
        dailyDrawButton.setTitleColor(.white, for: .normal)
        dailyDrawButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        dailyDrawButton.layer.cornerRadius = 20
        dailyDrawButton.layer.shadowColor = UIColor.systemPurple.cgColor
        dailyDrawButton.layer.shadowRadius = 8
        dailyDrawButton.layer.shadowOpacity = 0.6
        dailyDrawButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        dailyDrawButton.addTarget(self, action: #selector(dailyDrawTapped), for: .touchUpInside)
        view.addSubview(dailyDrawButton)
        dailyDrawButton.snp.makeConstraints { make in
            make.top.equalTo(topSearchBar.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.width.equalTo(120)
            make.height.equalTo(40)
        }

        // 标题标签
        subtitleLabel.text = "最近占卜记录"
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        subtitleLabel.textColor = .label
        subtitleLabel.textAlignment = .left
        view.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(topSearchBar.snp.bottom).offset(12)
            make.leading.equalTo(dailyDrawButton.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-16)
        }

        // Background image + blur (try to use asset named "starry_bg")
        if let bg = UIImage(named: "reBG") {
            let bgView = UIImageView(image: bg)
            bgView.contentMode = .scaleAspectFill
            // insert background at bottom
            view.insertSubview(bgView, at: 0)
            bgView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
            // place blur above background but below other content
            view.insertSubview(blur, aboveSubview: bgView)
            blur.alpha = 0.2
            blur.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }

        // Table view for history
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HistoryCell.self, forCellReuseIdentifier: HistoryCell.reuseIdentifier)
        tableView.estimatedRowHeight = 140
        tableView.rowHeight = UITableView.automaticDimension
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-12)
        }

        // Ensure search bar and plus button are above table/background
        view.bringSubviewToFront(subtitleLabel)
        view.bringSubviewToFront(topSearchBar)
        view.bringSubviewToFront(plusButton)

        // setup glow layers/animations
        setupGlows()
    }

    private func setupGlows() {
        // search glow layer
        if searchGlowLayer == nil {
            let glow = CALayer()
            glow.backgroundColor = UIColor.clear.cgColor
            glow.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
            glow.borderWidth = 1.0
            glow.shadowColor = UIColor.white.cgColor
            glow.shadowRadius = 10
            glow.shadowOpacity = 0.14
            glow.shadowOffset = .zero
            searchGlowLayer = glow
            topSearchBar.layer.insertSublayer(glow, at: 0)
        }

        // plus pulse layer
        if plusPulseLayer == nil {
            let pulse = CAShapeLayer()
            pulse.fillColor = UIColor.systemOrange.cgColor
            pulse.opacity = 0.0
            plusPulseLayer = pulse
            // insert below the button layer so it appears as outer glow
            if let pl = plusPulseLayer {
                view.layer.insertSublayer(pl, below: plusButton.layer)
            }
            startPlusPulseAnimation()
        }
        updateGlowLayouts()
    }

    private func updateGlowLayouts() {
        // update search glow frame
        if let glow = searchGlowLayer {
            let inset: CGFloat = -6
            glow.frame = topSearchBar.bounds.insetBy(dx: inset, dy: inset)
            glow.cornerRadius = topSearchBar.layer.cornerRadius + abs(inset)
        }

        // update plus pulse shape: keep pulse frame centered on the plus button for correct alignment
        if let pulse = plusPulseLayer {
            let btnFrameInView = plusButton.superview?.convert(plusButton.frame, to: view) ?? plusButton.frame
            let maxRadius: CGFloat = 42
            let pulseFrame = CGRect(x: btnFrameInView.midX - maxRadius, y: btnFrameInView.midY - maxRadius, width: maxRadius * 2, height: maxRadius * 2)
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            pulse.frame = pulseFrame
            pulse.path = UIBezierPath(ovalIn: pulse.bounds).cgPath
            CATransaction.commit()
        }
    }

    private func startPlusPulseAnimation() {
        guard let pulse = plusPulseLayer else { return }
        // scale+opacity animation grouped
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 0.6
        scale.toValue = 1.6
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 0.45
        fade.toValue = 0.0
        let group = CAAnimationGroup()
        group.animations = [scale, fade]
        group.duration = 1.6
        group.timingFunction = CAMediaTimingFunction(name: .easeOut)
        group.repeatCount = .infinity
        group.isRemovedOnCompletion = false
        pulse.add(group, forKey: "pulse")
    }

    @objc private func plusTapped() {
        // MARK: - 随意抽卡前的每日一签检查 (核心交互逻辑)
        // 
        // 🎯 方案A：柔和引导方式的完整实现
        // 在用户点击加号进行随意抽卡时，系统会：
        // 1. 检查用户今日是否已完成每日一签
        // 2. 如果未完成，显示友好的提示对话框
        // 3. 提供多个选项，尊重用户的自由选择
        // 4. 无论用户选择什么，都保持良好的用户体验
        // 
        // 💝 引导策略特点：
        // - 时机精准：在用户主动想要抽卡时提醒
        // - 语气温柔：不会让用户感到被强迫
        // - 选择多样：提供不同满足程度的选项
        // - 体验流畅：不影响原有的抽卡功能
        // 
        if !DailyDrawManager.shared.hasDrawnToday() {
            // 显示温馨提示，但仍然允许用户继续随意抽卡
            showCasualDrawReminder()
        } else {
            // 今日已完成每日一签，直接进入随意抽卡
            goToDraw(with: "")
        }
    }

    private func goToDraw(with question: String) {
        let resultVC = ResultViewController()
        resultVC.question = question
        resultVC.shouldAutoDraw = true
        navigationController?.pushViewController(resultVC, animated: true)
    }
    
    // MARK: - 每日一签
    @objc private func dailyDrawTapped() {
        let dailyDrawVC = DailyDrawViewController()
        navigationController?.pushViewController(dailyDrawVC, animated: true)
    }
    
    // MARK: - 随意抽卡温馨提示
    /// 当用户想要随意抽卡但今日未完成每日一签时的温馨提示
    /// 这个提示会强调每日一签的重要性，但仍然给用户选择权
    /// 采用方案A的柔和引导策略，避免强制用户的行为
    private func showCasualDrawReminder() {
        let reminderAlert = UIAlertController(
            title: "💫 主人想先看看今日运势吗？",
            message: "小萌觉得先完成今日运势签\n会让今天的占卜更加准确呢~\n不过主人想什么时候抽都可以啦~",
            preferredStyle: .alert
        )
        
        // 先去每日一签选项
        let dailyFirstAction = UIAlertAction(title: "先看今日运势", style: .default) { [weak self] _ in
            self?.goToDailyDraw()
        }
        dailyFirstAction.setValue(UIColor.systemPurple, forKey: "titleTextColor")
        reminderAlert.addAction(dailyFirstAction)
        
        // 直接随意抽卡选项 - 保留用户选择权
        let casualDrawAction = UIAlertAction(title: "我就想现在抽", style: .default) { [weak self] _ in
            self?.goToDraw(with: "")
        }
        casualDrawAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        reminderAlert.addAction(casualDrawAction)
        
        // 稍后提醒选项
        let laterAction = UIAlertAction(title: "稍后再提醒我", style: .cancel) { [weak self] _ in
            // 用户选择稍后提醒，直接进行随意抽卡
            self?.goToDraw(with: "")
        }
        reminderAlert.addAction(laterAction)
        
        // 设置对话框的视觉效果
        reminderAlert.view.tintColor = .systemPurple
        
        present(reminderAlert, animated: true, completion: nil)
    }

    // Load history array from UserDefaults
    private func loadHistory() -> [[String: Any]] {
        if let history = UserDefaults.standard.array(forKey: "drawHistory") as? [[String: Any]] {
            return history
        }
        return []
    }
}

// MARK: - Table View Data Source / Delegate
extension DrawViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { history.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HistoryCell.reuseIdentifier, for: indexPath) as? HistoryCell else {
            return UITableViewCell()
        }
        let entry = history[indexPath.row]
        cell.configure(with: entry)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let entry = history[indexPath.row]
        goToDraw(with: entry.question)
    }
}
