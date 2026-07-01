//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Sardor on 6/27/26.
//

import UIKit

final class TrackersViewController: UIViewController {
    // MARK: - Private Properties

    private let defaultCategoryTitle = "Важное"

    private let trackerStore: TrackerStore
    private let trackerCategoryStore: TrackerCategoryStore
    private let trackerRecordStore: TrackerRecordStore

    private var visibleCategories: [TrackerCategory] = []
    private var currentDate = Calendar.current.startOfDay(for: Date())
    private var isSelectedDateInFuture = false

    private lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(didTapAddButton)
        )
        button.tintColor = UIColor(resource: .ypBlack)
        return button
    }()

    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        datePicker.widthAnchor.constraint(equalToConstant: 100).isActive = true
        return datePicker
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        collectionView.register(
            TrackerSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerSectionHeaderView.reuseIdentifier
        )
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .star))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(resource: .ypBlack)
        label.textAlignment = .center
        return label
    }()

    private lazy var placeholderStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [placeholderImageView, placeholderLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // MARK: - Lifecycle

    init(
        trackerStore: TrackerStore,
        trackerCategoryStore: TrackerCategoryStore,
        trackerRecordStore: TrackerRecordStore
    ) {
        self.trackerStore = trackerStore
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerRecordStore = trackerRecordStore
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        trackerStore.delegate = self
        trackerCategoryStore.delegate = self
        setupNavigationBar()
        setupCollectionView()
        setupPlaceholder()
        reload()
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        navigationItem.title = "Трекеры"
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: UIColor(resource: .ypBlack)
        ]
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupPlaceholder() {
        view.addSubview(placeholderStackView)
        NSLayoutConstraint.activate([
            placeholderStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }

    // MARK: - Private Methods

    private func reload() {
        visibleCategories = makeVisibleCategories()
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }

    private func makeVisibleCategories() -> [TrackerCategory] {
        let selectedWeekday = weekday(from: currentDate)
        return trackerCategoryStore.categories.compactMap { category in
            let trackers = category.trackers.filter { $0.schedule.contains(selectedWeekday) }
            return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
        }
    }

    private func updatePlaceholderVisibility() {
        let isEmpty = visibleCategories.isEmpty
        placeholderStackView.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }

    private func weekday(from date: Date) -> Weekday {
        let calendarWeekday = Calendar.current.component(.weekday, from: date)
        return Weekday(rawValue: (calendarWeekday + 5) % 7 + 1) ?? .monday
    }

    private func isTrackerCompleted(_ tracker: Tracker, on date: Date) -> Bool {
        trackerRecordStore.records.contains {
            $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }

    private func completedDaysCount(_ tracker: Tracker) -> Int {
        trackerRecordStore.records.filter { $0.trackerId == tracker.id }.count
    }

    // MARK: - Actions

    @objc private func didTapAddButton() {
        let createHabitViewController = CreateHabitViewController()
        createHabitViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: createHabitViewController)
        present(navigationController, animated: true)
    }

    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = Calendar.current.startOfDay(for: sender.date)
        isSelectedDateInFuture = currentDate > Calendar.current.startOfDay(for: Date())
        reload()
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        visibleCategories[section].trackers.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerCell else {
            return UICollectionViewCell()
        }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        cell.delegate = self
        cell.configure(
            name: tracker.name,
            color: tracker.color,
            emoji: tracker.emoji,
            isCompleted: isTrackerCompleted(tracker, on: currentDate),
            completedDays: completedDaysCount(tracker),
            isEnabled: !isSelectedDateInFuture
        )
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerSectionHeaderView.reuseIdentifier,
            for: indexPath
        ) as? TrackerSectionHeaderView else {
            return UICollectionReusableView()
        }
        header.configure(title: visibleCategories[indexPath.section].title)
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let interitemSpacing: CGFloat = 9
        let sectionInset: CGFloat = 16
        let availableWidth = collectionView.bounds.width - sectionInset * 2 - interitemSpacing
        return CGSize(width: availableWidth / 2, height: 148)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        9
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        16
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 46)
    }
}

// MARK: - TrackerCellDelegate

extension TrackersViewController: TrackerCellDelegate {
    func trackerCellDidToggleCompletion(_ cell: TrackerCell) {
        guard
            !isSelectedDateInFuture,
            let indexPath = collectionView.indexPath(for: cell)
        else {
            return
        }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        do {
            if isTrackerCompleted(tracker, on: currentDate) {
                try trackerRecordStore.removeRecord(trackerId: tracker.id, date: currentDate)
            } else {
                try trackerRecordStore.addRecord(trackerId: tracker.id, date: currentDate)
            }
        } catch {
            return
        }
        cell.updateCompletionState(
            isCompleted: isTrackerCompleted(tracker, on: currentDate),
            completedDays: completedDaysCount(tracker),
            isEnabled: !isSelectedDateInFuture
        )
    }
}

// MARK: - CreateHabitViewControllerDelegate

extension TrackersViewController: CreateHabitViewControllerDelegate {
    func createHabitViewController(_ controller: CreateHabitViewController, didCreate tracker: Tracker) {
        try? trackerStore.addTracker(tracker, categoryTitle: defaultCategoryTitle)
        dismiss(animated: true)
    }
}

// MARK: - TrackerStoreDelegate

extension TrackersViewController: TrackerStoreDelegate {
    func trackerStoreDidChange() {
        reload()
    }
}

// MARK: - TrackerCategoryStoreDelegate

extension TrackersViewController: TrackerCategoryStoreDelegate {
    func trackerCategoryStoreDidChange() {
        reload()
    }
}
