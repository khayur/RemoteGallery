//
//  ImageLoader.swift
//  RemoteGallery
//
//  Created by Yury Khadatovich on 21.12.21.
//

import UIKit

struct ImageLoader {
    @discardableResult
     static func request(with url: URLLiteralConvertible, onCompletion: @escaping (UIImage?, Error?, FetchOperation) -> Void) -> Loader? {
        guard let imageLoaderUrl = url.imageLoaderURL else { return nil }

        let task = Task(nil, onCompletion: onCompletion)
        let loader = ImageLoader.session.getLoader(with: imageLoaderUrl, task: task)
        loader.resume()

        return loader
    }

    static var session: ImageLoader.Session {
        return Session.shared
    }

    static var manager: ImageLoader.LoaderManager {
        return Session.manager
    }

    class Session: NSObject, URLSessionDataDelegate {

        static let shared = Session()
        static let manager = LoaderManager()

        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
            guard let loader = getLoader(with: dataTask) else { return }
            loader.operative.receiveData.append(data)
        }

        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
            completionHandler(.allow)
        }

        func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
            guard let loader = getLoader(with: task) else { return }
            loader.complete(with: error)
        }

        func getLoader(with dataTask: URLSessionTask) -> Loader? {
            guard let url = dataTask.originalRequest?.url else { return nil }
            return ImageLoader.manager.storage[url]
        }

        func getLoader(with url: URL, task: Task) -> Loader {
            let loader = ImageLoader.manager.getLoader(with: url)
            loader.operative.update(task)
            return loader
        }
    }

    class LoaderManager {

        let session: URLSession
        let storage = HashStorage<URL, Loader>()
        var disk = Disk()

        init(configuration: URLSessionConfiguration = .default) {
            self.session = URLSession(configuration: .default, delegate: ImageLoader.session, delegateQueue: nil)
        }

        func getLoader(with url: URL) -> Loader {
            if let loader = storage[url] {
                return loader
            }

            let loader = Loader(session.dataTask(with: url), url: url, delegate: self)
            storage[url] = loader
            return loader
        }

        func getLoader(with url: URL, task: Task) -> Loader {
            let loader = getLoader(with: url)
            loader.operative.update(task)
            return loader
        }

        func remove(_ loader: Loader) {
            guard let url = storage.getKey(loader) else { return }

            storage[url] = nil
        }
    }
}

extension Data {

    enum FileType {
        case png
        case jpeg
        case gif
        case tiff
        case webp
        case Unknown
    }

    internal var fileType: FileType {
        let fileHeader = getFileHeader(capacity: 2)
      
        switch fileHeader {
        case [0x47, 0x49]:
            return .gif
        case [0xFF, 0xD8]:
            // FF D8 FF DB
            // FF D8 FF E0
            // FF D8 FF E1
            return .jpeg
        case [0x89, 0x50]:
            // 89 50 4E 47
            return .png
        default:
            return .Unknown
        }
    }

    internal func getFileHeader(capacity: Int) -> [UInt8] {

        var pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: capacity)

        (self as NSData).getBytes(pointer, length: capacity)

        var header = [UInt8]()
        for _ in 0 ..< capacity {
            header.append(pointer.pointee)
            pointer += 1
        }

        return header
    }
}

private let lock = NSRecursiveLock()

// MARK: Optimize image
extension UIImage {

    func adjust(_ size: CGSize, scale: CGFloat, contentMode: UIView.ContentMode) -> UIImage {
        lock.lock()
        defer { lock.unlock() }

        if images?.count ?? 0 > 1 {
            return self
        }

        switch contentMode {
        case .scaleToFill:
            if size.width * scale > self.size.width || size.height * scale > self.size.height {
                return self
            }

            let fitSize = CGSize(width: size.width * scale, height: size.height * scale)
            return render(fitSize)
        case .scaleAspectFit:
            if size.width * scale > self.size.width || size.height * scale > self.size.height {
                return self
            }

            let downscaleSize = CGSize(width: self.size.width / scale, height: self.size.height / scale)
            let ratio = size.width/downscaleSize.width < size.height/downscaleSize.height ? size.width/downscaleSize.width : size.height/downscaleSize.height

            let fitSize = CGSize(width: downscaleSize.width * ratio * scale, height: downscaleSize.height * ratio * scale)
            return render(fitSize)
        case .scaleAspectFill:
            if size.width * scale > self.size.width || size.height * scale > self.size.height {
                return self
            }

            let downscaleSize = CGSize(width: self.size.width / scale, height: self.size.height / scale)
            let ratio = size.width/downscaleSize.width > size.height/downscaleSize.height ? size.width/downscaleSize.width : size.height/downscaleSize.height

            let fitSize = CGSize(width: downscaleSize.width * ratio * scale, height: downscaleSize.height * ratio * scale)
            return render(fitSize)
        default:
            return self
        }
    }

