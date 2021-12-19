//
//  NavigationController.swift
//  RemoteGallery
//
//  Created by Yury Khadatovich on 19.12.21.
//

import UIKit

class NavigationController: UINavigationController {

    @IBInspectable var color: UIColor?

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        navigationBar.setup(barColor: color)
        view.backgroundColor = color
    }

    override var modalPresentationStyle: UIModalPresentationStyle {
        get {
            return .fullScreen
        }
        set {}
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return viewControllers.last?.preferredStatusBarStyle ?? .lightContent
    }
}
