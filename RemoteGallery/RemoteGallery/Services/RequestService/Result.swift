//
//  Result.swift
//  RemoteGallery
//
//  Created by Yury Khadatovich on 19.12.21.
//

import Foundation

enum Result<T> {
    case success(T)
    case failure(String)
    
    init(_ value: T) {
        self = .success(value)
    }
    
    var value: T? {
        guard case let .success(value) = self else { return nil }
        return value
    }
    
    var error: String? {
        guard case let .failure(error) = self else { return nil }
        return error
    }
}

