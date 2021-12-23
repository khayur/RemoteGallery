//
//  Interactor.swift
//  RemoteGallery
//
//  Created by Yury Khadatovich on 19.12.21.
//

import Foundation
import UIKit

protocol InteractorProtocol {
    func getGalleryData(callback: @escaping (Result<[String: GalleryDataItem]>) -> Void)
}

class Interactor: InteractorProtocol {


    let requestService: RestServiceProtocol

    init() {
        self.requestService = ServiceHolder.getService()
    }

    func getGalleryData(callback: @escaping (Result<[String: GalleryDataItem]>) -> Void) {
        let request = RequestData(endpoint: .galleryData, httpMethod: .get, params: [:], contentType: .json)
        requestService.perform(dataRequest: request, completion: callback)
    }
}
