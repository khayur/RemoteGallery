//
//  GalleryDataItem.swift
//  RemoteGallery
//
//  Created by Yury Khadatovich on 19.12.21.
//

import Foundation

class GalleryDataItem: Decodable {
    var photoURL: String?
    var userURL: String?
    var userName: String?
    var colors: [String]?
    var imageName: String?
    
    var imageURL: URL? {
        if let imageName = self.imageName {
            return URL(string: "http://dev.bgsoft.biz/task/\(imageName).jpg")
        } else {
            return nil
        }
    }

    enum CodingKeys: String, CodingKey {
        case photoURL = "photo_url"
        case userURL = "user_url"
        case userName = "user_name"
        case colors
    }
}

