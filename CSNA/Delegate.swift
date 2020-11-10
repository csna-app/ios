//
//  Delegate.swift
//  CSNA
//
//  Created by Wilhelm Thieme on 06/11/2020.
//

import UIKit

@UIApplicationMain
class Delegate: UIResponder, UIApplicationDelegate {

    internal var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            UserDefaults.standard.set("\(version) (\(build))", forKey: "appVersion")
        }
        
        window = UIWindow()
        window?.rootViewController = Controller()
        window?.makeKeyAndVisible()
        
        return true
    }


}

