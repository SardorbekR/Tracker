//
//  ScheduleCell.swift
//  Tracker
//
//  Created by Sardor on 6/27/26.
//

import UIKit

final class ScheduleCell: UITableViewCell {
    // MARK: - Static Properties

    static let reuseIdentifier = "ScheduleCell"

    // MARK: - Public Properties

    var onSwitchChanged: ((Bool) -> Void)?

    // MARK: - Private Properties

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = UIColor(resource: .ypBlack)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var switchView: UISwitch = {
        let switchView = UISwitch()
        switchView.onTintColor = UIColor(resource: .ypBlue)
        switchView.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
        switchView.translatesAutoresizingMaskIntoConstraints = false
        return switchView
    }()

    private lazy var dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(resource: .ypGray)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(resource: .ypBackground)
        selectionStyle = .none
        contentView.addSubview(titleLabel)
        contentView.addSubview(switchView)
        contentView.addSubview(dividerView)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            switchView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dividerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dividerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dividerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(title: String, isOn: Bool, showDivider: Bool) {
        titleLabel.text = title
        switchView.isOn = isOn
        dividerView.isHidden = !showDivider
    }

    // MARK: - Actions

    @objc private func switchToggled() {
        onSwitchChanged?(switchView.isOn)
    }
}
