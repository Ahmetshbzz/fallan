import SwiftUI
import PhotosUI

class ImageManager: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var imageSelection: PhotosPickerItem? {
        didSet {
            if let imageSelection = imageSelection {
                Task {
                    await loadImageFromSelection(imageSelection)
                }
            }
        }
    }
    
    @Published var showImagePicker = false
    
    func loadImageFromSelection(_ selection: PhotosPickerItem) async {
        do {
            if let data = try await selection.loadTransferable(type: Data.self) {
                await MainActor.run {
                    if let uiImage = UIImage(data: data) {
                        self.selectedImage = uiImage
                    } else {
                        print("Geçersiz görüntü verisi")
                    }
                }
            }
        } catch {
            print("Görüntü yüklenirken hata oluştu: \(error.localizedDescription)")
        }
    }
    
    func loadImage() async throws {
        guard let imageSelection else { return }
        await loadImageFromSelection(imageSelection)
    }
    
    func getImageData() -> Data? {
        guard let selectedImage else { return nil }
        return selectedImage.jpegData(compressionQuality: 0.7)
    }
    
    func resetSelection() {
        selectedImage = nil
        imageSelection = nil
    }
    
    func setImage(_ image: UIImage) {
        selectedImage = image
    }
} 