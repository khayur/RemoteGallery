//
//  UIStoryboard+Additions.swift
//  RemoteGallery
//
//  Created by Yury Khadatovich on 19.12.21.
//

import UIKit.UIStoryboard

enum StoryboardType: String {
    case gallery = "Gallery"
}

extension UIStoryboard {

    static let gallery = UIStoryboard(.gallery)

    convenience init(_ type: StoryboardType) {
        self.init(name: type.rawValue, bundle: nil)
    }

    func instantiate<T>(identifier: String = "") -> T {
        let identifier = identifier.isEmpty ? typeName(T.self) : identifier
        guard let controller = instantiateViewController(withIdentifier: identifier) as? T else {
            fatalError()
        }

        return controller
    }

}
