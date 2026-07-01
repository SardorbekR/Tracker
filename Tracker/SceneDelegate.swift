//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Sardor on 6/27/26.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    // MARK: - Public Properties

    var window: UIWindow?

    // MARK: - Private Properties

    private let hasSeenOnboardingKey = "hasSeenOnboarding"

    // MARK: - UIWindowSceneDelegate

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard
            let scene = scene as? UIWindowScene,
            let coreDataStack = (UIApplication.shared.delegate as? AppDelegate)?.coreDataStack
        else {
            return
        }
        window = UIWindow(windowScene: scene)
        window?.overrideUserInterfaceStyle = .light
        window?.rootViewController = makeRootViewController(coreDataStack: coreDataStack)
        window?.makeKeyAndVisible()
    }

    // MARK: - Private Methods

    private func makeRootViewController(coreDataStack: CoreDataStack) -> UIViewController {
        if UserDefaults.standard.bool(forKey: hasSeenOnboardingKey) {
            return TabBarController(coreDataStack: coreDataStack)
        }
        let onboardingViewController = OnboardingViewController()
        let key = hasSeenOnboardingKey
        onboardingViewController.onComplete = { [weak self] in
            UserDefaults.standard.set(true, forKey: key)
            self?.window?.rootViewController = TabBarController(coreDataStack: coreDataStack)
        }
        return onboardingViewController
    }
}
