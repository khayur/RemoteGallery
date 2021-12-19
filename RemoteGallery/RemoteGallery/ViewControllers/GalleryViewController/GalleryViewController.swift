//
//  GalleryViewController.swift
//  RemoteGallery
//
//  Created by Yury Khadatovich on 19.12.21.
//

import UIKit

class GalleryViewController: BaseViewController {
    
    private var interactor: InteractorProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureServices() {
        interactor = ServiceHolder.getService() as InteractorProtocol
    }
}
