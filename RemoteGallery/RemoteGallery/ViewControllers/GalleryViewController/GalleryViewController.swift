//
//  GalleryViewController.swift
//  RemoteGallery
//
//  Created by Yury Khadatovich on 19.12.21.
//

import UIKit

class GalleryViewController: BaseViewController {
    
    
    // MARK: - Outlets
    
    @IBOutlet private weak var galleryCollectionView: UICollectionView!
    
    // MARK: - Variables
    
    private var interactor: InteractorProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
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
        #warning("fix")
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as GalleryItemCollectionViewCell
        cell.configure(item: GalleryDataItem())
        #warning("fix")
        return cell
    }
}

extension GalleryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return galleryCollectionView.frame.size
    }
}

