//
//  UIView+Additions.swift
//  RemoteGallery
//
//  Created by Yury Khadatovich on 19.12.21.
//

import UIKit

extension UIView {
    func applyShadow(corner: CGFloat = 0.0, opacity: Float = 0.1, shadow: CGFloat = 10.0) {
            layer.masksToBounds = false
            layer.borderWidth = 0.0
            layer.cornerRadius = corner
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = opacity
            layer.shadowRadius = shadow
            layer.shadowOffset = .zero
        }
}

protocol NibLoadableView: AnyObject {
    static var nibName: String { get }
}

extension NibLoadableView where Self: UIView {
    static var nibName: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    static func instantiate() -> Self {
        return Bundle.main.loadNibNamed(nibName, owner: self, options: nil)?.first as! Self
    }
}