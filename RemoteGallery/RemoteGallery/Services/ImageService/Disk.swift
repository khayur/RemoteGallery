//
//  Disk.swift
//  RemoteGallery
//
//  Created by Yury Khadatovich on 21.12.21.
//

import Foundation

private let _ioQueueDisk = DispatchQueue(label: "gallery.imageloader.queues.disk.set")

public struct Disk {

    let directory = Directory()
    let storage = HashStorage<String, Data>()

    public init() {
    }

    struct Directory {

        init() {
            createDirectory()
        }
    }
}

extension Disk.Directory {

    fileprivate func createDirectory() {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            return
        }

        do {
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch _ {
        }
    }

    var path: String {
        let cacheDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        let directoryName = "gallery.imageloader.disk"

        return cacheDirectory + "/" + directoryName
    }
}


extension Disk {

    public func cleanUp() {
        let manager = FileManager.default
        for subpath in manager.subpaths(atPath: directory.path) ?? [] {
            let path = directory.path + "/" + subpath
            do {
                try manager.removeItem(atPath: path)
            } catch _ {
            }
        }
    }

    public func get(_ aKey: String) -> Data? {
        if let data = storage[aKey] {
            return data
        }
        return (try? Data(contentsOf: URL(fileURLWithPath: _path(aKey))))
    }

    public func get(_ aKey: URL) -> Data? {
        guard let key = aKey.absoluteString.escape() else { return nil }

        return get(key)
    }

    public func _path(_ name: String) -> String {
        return directory.path + "/" + name
    }

    public func set(_ anObject: Data, forKey aKey: String) {
        storage[aKey] = anObject

        let block: () -> Void = {
            do {
                try anObject.write(to: URL(fileURLWithPath: self._path(aKey)), options: [])
                self.storage[aKey] = nil
            } catch _ {}
        }

        _ioQueueDisk.async(execute: block)
    }

    public func set(_ anObject: Data, forKey aKey: URL) {
        guard let key = aKey.absoluteString.escape() else { return }
        set(anObject, forKey: key)
    }
}


