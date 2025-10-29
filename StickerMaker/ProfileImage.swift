//
//  ProfileImage.swift
//  StickerMaker
//
//  Created by Vladislav Semenov on 25/10/2025.
//

import SwiftUI
import Photos
import UIKit

enum TransferError: Error {
    case importFailed
}

struct ProfileImage: Transferable {
    let image: Image
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
        #if canImport(AppKit)
            guard let nsImage = NSImage(data: data) else {
                throw TransferError.importFailed
            }
            let image = Image(nsImage: nsImage)
            return ProfileImage(image: image)
        #elseif canImport(UIKit)
            guard let uiImage = UIImage(data: data) else {
                throw TransferError.importFailed
            }
            let image = Image(uiImage: uiImage)
            return ProfileImage(image: image)
        #else
            throw TransferError.importFailed
        #endif
        }
    }
}

