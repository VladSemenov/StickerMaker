import SwiftUI
import PhotosUI
import UIKit
import Combine

class StickerMakerViewModel: ObservableObject {
    enum ImageState: Equatable {
        case empty
        case loading(Progress)
        case success(UIImage)
        case failure(Error)
        
        static func == (lhs: ImageState, rhs: ImageState) -> Bool {
            switch (lhs, rhs) {
            case (.empty, .empty):
                return true
            case (.loading(let lhsProgress), .loading(let rhsProgress)):
                return lhsProgress.completedUnitCount == rhsProgress.completedUnitCount &&
                    lhsProgress.totalUnitCount == rhsProgress.totalUnitCount
            case (.success(let lhsImage), .success(let rhsImage)):
                return lhsImage == rhsImage
            case (.failure(let lhsError), .failure(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }
    
    @Published var selectedPhoto: PhotosPickerItem? {
        didSet {
            onSelectedPhotoChange(selectedPhoto)
        }
    }
    @MainActor @Published var imageState: ImageState = .empty
    @MainActor @Published var stickerImage: UIImage?
    
    private let filterService = StickerFilterService()
    
    func onSelectedPhotoChange(_ photo: PhotosPickerItem?) {
        guard let photo else {
            imageState = .empty
            return
        }
        let progress = loadTransferable(from: photo)
        imageState = .loading(progress)
    }
    
    private func loadTransferable(from item: PhotosPickerItem) -> Progress {
        let progress = item.loadTransferable(type: Data.self) { [weak self] result in
            let newState: ImageState
            switch result {
            case .success(let data?):
                if let uiImage = UIImage(data: data) {
                    newState = .success(uiImage)
                } else {
                    newState = .failure(StickerMakerViewModelImageError.invalidImageData)
                }
            case .success(nil):
                newState = .failure(StickerMakerViewModelImageError.emptyData)
            case .failure(let error):
                newState = .failure(error)
            }
            
            Task { @MainActor [weak self] in
                self?.imageState = newState
            }
        }
        return progress
    }
    
    func generateSticker() {
        // Read the image state on the main actor to avoid races
        let image: UIImage?
        if case .success(let img) = imageState {
            image = img
        } else {
            image = nil
        }
        guard let image else { return }
        Task { [weak self] in
            if let sticker = try? await self?.filterService.makeSticker(from: image) {
                await MainActor.run { [weak self] in
                    self?.stickerImage = sticker
                }
            } else {
                await MainActor.run { [weak self] in
                    self?.imageState = .failure(StickerMakerViewModelImageError.failedToProcessImage)
                }
            }
        }
    }
    
    enum StickerMakerViewModelImageError: LocalizedError {
        case invalidImageData
        case emptyData
        case failedToProcessImage
        
        var errorDescription: String? {
            switch self {
            case .invalidImageData:
                return "Failed to create image from the selected data."
            case .emptyData:
                return "No image data was found."
            case .failedToProcessImage:
                return "Failed to process the selected image."
            }
        }
    }
}

