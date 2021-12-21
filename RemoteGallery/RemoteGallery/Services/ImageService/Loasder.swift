//
//  Loasder.swift
//  RemoteGallery
//
//  Created by Yury Khadatovich on 21.12.21.
//

import Foundation

import Foundation
import UIKit

public struct Loader {

    unowned let delegate: ImageLoader.LoaderManager
    let task: URLSessionDataTask
    let operative = Operative()
    let url: URL

    init(_ task: URLSessionDataTask, url: URL, delegate: ImageLoader.LoaderManager) {
        self.task = task
        self.url = url
        self.delegate = delegate
    }

    public var state: URLSessionTask.State {
        return task.state
    }

    public func resume() {
        task.resume()
    }

    public func cancel() {
        task.cancel()

        let reason = "Cancel to request: \(url)"
        onFailure(with: NSError(domain: "Imageloader", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey: reason]))
    }

    func complete(with error: Error?) {
        if let error = error {
            onFailure(with: error)
            return
        }

        if let image = UIImage.process(data: operative.receiveData) {
            onSuccess(with: image)
            delegate.disk.set(operative.receiveData, forKey: url)
            return
        }

        if let statusCode = (task.response as? HTTPURLResponse)?.statusCode, statusCode >= 200, statusCode < 400 {
            let reason = "Disconnect on downloading caused by HTTPStatusCode: \(statusCode)"
            onFailure(with: NSError(domain: "Imageloader", code: statusCode, userInfo: [NSLocalizedFailureReasonErrorKey: reason]))
            return
        }

        failOnConvertToImage()
    }

    private func failOnConvertToImage() {
        onFailure(with: NSError(domain: "Imageloader", code: -999, userInfo: [NSLocalizedFailureReasonErrorKey: "Failure when convert image"]))
    }

    private func onSuccess(with image: UIImage) {
        operative.tasks.forEach { task in
            task.onCompletion(image, nil, .network)
        }
        operative.tasks = []
        delegate.remove(self)
    }

    private func onFailure(with error: Error) {
        operative.tasks.forEach { task in
            task.onCompletion(nil, error, .error)
        }
        operative.tasks = []
        delegate.remove(self)
    }
}

extension Loader: Equatable {}

public func ==(lhs: Loader, rhs: Loader) -> Bool {
    return lhs.task == rhs.task
}


public struct Loadable<Base> {

    let base: Base
    init(_ base: Base) {
        self.base = base
    }
}

public protocol LoadableCompatible {
    associatedtype CompatibleType

    var load: Loadable<CompatibleType> { get }
}

extension LoadableCompatible {

    public var load: Loadable<Self> {
        return Loadable(self)
    }
}

extension UIImageView: LoadableCompatible {}
