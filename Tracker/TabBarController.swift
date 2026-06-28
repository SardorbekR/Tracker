//
//  TabBarController.swift
//  Tracker
//
//  Created by Sardor on 6/27/26.
//

import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let trackersViewController = TrackersViewController()
        let trackersNavigationController = UINavigationController(
            rootViewController: trackersViewController
        )
        trackersNavigationController.navigationBar.prefersLargeTitles = true
        trackersNavigationController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(systemName: "record.circle.fill"),
            selectedImage: nil
        )

        let statisticsViewController = StatisticsViewController()
        let statisticsNavigationController = UINavigationController(
            rootViewController: statisticsViewController
        )
        statisticsNavigationController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(systemName: "hare.fill"),
            selectedImage: nil
        )

        viewControllers = [trackersNavigationController, statisticsNavigationController]

        tabBar.tintColor = UIColor(resource: .ypBlue)
        tabBar.unselectedItemTintColor = UIColor(resource: .ypGray)
    }
}
