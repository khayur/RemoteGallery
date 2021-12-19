//
//  LoadingView.swift
//  RemoteGallery
//
//  Created by Yury Khadatovich on 19.12.21.
//

import UIKit

class LoadingView: BaseView {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!

    var isAnimating: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.applyShadow(corner: 4.0)
        alpha = 0.0
    }

    func start() {
        guard !isAnimating else { return }

        isAnimating = true
        indicator.startAnimating()
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.alpha = 1.0
        })
    }

    func finish() {
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.alpha = 0.0
        }, completion: {finished in
            self.indicator.stopAnimating()
            self.isAnimating = false
        })
    }

}
