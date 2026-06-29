//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Sardor on 6/27/26.
//

import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func scheduleViewController(_ controller: ScheduleViewController, didSelect schedule: [Weekday])
}

final class ScheduleViewController: UIViewController {
    // MARK: - Public Properties

    weak var delegate: ScheduleViewControllerDelegate?

    // MARK: - Private Properties

    private var selectedWeekdays: Set<Weekday>

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.reuseIdentifier)
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(resource: .ypBlack)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle

    init(selectedWeekdays: [Weekday]) {
        self.selectedWeekdays = Set(selectedWeekdays)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Расписание"
        navigationItem.hidesBackButton = true
        setupLayout()
    }

    // MARK: - Setup

    private func setupLayout() {
        view.addSubview(tableView)
        view.addSubview(doneButton)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(Weekday.allCases.count) * 75),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    // MARK: - Actions

    @objc private func didTapDone() {
        let schedule = Weekday.allCases.filter { selectedWeekdays.contains($0) }
        delegate?.scheduleViewController(self, didSelect: schedule)
    }
}

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Weekday.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ScheduleCell.reuseIdentifier,
            for: indexPath
        ) as? ScheduleCell else {
            return UITableViewCell()
        }
        let weekday = Weekday.allCases[indexPath.row]
        let isLastRow = indexPath.row == Weekday.allCases.count - 1
        cell.configure(
            title: weekday.title,
            isOn: selectedWeekdays.contains(weekday),
            showDivider: !isLastRow
        )
        cell.onSwitchChanged = { [weak self] isSelected in
            if isSelected {
                self?.selectedWeekdays.insert(weekday)
            } else {
                self?.selectedWeekdays.remove(weekday)
            }
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}
