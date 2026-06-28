//
//  TrackerCell.swift
//  Tracker
//
//  Created by Sardor on 6/27/26.
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func trackerCellDidToggleCompletion(_ cell: TrackerCell)
}

final class TrackerCell: UICollectionViewCell {
    static let reuseIdentifier = "TrackerCell"

    weak var delegate: TrackerCellDelegate?

    private lazy var cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var emojiBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(resource: .ypBlack)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var completeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = .white
        button.layer.cornerRadius = 17
        button.addTarget(self, action: #selector(didTapComplete), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(
        name: String,
        color: UIColor,
        emoji: String,
        isCompleted: Bool,
        completedDays: Int,
        isEnabled: Bool
    ) {
        cardView.backgroundColor = color
        emojiLabel.text = emoji
        nameLabel.text = name
        counterLabel.text = dayString(for: completedDays)

        let imageName = isCompleted ? "checkmark" : "plus"
        completeButton.setImage(UIImage(systemName: imageName), for: .normal)
        completeButton.backgroundColor = color
        completeButton.alpha = isCompleted ? 0.3 : 1
        completeButton.isEnabled = isEnabled
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        emojiLabel.text = nil
        nameLabel.text = nil
        counterLabel.text = nil
        completeButton.setImage(nil, for: .normal)
    }

    private func setupViews() {
        contentView.addSubview(cardView)
        contentView.addSubview(counterLabel)
        contentView.addSubview(completeButton)
        cardView.addSubview(emojiBackgroundView)
        emojiBackgroundView.addSubview(emojiLabel)
        cardView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),

            emojiBackgroundView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),

            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),

            completeButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.heightAnchor.constraint(equalToConstant: 34),

            counterLabel.centerYAnchor.constraint(equalTo: completeButton.centerYAnchor),
            counterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            counterLabel.trailingAnchor.constraint(lessThanOrEqualTo: completeButton.leadingAnchor, constant: -8)
        ])
    }

    private func dayString(for count: Int) -> String {
        let remainderTen = count % 10
        let remainderHundred = count % 100
        if remainderTen == 1 && remainderHundred != 11 {
            return "\(count) день"
        }
        if (2...4).contains(remainderTen) && !(12...14).contains(remainderHundred) {
            return "\(count) дня"
        }
        return "\(count) дней"
    }

    @objc private func didTapComplete() {
        delegate?.trackerCellDidToggleCompletion(self)
    }
}
