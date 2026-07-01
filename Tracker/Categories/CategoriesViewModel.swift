//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by Sardor on 7/1/26.
//

import Foundation

final class CategoriesViewModel {
    // MARK: - Public Properties

    var onCategoriesChanged: (() -> Void)?
    var onCategorySelected: ((String) -> Void)?

    private(set) var selectedCategoryTitle: String?

    var isEmpty: Bool {
        categories.isEmpty
    }

    // MARK: - Private Properties

    private let store: TrackerCategoryStore

    private var categories: [TrackerCategory] {
        store.categories
    }

    // MARK: - Lifecycle

    init(store: TrackerCategoryStore, selectedCategoryTitle: String?) {
        self.store = store
        self.selectedCategoryTitle = selectedCategoryTitle
        store.delegate = self
    }

    // MARK: - Public Methods

    func numberOfCategories() -> Int {
        categories.count
    }

    func categoryTitle(at index: Int) -> String {
        categories[index].title
    }

    func isSelectedCategory(at index: Int) -> Bool {
        categories[index].title == selectedCategoryTitle
    }

    func selectCategory(at index: Int) {
        let title = categories[index].title
        selectedCategoryTitle = title
        onCategorySelected?(title)
    }

    func addCategory(_ title: String) {
        try? store.addCategory(title)
    }
}

// MARK: - TrackerCategoryStoreDelegate

extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func trackerCategoryStoreDidChange() {
        onCategoriesChanged?()
    }
}
