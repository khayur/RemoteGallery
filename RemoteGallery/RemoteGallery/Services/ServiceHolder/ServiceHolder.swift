//
//  ServiceHolder.swift
//  RemoteGallery
//
//  Created by Yury Khadatovich on 19.12.21.
//

import Foundation

class ServiceHolder {

    fileprivate static let shared = ServiceHolder()
    fileprivate var registry: [String: Any] = [:]
    private init() {}
    

    static func setup() {
        let requestService = RestServiceProvider()
        ServiceHolder.addService(requestService as RestServiceProtocol)
        
        let interactor = Interactor()
        ServiceHolder.addService(interactor as InteractorProtocol)
    }

    static func addService<T>(_ instance: T) {
        let key = typeName(T.self)
        shared.registry[key] = instance
    }

    static func getService<T>() -> T {
        let service: T = ServiceHolder.findService(T.self)
        return service
    }

    static func findService<T>(_: T.Type) -> T {
        let key = typeName(T.self)
        guard let registryRec = shared.registry[key] as? T else {
            print("Service instance wasn't found or isn't an protocol")
            fatalError("Service instance wasn't found or isn't an protocol")
        }
        return registryRec
    }

}
