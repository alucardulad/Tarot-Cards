//
//  FavoritesViewController.swift
//  tarot_cards
//
//  Created by 陈柔 on 2026/2/8.
//

import UIKit
import SnapKit
import SwifterSwift

class FavoritesViewController: UIViewController {

    // MARK: - 属性

    private let tableView = UITableView()
    private var favorites: [TarotCard] = []
    private let emptyView: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()
    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "还没有收藏的卡牌哦~\n点❤️去收藏吧~"
        l.textAlignment = .center
        l.textColor = ThemeManager.shared.secondaryColor
        l.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return l
    }()
    private let emptyImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "heart.slash.fill")
        iv.tintColor = ThemeManager.shared.secondaryColor
        iv.contentMode = .scaleAspectFit
        iv.transform = CGAffineTransform(scaleX: -1, y: 1)
        return iv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // 设置统一导航栏
        setupUnifiedNavigationBar(title: "我的收藏")

        // 设置统一背景特效
        setupPageBackground(hasStarfield: true, hasAmbientLight: true)

        view.backgroundColor = .clear

        setupUI()
        loadFavorites()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        ParticleManager.updateBounds(for: view)
    }

    deinit {
        ParticleManager.cleanup(for: view)
    }

    // MARK: - 背景特效

    private func setupBackgroundEffects() {
        let colors = [
            UIColor(hex: "2D1344").cgColor,
            UIColor(hex: "1E1233").cgColor,
            UIColor(hex: "120632").cgColor
        ]
        let backgroundLayer = CAGradientLayer()
        backgroundLayer.colors = colors
        backgroundLayer.startPoint = CGPoint(x: 0.5, y: 0)
        backgroundLayer.endPoint = CGPoint(x: 0.5, y: 1)
        backgroundLayer.locations = [0.0, 0.5, 1.0]
        backgroundLayer.frame = view.bounds
        view.layer.insertSublayer(backgroundLayer, at: 0)

        let ambientLightView = UIView()
        ambientLightView.backgroundColor = ThemeManager.shared.secondaryColor
        ambientLightView.alpha = 0.08
        view.addSubview(ambientLightView)
        ambientLightView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.layoutIfNeeded()
    }

    // MARK: - UI布局

    private func setupUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tableView.register(FavoriteCell.self, forCellReuseIdentifier: "FavoriteCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = 120

        // 空状态视图
        emptyView.addSubview(emptyImageView)
        emptyView.addSubview(emptyLabel)
        view.addSubview(emptyView)

        emptyImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(100)
        }

        emptyLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyImageView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
        }
    }

    private func loadFavorites() {
        favorites = FavoriteManager.shared.getAllFavorites()

        if favorites.isEmpty {
            tableView.isHidden = true
            emptyView.isHidden = false
        } else {
            tableView.isHidden = false
            emptyView.isHidden = true
            tableView.reloadData()
        }

        updateTitle()
    }

    func updateTitle() {
        let count = FavoriteManager.shared.getFavoritesCount()
        title = "❤️ 收藏 (\(count))"
    }

    /// 由 cell 调用：切换指定卡牌的收藏状态并刷新列表
    func handleToggleFavorite(cardId: Int) {
        if let card = favorites.first(where: { $0.id == cardId }) {
            _ = FavoriteManager.shared.toggleFavorite(card)
            loadFavorites()
        }
    }

    private func refreshFavorites() {
        loadFavorites()
    }
}

// MARK: - UITableViewDataSource

extension FavoritesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as! FavoriteCell
        let card = favorites[indexPath.row]
        cell.configure(with: card)
        cell.tableView = tableView
        cell.favoritesVC = self
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let card = favorites[indexPath.row]
            FavoriteManager.shared.removeFavorite(card)
            favorites.remove(at: indexPath.row)

            tableView.deleteRows(at: [indexPath], with: .fade)

            if favorites.isEmpty {
                tableView.isHidden = true
                emptyView.isHidden = false
            }

            updateTitle()
        }
    }
}

// MARK: - UITableViewDelegate

extension FavoritesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let card = favorites[indexPath.row]

        // 创建卡牌详情页面
        let detailVC = CardDetailViewController()
        detailVC.card = card
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - FavoriteCell

class FavoriteCell: UITableViewCell {

    private let cardView: CardDisplayView = {
        let v = CardDisplayView()
        v.isUserInteractionEnabled = false
        return v
    }()

    private let heartButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        btn.setImage(UIImage(systemName: "heart"), for: .normal)
        btn.tintColor = .systemRed
        btn.backgroundColor = UIColor(white: 1, alpha: 0.15)
        btn.layer.cornerRadius = 20
        return btn
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }

    private func setupSubviews() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(cardView)
        contentView.addSubview(heartButton)
        heartButton.addTarget(self, action: #selector(heartButtonTapped), for: .touchUpInside)

        cardView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(80)
        }

        heartButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(8)
            make.width.height.equalTo(36)
        }

        let infoContainer = UIStackView()
        infoContainer.axis = .vertical
        infoContainer.spacing = 8
        contentView.addSubview(infoContainer)

        let nameLabel = UILabel()
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        nameLabel.textColor = ThemeManager.shared.textColor
        infoContainer.addArrangedSubview(nameLabel)

        let directionLabel = UILabel()
        directionLabel.font = UIFont.systemFont(ofSize: 14)
        directionLabel.textColor = .secondaryLabel
        infoContainer.addArrangedSubview(directionLabel)

        let meaningLabel = UILabel()
        meaningLabel.font = UIFont.systemFont(ofSize: 13)
        meaningLabel.textColor = ThemeManager.shared.secondaryColor
        meaningLabel.numberOfLines = 2
        infoContainer.addArrangedSubview(meaningLabel)

        infoContainer.snp.makeConstraints { make in
            make.leading.equalTo(cardView.snp.trailing).offset(16)
            make.trailing.equalTo(heartButton.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
        }
    }

    func configure(with card: TarotCard) {
        cardView.configure(with: card)
        heartButton.isSelected = FavoriteManager.shared.isFavorite(card)
        heartButton.tag = card.id
    }

    @objc private func heartButtonTapped() {
        let tag = heartButton.tag
        favoritesVC?.handleToggleFavorite(cardId: tag)
    }

    weak var tableView: UITableView?
    weak var favoritesVC: FavoritesViewController?
}

