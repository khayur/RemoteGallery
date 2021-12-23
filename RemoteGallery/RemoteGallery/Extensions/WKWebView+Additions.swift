//
//  WKWebView+Additions.swift
//  RemoteGallery
//
//  Created by Yury Khadatovich on 22.12.21.
//
import WebKit

extension WKWebView {
    func load(_ urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            load(request)
        }
    }
}
