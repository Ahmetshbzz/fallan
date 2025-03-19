import SwiftUI
import PhotosUI

class ImageManager: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var imageSelection: PhotosPickerItem? {
        didSet {
            Task {
                try await loadImage()
            }
        }
    }
    
    func loadImage() async throws {
        guard let imageSelection else { return }
        
        do {
            if let data = try await imageSelection.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    self.selectedImage = uiImage
                }
            }
        } catch {
            print("Görüntü yüklenirken hata oluştu: \(error.localizedDescription)")
            throw error
        }
    }
    
    func getImageData() -> Data? {
        guard let selectedImage else { return nil }
        return selectedImage.jpegData(compressionQuality: 0.7)
    }
    
    func resetSelection() {
        selectedImage = nil
        imageSelection = nil
    }
} 