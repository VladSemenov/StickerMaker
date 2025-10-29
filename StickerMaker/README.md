# Sticker Maker — Vision API Practice

A simple SwiftUI app for turning photos into stickers. This project’s primary goal is to get familiar with Apple’s Vision-based image processing workflows by building a small, focused experience: pick a photo, process it into a cutout, and export a sticker.

## How it works (High level)

- You choose an image with the system photo picker.
- The app loads the selected asset and updates UI state (`imageState`).
- A filter service (e.g., subject extraction/segmentation) generates a transparent-background sticker from the image.
- The resulting `stickerImage` is displayed and can be saved or shared.

## Requirements

- iOS 18 or later (simulator or device)

## Getting Started

1. Open the project in Xcode.
2. Select an iOS Simulator (or a physical device) and press Run.
3. On first launch, grant Photos access if prompted.

## Using the App

1. Tap the photo picker button to select an image from your library.
2. Wait for the loading indicator to complete. If the image loads successfully, it will appear in the preview.
3. Tap "Generate Sticker" to process the image.
   - On success, the processed sticker (with transparent background when available) appears in the result area.
   - On failure, an error message is shown so you can try a different image.
4. Use the iOS share sheet (if provided in your UI) to export or save the sticker.

## Project Structure (Key pieces)

- StickerMakerViewModel: Manages photo selection state, loading progress, error handling, and triggers sticker generation.
- StickerFilterService: Encapsulates the image processing logic (e.g., Vision-based segmentation/masking) to create a sticker from a `UIImage`.
- SwiftUI Views: Bind to the view model’s `imageState` and `stickerImage` to reflect loading, success, and error states.

## Notes on Vision API

This project focuses on learning patterns common to Vision-backed workflows:
- Asynchronous processing with cancellation and progress reporting.
- Converting Vision outputs (masks, observations) into Core Image or UIKit-friendly images.
- Maintaining responsive UI by isolating work off the main actor and publishing results back on the main actor.

## Troubleshooting

- If the photo picker returns empty data, try selecting a different image or verify Photos permissions in Settings.
- If sticker generation fails, ensure you’re testing with subjects that have clear foreground/background separation.
- Run on a physical device for best performance when experimenting with heavier image processing.

## License

This project is for learning and experimentation. Use it as a starting point to explore and extend Vision-based image effects and sticker creation.
