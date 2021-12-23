//
//  GalleryViewController.swift
//  RemoteGallery
//
//  Created by Yury Khadatovich on 19.12.21.
//

import UIKit
import WebKit


class GalleryViewController: BaseViewController, ButtonsDelegate {
    // MARK: - Outlets
    
    @IBOutlet private weak var galleryCollectionView: UICollectionView!
    
    // MARK: - Variables
    
    private var interactor: InteractorProtocol!
    private var galleryItems: [GalleryDataItem] = []
    private let webView = WebView()

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        getGalleryItems()
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }
    override func configureViews() {
        galleryCollectionView.register(GalleryItemCollectionViewCell.self)
    }
    
    override func configureServices() {
        interactor = ServiceHolder.getService() as InteractorProtocol
    }
    
    //MARK: - Methods
    func userButtonPressed(at index: IndexPath) {
        self.view.addSubview(webView)
        if let urlString = galleryItems[index.row].userURL {
        webView.load(urlString)
        }
    }
    
    func photoButtonPressed(at index: IndexPath) {
        self.view.addSubview(webView)
        if let urlString = galleryItems[index.row].photoURL {
        webView.load(urlString)
        }
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
        cell.delegate = self
        cell.indexPath = indexPath
        return cell
    }
}

//MARK: - UICollectionViewDelegate
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
