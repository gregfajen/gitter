//
//  AppDelegate.swift
//  Gitter
//
//  Created by Greg Fajen on 3/3/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
//        let before = """
//        a
//        b
//        c
//        """
//
//        let after = """
//        a
//        c
//        f
//        """
        
        let before = """
        A
        B
        C
        A
        B
        B
        A
        """
        
        let after = """
        C
        B
        A
        B
        A
        C
        """
        
//        let after = """
//        x
//        y
//        z
//        """
        
        let diff = Diff(before: before, after: after)
        print(diff.diff)
        print("")
        
//        let vc = RepoVC()
//        vc.repoResource.whenComplete { result in
//            print(result)
//            print("")
//        }
        
//        GitHub().getRepo()
        
//        GitHub().getPulls { result in
//            print(result)
//        }
        
//        GitHub().getFiles()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

