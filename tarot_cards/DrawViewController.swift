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

        // Title label
        subtitleLabel.text = "最近占卜记录"
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        subtitleLabel.textColor = .label
        subtitleLabel.textAlignment = .left
        view.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(topSearchBar.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
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
        goToDraw(with: "")
    }

    private func goToDraw(with question: String) {
        let resultVC = ResultViewController()
        resultVC.question = question
        resultVC.shouldAutoDraw = true
        navigationController?.pushViewController(resultVC, animated: true)
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
