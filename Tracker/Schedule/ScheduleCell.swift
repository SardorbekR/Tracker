//
//  ScheduleCell.swift
//  Tracker
//
//  Created by Sardor on 6/27/26.
//

import UIKit

final class ScheduleCell: UITableViewCell {
    static let reuseIdentifier = "ScheduleCell"

    var onSwitchChanged: ((Bool) -> Void)?

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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(resource: .ypBackground)
        selectionStyle = .none
        contentView.addSubview(titleLabel)
        contentView.addSubview(switchView)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            switchView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, isOn: Bool) {
        titleLabel.text = title
        switchView.isOn = isOn
    }

    @objc private func switchToggled() {
        onSwitchChanged?(switchView.isOn)
    }
}
