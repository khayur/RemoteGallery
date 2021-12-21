//
//  GalleryViewController.swift
//  RemoteGallery
//
//  Created by Yury Khadatovich on 19.12.21.
//

import UIKit
import Combine

class GalleryViewController: BaseViewController {
    
    
    // MARK: - Outlets
    
    @IBOutlet private weak var galleryCollectionView: UICollectionView!
    
    // MARK: - Variables
    
    private var interactor: InteractorProtocol!
    
    private var galleryItems: [GalleryDataItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        getGalleryItems()
    }
    
    override func configureViews() {
        galleryCollectionView.register(GalleryItemCollectionViewCell.self)
    }
    
    override func configureServices() {
        interactor = ServiceHolder.getService() as InteractorProtocol
    }
}


// MARK: - UICollectionViewDataSource

extension GalleryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return galleryItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as GalleryItemCollectionViewCell
        cell.configure(item: galleryItems[indexPath.row])
        return cell
    }
}

extension GalleryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return galleryCollectionView.frame.size
    }
}

// MARK: - Requests

extension GalleryViewController {
    private func getGalleryItems() {
        self.showLoading()
        interactor.getGalleryData { result in
            switch result {
            case .success(let items):
                var galleryItemsData: [GalleryDataItem] = []
                items.forEach { key, value in
                    value.imageName = key
                    galleryItemsData.append(value)
                }
                self.galleryItems = galleryItemsData.sorted(by: { ($0.userName ?? "") < ($1.userName ?? "") })
                self.galleryCollectionView.reloadData()
            case .failure(let error):
                print(error)
            }
            self.hideLoading()
        }
    }
}
