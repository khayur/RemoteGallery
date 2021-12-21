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
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        itemImageView.image = nil
    }
    
    func configure(item: GalleryDataItem) {
        galleryContentView.applyShadow()
        galleryContentView.layer.cornerRadius = galleryContentView.frame.height / 12
        usernameLabel.text = item.userName
        usernameGradientView.layer.cornerRadius = usernameGradientView.frame.height / 2
        itemImageView.contentMode = .scaleAspectFill

        itemImageView.load.request(with: "http://" + Constants.baseServerUrl + "/task/\(item.imageName!).jpg") { galleryImage, error, operation in
            DispatchQueue.main.async {
                self.itemImageView.image = galleryImage
            }
        }
        self.itemImageView.layer.cornerRadius = galleryContentView.frame.height / 12
    }

    //MARK: - Actions
    
}
