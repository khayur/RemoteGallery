//
//  UIButton+Additions.swift
//  RemoteGallery
//
//  Created by Yury Khadatovich on 22.12.21.
//

import Foundation
import UIKit

extension UIButton {
    func pulsate() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.3
        pulse.fromValue = 0.95
        pulse.toValue = 1.0
        layer.add(pulse, forKey: nil)
    }
}
