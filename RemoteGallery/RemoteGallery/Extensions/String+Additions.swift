//
//  String+Additions.swift
//  RemoteGallery
//
//  Created by Yury Khadatovich on 22.12.21.
//

import Foundation

extension String {
    public func escape() -> String? {
        return addingPercentEncoding(withAllowedCharacters: .alphanumerics)
    }
}
