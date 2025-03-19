import SwiftUI
import PhotosUI

class ImageManager: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var imageSelection: PhotosPickerItem?
    @Published var isLoading = false
    @Published var hasError = false
    
    // Seçilen görüntüyü yükle
    func loadSelectedImage() {
        guard let selection = imageSelection else { return }
        
        // Zaten aynı görüntü yüklenmişse tekrar yüklemeye gerek yok
        if isLoading { return }
        
        // UI durumlarını sıfırla ve yükleme moduna geç
        Task { @MainActor in
            self.isLoading = true
            self.hasError = false
            self.selectedImage = nil
        }
        
        print("Fotoğraf yükleme başladı...")
        
        Task {
            do {
                guard let data = try await selection.loadTransferable(type: Data.self) else {
                    print("Fotoğraf verisi alınamadı")
                    await setError()
                    return
                }
                
                guard let image = UIImage(data: data) else {
                    print("Alınan veri fotoğrafa dönüştürülemedi")
                    await setError()
                    return
                }
                
                // UI güncellemesi için MainActor'a geç
                await MainActor.run {
                    print("Fotoğraf başarıyla yüklendi: \(image.size.width)x\(image.size.height)")
                    self.isLoading = false
                    self.selectedImage = image
                    
                    // UI güncellemesi için yardımcı bir değişiklik
                    self.objectWillChange.send()
                }
            } catch {
                print("Görüntü yükleme hatası: \(error.localizedDescription)")
                await setError()
            }
        }
    }
    
    // Geriye dönük uyumluluk için bu metodu koruyalım
    func updateImageSelection(_ selection: PhotosPickerItem?) {
        // Seçim sıfırlanmışsa (iptal edilmişse), tüm durumu sıfırla
        if selection == nil {
            Task { @MainActor in
                self.selectedImage = nil
                self.imageSelection = nil
                self.isLoading = false
                self.hasError = false
                self.objectWillChange.send()
            }
            return
        }
        
        // Seçim değişmişse yeni görüntüyü yükle
        if selection?.itemIdentifier != imageSelection?.itemIdentifier {
            imageSelection = selection
            loadSelectedImage()
        }
    }
    
    // Hata durumunu ayarla
    @MainActor
    private func setError() {
        hasError = true
        isLoading = false
        selectedImage = nil
        objectWillChange.send()
    }
    
    // JPEG veri formatını döndür 
    func getImageData() -> Data? {
        guard let selectedImage else { return nil }
        return selectedImage.jpegData(compressionQuality: 0.8)
    }
    
    // Tüm seçimleri sıfırla
    func resetSelection() {
        Task { @MainActor in
            self.selectedImage = nil
            self.imageSelection = nil
            self.isLoading = false
            self.hasError = false
            self.objectWillChange.send()
        }
    }
} 