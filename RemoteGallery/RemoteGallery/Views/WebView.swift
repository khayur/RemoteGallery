//
//  WebView.swift
//  RemoteGallery
//
//  Created by Yury Khadatovich on 22.12.21.
//

import UIKit
import WebKit
import Foundation

class WebView: WKWebView {
    //    var closeButton: UIButton?
    
    //MARK: - Lifecycle
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setUpNavigationBar()
    }
    
    func setUpNavigationBar() {
        let closeButton = UIButton(type: .close)
        let buttonSide: CGFloat = 35
        closeButton.frame = CGRect(x: 0, y: 0, width: buttonSide, height: buttonSide)
        closeButton.addTarget(self, action: #selector(WebView.didPressCloseButton(sender:)), for: .touchUpInside)
        
        let buttonView = UIView(frame: CGRect(x: 0, y: 0, width: self.scrollView.frame.width, height: 100))
        buttonView.backgroundColor = .white
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.addSubview(closeButton)
        self.scrollView.addSubview(buttonView)
        
        let closeButtonConstraints = [
            closeButton.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor, constant: -10),
            closeButton.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor, constant:  10)
        ]
        NSLayoutConstraint.activate(closeButtonConstraints)
        
        let buttonViewConstraints = [
            buttonView.topAnchor.constraint(equalTo: self.topAnchor),
            buttonView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            buttonView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            buttonView.heightAnchor.constraint(equalToConstant: buttonView.frame.height),
        ]
        NSLayoutConstraint.activate(buttonViewConstraints)
        self.scrollView.contentInset = UIEdgeInsets(top: buttonView.frame.height / 2, left: 0, bottom: 0, right: 0)
    }
    
    @objc func didPressCloseButton(sender: UIButton!) {
        sender.pulsate()
        self.removeFromSuperview()
    }
}
