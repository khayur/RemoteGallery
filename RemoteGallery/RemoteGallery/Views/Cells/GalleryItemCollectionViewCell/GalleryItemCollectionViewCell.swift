//
//  GalleryItemCollectionViewCell.swift
//  RemoteGallery
//
//  Created by Yury Khadatovich on 19.12.21.
//

import UIKit

class GalleryItemCollectionViewCell: BaseCollectionViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var galleryContentView: UIView!
    @IBOutlet private weak var itemImageView: UIImageView!
    @IBOutlet private weak var usernameGradientView: UIView!
    @IBOutlet private weak var usernameLabel: UILabel!
    
    // MARK: - Life Cycle
    
    func configure(item: GalleryDataItem) {
        galleryContentView.applyShadow()
        galleryContentView.layer.cornerRadius = galleryContentView.frame.height / 12
        galleryContentView.clipsToBounds = true
        usernameLabel.text = "\(arc4random().hashValue)"
        galleryContentView.layoutSubviews()
    }
}
