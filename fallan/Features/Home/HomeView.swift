import SwiftUI
import PhotosUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showHistory = false
    // Fotoğraf yükleme durumunu takip etmek için
    @State private var refreshUI = UUID()
    
    var body: some View {
        ZStack {
            // Arka plan gradyanı
            LinearGradient(
                gradient: Gradient(colors: [Color(#colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1)), Color(#colorLiteral(red: 0.3647058904, green: 0, blue: 0.5176470876, alpha: 1))]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Başlık
                Text("Fallan")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                Spacer()
                
                // İçerik alanı
                contentView
                    .id(refreshUI) // UI güncellemelerini zorla
                
                Spacer()
                
                // Alt gezinme çubuğu
                HStack {
                    Spacer()
                    
                    Button {
                        showHistory = true
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)).opacity(0.3))
                            )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .sheet(isPresented: $showHistory) {
                ReadingHistoryView(readingStore: viewModel.readingStore)
            }
            .onChange(of: viewModel.imageManager.selectedImage) { _, _ in
                // Fotoğraf yüklendiğinde UI'ı güncelle
                refreshUI = UUID()
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.state {
        case .idle:
            uploadView
                .transition(.opacity)
        case .loading:
            ProgressView()
                .scaleEffect(2)
                .tint(.white)
                .frame(maxWidth: .infinity, maxHeight: 300)
                .background(Color.black.opacity(0.2))
                .cornerRadius(20)
                .padding(.horizontal)
                .transition(.opacity)
        case .result(let text):
            resultView(text: text)
                .transition(.opacity)
        case .error(let message):
            errorView(message: message)
                .transition(.opacity)
        }
    }
    
    private var uploadView: some View {
        VStack(spacing: 20) {
            if let selectedImage = viewModel.imageManager.selectedImage {
                // Seçilen görüntü görünümü
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .cornerRadius(12)
                    .shadow(radius: 10)
                    .padding(.horizontal)
                
                HStack(spacing: 20) {
                    // Yeni fotoğraf seçme butonu
                    Button {
                        viewModel.imageManager.resetSelection()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Değiştir")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.7))
                        )
                    }
                    
                    // Analiz başlatma butonu
                    Button {
                        Task {
                            await viewModel.analyzeImage()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Analiz Et")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)), Color(#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1))]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                        )
                    }
                }
                .padding(.horizontal, 20)
            } else if viewModel.imageManager.isLoading {
                // Yükleniyor göstergesi
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(2)
                        .tint(.white)
                    
                    Text("Fotoğraf Yükleniyor...")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.2))
                .cornerRadius(20)
                .padding(.horizontal)
            } else if viewModel.imageManager.hasError {
                // Hata görünümü
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.yellow)
                    
                    Text("Fotoğraf yüklenirken bir hata oluştu.\nLütfen tekrar deneyin.")
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    photoPickerButton
                }
                .padding()
                .background(Color.black.opacity(0.3))
                .cornerRadius(20)
                .padding(.horizontal)
            } else {
                // Fotoğraf seçme görünümü
                VStack(spacing: 15) {
                    Text("Fotoğrafınızdan Kehanet Alın")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    Text("Herhangi bir fotoğrafınızı seçin ve yapay zeka size özel yorumlar üretsin")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    
                    photoPickerButton
                }
            }
        }
    }
    
    // Fotoğraf seçici butonu
    private var photoPickerButton: some View {
        PhotosPicker(
            selection: $viewModel.imageManager.imageSelection,
            matching: .images,
            photoLibrary: .shared()
        ) {
            VStack(spacing: 15) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                
                Text("Fotoğraf Seç")
                    .font(.title3.bold())
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    .blur(radius: 1)
            )
            .padding(.horizontal, 40)
        }
        .onChange(of: viewModel.imageManager.imageSelection) { _, newValue in
            if newValue != nil {
                print("Fotoğraf seçildi, yükleme başlatılıyor...")
                viewModel.imageManager.loadSelectedImage()
            }
        }
    }
    
    private func resultView(text: String) -> some View {
        VStack(spacing: 20) {
            ScrollView {
                Text(text)
                    .font(.body)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .shadow(radius: 5)
            }
            .frame(height: 300)
            
            Button {
                withAnimation {
                    viewModel.resetState()
                }
            } label: {
                Text("Yeni Fal Baktır")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)), Color(#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1))]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                    )
                    .shadow(radius: 5)
                    .padding(.horizontal, 40)
            }
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.yellow)
            
            Text(message)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
            
            Button {
                withAnimation {
                    viewModel.resetState()
                }
            } label: {
                Text("Tekrar Dene")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.red.opacity(0.7))
                    )
                    .shadow(radius: 5)
                    .padding(.horizontal, 40)
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

#Preview {
    HomeView()
} 