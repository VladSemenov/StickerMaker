import SwiftUI
import Vision
import CoreImage.CIFilterBuiltins
import UIKit

final class StickerFilterService {
    private let context = CIContext()
    private let filters = CIFilter.self

    func makeSticker(from uiImage: UIImage, outlineWidth: Double = 5.0) async throws -> UIImage? {
        guard let cgImage = uiImage.cgImage else { return nil }

        let request = GenerateForegroundInstanceMaskRequest()
        guard let observation = try await request.perform(on: cgImage) else { return nil }

        let handler = ImageRequestHandler(cgImage)
        let pixelBuffer = try observation.generateScaledMask(for: observation.allInstances, scaledToImageFrom: handler)
        let maskCI = CIImage(cvPixelBuffer: pixelBuffer)
        guard let inputCI = CIImage(image: uiImage) else { return nil }
        guard let composed = apply(mask: maskCI, to: inputCI, outlineWidth: outlineWidth) else { return nil }
        return render(ciImage: composed)
    }

    private func apply(mask: CIImage, to image: CIImage, outlineWidth: Double) -> CIImage? {
        // Cut the original by mask
        let blend = filters.blendWithMask()
        blend.inputImage = image
        blend.maskImage = mask
        blend.backgroundImage = CIImage.empty()
        guard let masked = blend.outputImage else { return nil }

        // Create white outline by morphology gradient
        let gradient = filters.morphologyGradient()
        gradient.inputImage = mask
        gradient.radius = Float(outlineWidth)
        guard let dilated = gradient.outputImage else { return masked }

        // Tint outline to white
        let white = filters.colorMatrix()
        white.inputImage = dilated
        white.rVector = CIVector(x: 1, y: 0, z: 0, w: 0)
        white.gVector = CIVector(x: 1, y: 0, z: 0, w: 0)
        white.bVector = CIVector(x: 1, y: 0, z: 0, w: 0)
        white.aVector = CIVector(x: 0, y: 0, z: 0, w: 1)
        guard let whiteOutline = white.outputImage else { return masked }

        // Composite outline behind the masked subject
        let composite = filters.sourceOverCompositing()
        composite.inputImage = masked
        composite.backgroundImage = whiteOutline
        return composite.outputImage
    }

    private func render(ciImage: CIImage) -> UIImage? {
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
