//
//  AppDelegate.swift
//  RemoteGallery
//
//  Created by Yury Khadatovich on 19.12.21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupServices()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        
        setRootController()
        return true
    }
    
    func setupServices() {
        ServiceHolder.setup()
    }

    func setRootController() {
        guard let rootController: NavigationController = UIStoryboard.gallery.instantiateViewController(withIdentifier: typeName(GalleryViewController.self)) as? NavigationController else {
            fatalError()
        }
        
        window?.setRootViewController(rootController)
    }

}

