//
//  RequestData.swift
//  RemoteGallery
//
//  Created by Yury Khadatovich on 19.12.21.
//

import Foundation

typealias Parameters = [String: Any]

enum RequestContentType: String {
    case json = "application/json; charset=UTF-8"
    case urlencoded = "application/x-www-form-urlencoded"
    case multipart = "multipart/form-data"
}

enum HttpMethod: String {
    case get
    case post
    case put
    case patch
    case delete
    
    var name: String {
        return self.rawValue.uppercased()
    }
}

struct RequestData {
    var url: String
    var httpMethod: HttpMethod
    var params: Parameters = [:]
    var encode: RequestContentType = .json
    var skipError: Bool = false
    var bodyInUrl: Bool = false
    var customUrlString: String?
    var mediaFileName = ""
    
    init(endpoint: Endpoint,
         httpMethod: HttpMethod,
         params: Parameters = [:],
         contentType: RequestContentType = .json) {
        self.url = endpoint.value
        self.httpMethod = httpMethod
        self.params = params
        self.encode = contentType
    }
    
}

extension RequestData {
    
    init(endpoint: String,
         httpMethod: HttpMethod,
         params: [String : Any] = [:],
         contentType: RequestContentType = .json) {
        self.url = endpoint
        self.httpMethod = httpMethod
        self.params = params
        self.encode = contentType
    }
    
}

enum Endpoint {
    case galleryData
    case galleryImage(name: String)

    var value: String {
        switch self {
        case .galleryData:
            return "task/credits.json"
        case .galleryImage(let name):
          return "task/\(name).jpg"
        }
      }
    
}


