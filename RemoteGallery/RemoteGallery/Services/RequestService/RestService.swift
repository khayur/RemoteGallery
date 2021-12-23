//
//  RestService.swift
//  RemoteGallery
//
//  Created by Yury Khadatovich on 19.12.21.
//

import UIKit

protocol RestServiceProtocol {
    func perform<T: Decodable>(dataRequest: RequestData, completion: @escaping (Result<T>) -> Void)
}

final class RestServiceProvider {

    private let serviceQueue: OperationQueue
    private let serviceSession: URLSession

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 180
        configuration.httpMaximumConnectionsPerHost = 10
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        serviceQueue = OperationQueue()
        serviceQueue.maxConcurrentOperationCount = 3
        serviceSession = URLSession(configuration: configuration,
                                         delegate: nil,
                                         delegateQueue: serviceQueue)
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
