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
    func loadImage(for item:GalleryDataItem, callback: @escaping (UIImage?) -> Void)
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

    func loadImage(for item: GalleryDataItem, callback: @escaping (UIImage?) -> Void) {
        guard let imageName = item.imageName else { callback(nil); return }
        let request = RequestData(endpoint: .galleryImage(name: imageName), httpMethod: .get, params: [:], contentType: .json)
        requestService.runImageOperation(dataRequest: request, callback: callback)
    }
}
