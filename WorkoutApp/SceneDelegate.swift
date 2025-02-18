//
//  SceneDelegate.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 12/31/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var logTabBarItem: UITabBarItem!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        if Settings.shared.accentColor == nil && Settings.shared.customAccentColor == nil {
            Settings.shared.accentColor = .blue
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateTheme),
                                               name: UIUserInterfaceStyle.valueChangedNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateAccentColor),
                                               name: AccentColor.valueChangedNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateLogBadge),
                                               name: Settings.logBadgeValueChangedNotification,
                                               object: nil)

        let tabBarController = UITabBarController()

        let workoutDao = WorkoutDao(context: CoreDataStack.shared.mainContext, backgroundContext: CoreDataStack.shared.newBackgroundContext())
        let workoutService = WorkoutService(workoutDao: workoutDao)
        
        let workoutViewController = WorkoutViewController(workoutService: workoutService)
        let logViewController = LogViewController(workoutService: workoutService)
        let progressViewController = ProgressViewController(workoutService: workoutService)
        let settingsViewController = SettingsTableViewController()
        logViewController.delegate = progressViewController
        logViewController.progressDelegate = progressViewController
        
        workoutViewController.tabBarItem = UITabBarItem(title: "Workout", image: UIImage(systemName: "dumbbell.fill"), tag: 0)
        logViewController.tabBarItem = UITabBarItem(title: "Log", image: UIImage(systemName: "calendar"), tag: 0)
        progressViewController.tabBarItem = UITabBarItem(title: "Progress", image: UIImage(systemName: "chart.bar.fill"), tag: 0)
        settingsViewController.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape.fill"), tag: 0)
        
        progressViewController.loadViewIfNeeded()

        tabBarController.viewControllers = [workoutViewController, logViewController, progressViewController, settingsViewController].map { UINavigationController(rootViewController: $0) }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        logTabBarItem = logViewController.tabBarItem
        updateTheme()
        updateAccentColor()
        updateLogBadge()
        window?.windowScene = windowScene
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
    
    @objc func updateTheme() {
        window?.overrideUserInterfaceStyle = Settings.shared.theme
    }
    
    @objc func updateAccentColor() {
        window?.tintColor = Settings.shared.selectedAccentColor
    }
    
    
    @objc func updateLogBadge() {
        if Settings.shared.logBadgeValue == 0 {
            logTabBarItem.badgeValue = nil
        } else {
            logTabBarItem.badgeValue = String(Settings.shared.logBadgeValue)
        }
    }
    

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
//        CoreDataStack.shared.saveContext()
    }


}

