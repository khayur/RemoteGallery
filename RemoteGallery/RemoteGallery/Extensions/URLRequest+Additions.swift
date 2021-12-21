//
//  URLRequest+Additions.swift
//  RemoteGallery
//
//  Created by Yury Khadatovich on 19.12.21.
//

import UIKit

private let IMAGE_QUALITY_COMPRESSION: CGFloat = 0.5

extension URLRequest {
    
    static func baseUrlRequest(requestData: RequestData, cachePolicy: CachePolicy = .reloadIgnoringLocalCacheData) -> URLRequest? {
        
        let urlPath = String(format: "%@%@/%@",
                             Constants.urlScheme,
                             Constants.baseServerUrl,
                             requestData.url)

        guard let url = URL(string: requestData.customUrlString ?? urlPath) else { return nil }
        
        var request = URLRequest(url: url)
        request.cachePolicy = cachePolicy
        request.httpMethod = requestData.httpMethod.name
        request.setValue(requestData.encode.rawValue, forHTTPHeaderField: "Accept")
        request.setValue(requestData.encode.rawValue, forHTTPHeaderField: "Content-Type")
        
        switch requestData.httpMethod {
        case .get, .delete:
            guard let query = URLRequest.createQuery(from: requestData),
                let url = URL(string: "\(urlPath)?\(query)") else { break }
            #if DEBUG
            print("QUERY: \(query)")
            #endif
            request.url = url
        case .post, .put, .patch:
            request.httpBody = URLRequest.encode(data: requestData)
            
            if requestData.encode == .urlencoded, let length = request.httpBody?.count {
                request.setValue(String(describing: length), forHTTPHeaderField: "Content-Length")
            }
        }
        return request
    }
        
    private static func encode(data: RequestData) -> Data? {
        guard data.params.count > 0 else { return nil }
        switch data.encode {
        case .json:
            #if DEBUG
            if let jsonData = try? JSONSerialization.data(withJSONObject: data.params, options: JSONSerialization.WritingOptions()) as NSData {
                let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
                print("json string = \(jsonString)")
            }
            #endif
            return try? JSONSerialization.data(withJSONObject: data.params as Any, options: JSONSerialization.WritingOptions(rawValue: 0))
        case .urlencoded:
            return URLRequest.createQuery(from: data)?.data(using: String.Encoding.utf8)
        case .multipart:
            return nil
        }
    }
        
    private static func configureQueryItems(data: RequestData) -> [URLQueryItem] {
        var items: [URLQueryItem] = []
        
        for (key, value) in data.params {
            if let strValue = value as? String {
                let stringValue = URLRequest.encodeQuery(query: strValue)
                items.append(URLQueryItem(name: key, value: stringValue))
            } else {
                items.append(URLQueryItem(name: key, value: "\(value)"))
            }
        }
        
        return items
    }
    
    static func encodeQuery(query: String) -> String {
        let kAFCharactersGeneralDelimitersToEncode = ":#[]@!$&'()*+,;=";
        
        var characterSet = CharacterSet.urlQueryAllowed
        characterSet.remove(charactersIn: kAFCharactersGeneralDelimitersToEncode)
        
        return query.addingPercentEncoding(withAllowedCharacters: characterSet) ?? query
    }
    
    static func createQuery(from requestData: RequestData) -> String? {
        let urlPath = String(format: "%@%@/%@",
        Constants.urlScheme,
        Constants.baseServerUrl,
        requestData.url)
        
        guard requestData.params.count > 0, var components = URLComponents(string: urlPath) else { return nil }
        
        components.queryItems = requestData.params.reduce([], { (result, item) -> [URLQueryItem] in
            var result = result
            if let value = item.value as? String  {
                result.append(URLQueryItem(name: item.key, value: URLRequest.encode(query: value)))
            } else if let value = item.value as? [Any] {
                for element in value {
                    result.append(URLQueryItem(name: item.key, value: URLRequest.encode(query: "\(element)")))
                }
            } else {
                result.append(URLQueryItem(name: item.key, value: URLRequest.encode(query: "\(item.value)")))
            }
            return result
        })
        return components.query
    }
    
    static func encode(query: String) -> String {
        let forbiddenCharacters = ":#[]@!$&'()*+,;="
        var set: CharacterSet = .urlQueryAllowed
        set.remove(charactersIn: forbiddenCharacters)
        return query.addingPercentEncoding(withAllowedCharacters: set) ?? query
    }
    
    private static func JSONPatchEncode(data: RequestData) -> Data? {
        guard data.params.count > 0 else { return nil }
        switch data.encode {
        case .json:
            var jsonPatch: [[String: Any]] = []
            for (parameter, value) in data.params {
                var newDict: [String: Any] = ["op": "replace"]
                newDict["path"] = "/" + parameter
                newDict["value"] = value
                jsonPatch.append(newDict)
            }
            #if DEBUG
            if let jsonData = try? JSONSerialization.data(withJSONObject: jsonPatch) {
                let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
                print("json string = \(jsonString)")
            }
            #endif
            return try? JSONSerialization.data(withJSONObject: jsonPatch)
        default:
            return nil
        }
    }
}