    func render(_ size: CGSize) -> UIImage {
        lock.lock()
        defer { lock.unlock() }

        if size.width == 0 || size.height == 0 {
            return self
        }

        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        return UIGraphicsGetImageFromCurrentImageContext()!
    }

    internal static func process(data: Data) -> UIImage? {
        switch data.fileType {
        case .gif:
            guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
            let result = source.process()
            return UIImage.animatedImage(with: result.images, duration: result.duration)
        case .png, .jpeg, .tiff, .webp, .Unknown:
            return UIImage(data: data)
        }
    }

    static func decode(_ data: Data) -> UIImage? {
        lock.lock()
        defer { lock.unlock() }

        return UIImage(data: data)
    }
}


private var ImageLoaderRequestUrlKey = 0
private let _ioQueue = DispatchQueue(label: "swift.imageloader.queues.io", attributes: .concurrent)

extension UIImageView {
    fileprivate var requestUrl: URL? {
        get {
            var requestUrl: URL?
            _ioQueue.sync {
                requestUrl = objc_getAssociatedObject(self, &ImageLoaderRequestUrlKey) as? URL
            }

            return requestUrl
        }
        set(newValue) {
            _ioQueue.async {
                objc_setAssociatedObject(self, &ImageLoaderRequestUrlKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}

extension Loadable where Base: UIImageView {

    @discardableResult
    func request(with url: URLLiteralConvertible, options: [Option] = []) -> Loader? {
        return request(with: url, placeholder: nil, options: options, onCompletion: { _,_,_  in })
    }

    @discardableResult
    func request(with url: URLLiteralConvertible, options: [Option] = [], onCompletion: @escaping (UIImage?, Error?, FetchOperation) -> Void) -> Loader? {
        return request(with: url, placeholder: nil, options: options, onCompletion: onCompletion)
    }

    @discardableResult
    func request(with url: URLLiteralConvertible, placeholder: UIImage?, options: [Option] = [], onCompletion: @escaping (UIImage?, Error?, FetchOperation) -> Void) -> Loader? {
        guard let imageLoaderUrl = url.imageLoaderURL else { return nil }

        let imageCompletion: (UIImage?, Error?, FetchOperation) -> Void = { image, error, operation in
            guard var image = image else { return onCompletion(nil, error, operation)  }

            DispatchQueue.main.async {
                if options.contains(.adjustSize) {
                    image = image.adjust(self.base.frame.size, scale: UIScreen.main.scale, contentMode: self.base.contentMode)
                }
                if let images = image.images, images.count > 0, let gif = UIImage.animatedImage(with: images, duration: 1) {
                    image = gif
                }
                self.base.image = image
                onCompletion(image, error, operation)
            }
        }

        let task = Task(base, onCompletion: imageCompletion)

        // cancel
        if let requestUrl = base.requestUrl {
            let loader = ImageLoader.manager.getLoader(with: requestUrl)
            loader.operative.remove(task)
            if requestUrl != imageLoaderUrl, loader.operative.tasks.isEmpty {
                loader.cancel()
            }
        }
        base.requestUrl = url.imageLoaderURL

        // disk
        base.image = placeholder ?? nil
        if let data = ImageLoader.manager.disk.get(imageLoaderUrl), let image = UIImage.process(data: data) {
            task.onCompletion(image, nil, .disk)
            return nil
        }

        // request
        let loader = ImageLoader.manager.getLoader(with: imageLoaderUrl, task: task)
        loader.resume()

        return loader
    }
}

extension CGImageSource {

    internal var imageCount: Int {
        return CGImageSourceGetCount(self)
    }

    internal func process() -> (images: [UIImage], duration: TimeInterval) {
        var images = [UIImage]()
        let count = imageCount
        let duration: Double = Double(count) * 0.2 // TODO: implementation
        for i in 0 ..< count {
            if let cgImage = getCGImage(index: i) {
                images.append(UIImage(cgImage: cgImage))
            }
        }

        return (images, duration)
    }

    internal func getCGImage(index: Int) -> CGImage? {
        return CGImageSourceCreateImageAtIndex(self, index, nil)
    }
}
