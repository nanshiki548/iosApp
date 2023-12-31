//
//  SceneDelegate.swift
//  InstaglamSmple
//
//  Created by 松田竜弥 on 2020/06/01.
//  Copyright © 2020 松田竜弥. All rights reserved.
//

import UIKit
import NCMB

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene as! UIWindowScene )
            self.window = window
            //self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Splash", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(identifier: "SplashViewController")
            self.window?.rootViewController = rootViewController
            self.window?.makeKeyAndVisible()
        }
    
//    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
//        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
//        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
//        guard let _ = (scene as? UIWindowScene) else { return }
//        
//        let ud = UserDefaults.standard
//        let isLogin = ud.bool(forKey: "isLogin")
//        let window = UIWindow(windowScene: scene as! UIWindowScene )
//        if isLogin == true {
//            //ログイン中だったら
//            self.window = window
//            //self.window = UIWindow(frame: UIScreen.main.bounds)
//            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//            let rootViewController = storyboard.instantiateViewController(identifier: "RootTabBarController")
//            self.window?.rootViewController = rootViewController
//            self.window?.backgroundColor = UIColor.white
//            self.window?.makeKeyAndVisible()
//            
//        }else {
//            //ログインしていなかったら
//           // self.window = UIWindow(frame: UIScreen.main.bounds)
//            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
//            let rootViewController = storyboard.instantiateViewController(identifier: "RootNavigationController")
//            self.window?.rootViewController = rootViewController
//            self.window?.backgroundColor = UIColor.white
//            self.window?.makeKeyAndVisible()
//        }
//        
//    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
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
    }


}

