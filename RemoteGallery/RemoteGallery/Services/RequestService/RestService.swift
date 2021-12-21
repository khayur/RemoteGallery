//
//  RestService.swift
//  RemoteGallery
//
//  Created by Yury Khadatovich on 19.12.21.
//

import UIKit

protocol RestServiceProtocol {
    func perform<T: Decodable>(dataRequest: RequestData, completion: @escaping (Result<T>) -> Void)
    func runImageOperation(dataRequest: RequestData, callback: @escaping (UIImage?) -> ())
}

let cache = NSCache<NSString, UIImage>()

final class RestServiceProvider {

    private let serviceQueue: OperationQueue
    private let serviceSession: URLSession

    private let mediaQueue: OperationQueue
    private let mediaSession: URLSession

    var imageObservers: [String: [(UIImage?) -> ()]] = [:]
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 180
        configuration.httpMaximumConnectionsPerHost = 10
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        serviceQueue = OperationQueue()
        serviceQueue.maxConcurrentOperationCount = 1
        serviceSession = URLSession(configuration: configuration,
                                         delegate: nil,
                                         delegateQueue: serviceQueue)

        mediaQueue = OperationQueue()
        mediaQueue.maxConcurrentOperationCount = 1
        mediaQueue.qualityOfService = .default
        mediaSession = URLSession(configuration: configuration,
                                       delegate: nil,
                                       delegateQueue: self.mediaQueue)
    }
}


// MARK: - WebServiceProtocol

extension RestServiceProvider: RestServiceProtocol {
    func perform<T: Decodable>(dataRequest: RequestData, completion: @escaping (Result<T>) -> Void) {

        guard let request = URLRequest.baseUrlRequest(requestData: dataRequest) else { completion(.failure("Unknown")); return }

        #if DEBUG
        print("\n URL:\(String(describing: request.url)):\n  \n-> \(dataRequest.params)\n")
        #endif
        
        let dataTask = self.serviceSession.dataTask(with: request) { [weak self] (data, response, error) -> Void in
            URLCache.shared.removeAllCachedResponses()
            guard let self = self else { return }
            #if DEBUG
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            print("\n [\(dataRequest.httpMethod.name)] URL:\(String(describing: request.url))")
            print("\n code: \(statusCode) \n-> \(String(data: data ?? Data(), encoding: String.Encoding.utf8)!)\n")
            #endif
            
            let responseHandler: ((Result<T>) -> Void) = { result in
                switch result {
                case .success(let value):
                    completion(.success(value))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            self.handleResponse(data: data, response: response, error: error, responseHandler: responseHandler)
        }
        dataTask.resume()
    }

    func runImageOperation(dataRequest: RequestData, callback: @escaping (UIImage?) -> ()) {

        guard let request: URLRequest = URLRequest.baseUrlRequest(requestData: dataRequest, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData) else { callback(nil); return }
        guard let path = request.url?.absoluteString else { callback(nil); return }

        if let cachedImage = cache.object(forKey: path as NSString) {
            callback(cachedImage)
        }

        if var observers = self.imageObservers[path] {
            observers.append(callback)
            self.imageObservers[path] = observers
            return
        }
        self.imageObservers[path] = [callback]

        let task = self.mediaSession.dataTask(with: request, completionHandler: { [weak self] (data, response, error) -> Void in
            guard let `self` = self else { return }

            var responseImage: UIImage?
            if let data = data, let image = UIImage(data: data) {
                responseImage = image
                cache.setObject(image, forKey: path as NSString)
            }

            DispatchQueue.main.async {
                self.imageObservers[path]?.forEach { $0(responseImage) }
                self.imageObservers.removeValue(forKey: path)
            }
        })
        task.priority = 0.25
        task.resume()
    }
}

// MARK: - Private methods
extension RestServiceProvider {

    private func handleResponse<T: Decodable>(data: Data?, response: URLResponse?, error: Error?, responseHandler: @escaping (Result<T>) -> Void) -> Void {
        URLCache.shared.removeAllCachedResponses()
        guard var data = data, let response = response else {
            DispatchQueue.main.sync {
                responseHandler(.failure(error?.localizedDescription ?? "Unknown"))
            }
            return
        }

        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0

        if data.isEmpty, let emptyJSONData = try? JSONSerialization.data(withJSONObject: [:], options: .prettyPrinted) {
            data = emptyJSONData
        }
        #if DEBUG
        print("\n ◁ URL:\(String(describing: response.url))")
        print("\n code: \(statusCode) \n-> \(String(data: data, encoding: String.Encoding.utf8)!)\n")
        #endif

        DispatchQueue.main.async {
            switch statusCode {
            case 200..<300:
                guard let parsedData = try? JSONDecoder().decode(T.self, from: data) else {
                    responseHandler(Result.failure("Error"))
                    return
                }
                responseHandler(.success(parsedData))
            default:
                responseHandler(Result.failure("Error"))
            }
        }
    }
}
