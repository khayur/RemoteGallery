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
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!

    // MARK: - Properties
    weak var delegate: ButtonsDelegate?
    var indexPath: IndexPath!
    
    // MARK: - Life Cycle
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        itemImageView.image = nil
    }
    
    func configure(item: GalleryDataItem) {
//        galleryContentView.applyShadow()
        galleryContentView.layer.cornerRadius = galleryContentView.frame.height / 12
        usernameLabel.text = item.userName
        usernameGradientView.layer.cornerRadius = usernameGradientView.frame.height / 2
        itemImageView.contentMode = .scaleAspectFill
        itemImageView.load.request(with: Constants.urlScheme + Constants.baseServerUrl + "/task/\(item.imageName!).jpg") { galleryImage, error, operation in
            DispatchQueue.main.async {
                self.itemImageView.image = galleryImage
            }
        }
        self.itemImageView.layer.cornerRadius = galleryContentView.frame.height / 12
        userButton.backgroundColor = .lightGray.withAlphaComponent(0.5)
        userButton.layer.cornerRadius = userButton.frame.height / 2
        photoButton.backgroundColor = .lightGray.withAlphaComponent(0.5)
        photoButton.layer.cornerRadius = photoButton.frame.height / 2
        userButton.titleLabel?.textColor = .white
        photoButton.titleLabel?.textColor = .white
    }

    //MARK: - Actions
    @IBAction func didPressUserButton(_ sender: Any) {
        userButton.pulsate()
        self.delegate?.userButtonPressed(at: indexPath)
    }
    @IBAction func didPressPhotoButton(_ sender: Any) {
        photoButton.pulsate()
        self.delegate?.photoButtonPressed(at: indexPath)
    }
    
}
