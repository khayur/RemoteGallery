//
//  Thread+Additions.swift
//  RemoteGallery
//
//  Created by Yury Khadatovich on 21.12.21.
//

import Foundation

extension Thread {
    func dispatch(block: @escaping () -> Void) {
        if Thread.current == self {
            block()
        } else {
            perform(#selector(execute(block:)), on: self, with: block, waitUntilDone: false)
        }
    }

    @objc func execute(block: () -> Void) {
        block()
    }
}
