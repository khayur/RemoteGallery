//
//  UICollectionView+Additions.swift
//  RemoteGallery
//
//  Created by Yury Khadatovich on 19.12.21.
//

import UIKit

extension UICollectionView {

    func register<T: UICollectionViewCell>(_ type: T.Type) where T: ReusableView, T: NibLoadableView {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        register(nib, forCellWithReuseIdentifier: typeName(T.self))
    }

    func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T where T: ReusableView {
        guard let cell = dequeueReusableCell(withReuseIdentifier: typeName(T.self), for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }
        return cell
    }

    func dequeueEmptyCell(for indexPath: IndexPath) -> UICollectionViewCell {
        let cell: EmptyCollectionViewCell = dequeueReusableCell(forIndexPath: indexPath)
        return cell
    }
}
