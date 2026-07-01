//
//  TabBarController.swift
//  Tracker
//
//  Created by Sardor on 6/27/26.
//

import UIKit

final class TabBarController: UITabBarController {
    // MARK: - Private Properties

    private let coreDataStack: CoreDataStack

    // MARK: - Lifecycle

    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
        configureViewControllers()
    }

    // MARK: - Setup

    private func configureTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = UIColor(resource: .ypGray)
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = UIColor(resource: .ypBlue)
        tabBar.unselectedItemTintColor = UIColor(resource: .ypGray)
    }

    private func configureViewControllers() {
        let trackersViewController = TrackersViewController(coreDataStack: coreDataStack)
        viewControllers = [
            makeNavigationController(
                rootViewController: trackersViewController,
                title: "Трекеры",
                image: UIImage(systemName: "record.circle.fill")
            ),
            makeNavigationController(
                rootViewController: StatisticsViewController(),
                title: "Статистика",
                image: UIImage(systemName: "hare.fill")
            )
        ]
    }

    private func makeNavigationController(
        rootViewController: UIViewController,
        title: String,
        image: UIImage?
    ) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.tabBarItem = UITabBarItem(title: title, image: image, selectedImage: nil)
        return navigationController
    }
}
