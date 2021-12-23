//
//  Constants.swift
//  RemoteGallery
//
//  Created by Yury Khadatovich on 19.12.21.
//

import UIKit

struct Constants {
    static let animationDuration = 0.25
    
    static let urlScheme = "http://"
    static let baseServerUrl = "dev.bgsoft.biz"
}

/// Converting type's name to String
/// - Parameter some: Type that will be converted to String
/// - Returns: String value of parameter's name
func typeName(_ some: Any) -> String {
    return (some is Any.Type) ? "\(some)" : "\(type(of: some))"
}
