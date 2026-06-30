//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Sardor on 6/27/26.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = scene as? UIWindowScene else { return }
        guard let coreDataStack = (UIApplication.shared.delegate as? AppDelegate)?.coreDataStack else {
            return
        }
        window = UIWindow(windowScene: scene)
        window?.rootViewController = TabBarController(coreDataStack: coreDataStack)
        window?.overrideUserInterfaceStyle = .light
        window?.makeKeyAndVisible()
    }
}
