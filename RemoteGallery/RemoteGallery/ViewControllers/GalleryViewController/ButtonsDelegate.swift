//
//  ButtonsDelegate.swift
//  RemoteGallery
//
//  Created by Yury Khadatovich on 22.12.21.
//

import Foundation

protocol ButtonsDelegate: AnyObject {
    func userButtonPressed(at index: IndexPath)
    func photoButtonPressed(at index: IndexPath)
}
