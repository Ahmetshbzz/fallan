import SwiftUI
import PhotosUI
import Combine

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
    
    init() {
        // ImageManager'dan gelen değişiklikleri dinle
        setupObservers()
    }
    
    private func setupObservers() {
        // ImageManager'dan gelen değişiklikleri dinlemek için yöntem ayarla
        imageManager.objectWillChange.sink { [weak self] _ in
            guard let self = self else { return }
            
            // ImageManager değişikliklerini UI'a yansıt
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }.store(in: &cancelBag)
    }
    
    // Abonelikleri saklamak için
    private var cancelBag = Set<AnyCancellable>()
    
    func analyzeImage() async {
        guard let imageData = imageManager.getImageData() else {
            await MainActor.run {
                state = .error("Lütfen bir fotoğraf seçin veya yüklenen fotoğrafın geçerli olduğundan emin olun.")
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
                // Daha kullanıcı dostu hata mesajı
                let errorMessage: String
                if let networkError = error as? NetworkError {
                    switch networkError {
                    case .invalidURL:
                        errorMessage = "API bağlantısı oluşturulamadı. Lütfen daha sonra tekrar deneyin."
                    case .invalidResponse:
                        errorMessage = "Sunucudan geçersiz bir yanıt alındı. Lütfen daha sonra tekrar deneyin."
                    case .invalidData:
                        errorMessage = "Alınan veri işlenemedi. Farklı bir fotoğraf deneyin."
                    }
                } else {
                    errorMessage = "Analiz edilirken bir hata oluştu: \(error.localizedDescription)"
                }
                state = .error(errorMessage)
            }
        }
    }
    
    func resetState() {
        state = .idle
        imageManager.resetSelection()
    }
} 