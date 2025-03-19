import SwiftUI
import PhotosUI

enum HomeViewState {
    case idle
    case loading
    case result(String)
    case error(String)
}

class HomeViewModel: ObservableObject {
    @Published var state: HomeViewState = .idle
    @Published var imageManager = ImageManager()
    @Published var readingStore = ReadingStore()
    
    private let geminiService = GeminiService()
    
    func analyzeImage() async {
        guard let imageData = imageManager.getImageData() else {
            await MainActor.run {
                state = .error("Lütfen bir fotoğraf seçin.")
            }
            return
        }
        
        await MainActor.run {
            state = .loading
        }
        
        do {
            let result = try await geminiService.analyzeImage(imageData)
            
            await MainActor.run {
                state = .result(result)
                _ = readingStore.saveReading(result, imageData: imageData)
            }
        } catch {
            await MainActor.run {
                state = .error("Analiz edilirken bir hata oluştu: \(error.localizedDescription)")
            }
        }
    }
    
    func resetState() {
        state = .idle
        imageManager.resetSelection()
    }
} 