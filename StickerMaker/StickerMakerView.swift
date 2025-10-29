//
//  StickerMakerView.swift
//  StickerMaker
//
//  Created by Vladislav Semenov on 25/10/2025.
//

import SwiftUI
import PhotosUI
import UIKit

struct StickerMakerView: View {
    @StateObject private var viewModel = StickerMakerViewModel()
    
    var body: some View {
        Group {
            switch viewModel.imageState {
            case .empty:
                Text("")
            case .loading(let progress):
                ProgressView(value: progress.fractionCompleted)
            case .success(let image):
                VStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding()
                    
                    Button {
                        viewModel.generateSticker()
                    } label: {
                        Text("Make a sticker")
                    }
                    
                    if let stickerImage = viewModel.stickerImage {
                        Image(uiImage: stickerImage)
                            .resizable()
                            .scaledToFit()
                            .padding()
                    }
                }
            case .failure(let error):
                Text("Failed: \(error.localizedDescription)")
                    .foregroundStyle(.red)
            }
        }
        .overlay(alignment: .topTrailing) {
            PhotosPicker(selection: $viewModel.selectedPhoto,
                         matching: .images,
                         photoLibrary: .shared()) {
                Image(systemName: "pencil.circle.fill")
                    .symbolRenderingMode(.multicolor)
                    .font(.system(size: 30))
                    .foregroundColor(.accentColor)
            }
        }
    }
}

#Preview {
    StickerMakerView()
}
