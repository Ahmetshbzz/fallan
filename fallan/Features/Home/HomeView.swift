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
        ZStack {
            // Arka plan efekti
            VStack {
                // Yıldızlar efekti
                ForEach(0..<20, id: \.self) { _ in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.1...0.3)))
                        .frame(width: Double.random(in: 1...3), height: Double.random(in: 1...3))
                        .position(
                            x: Double.random(in: 0...UIScreen.main.bounds.width),
                            y: Double.random(in: 0...400)
                        )
                        .blur(radius: 0.5)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack(spacing: 25) {
                // Sonuç başlığı
                HStack {
                    Image(systemName: "sparkles")
                        .font(.system(size: 24))
                        .foregroundColor(Color(#colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)))
                    
                    Text("Senin İçin Kehanet")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 24))
                        .foregroundColor(Color(#colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)))
                }
                .padding(.top, 10)
                
                // Süslü ayırıcı çizgi
                HStack(spacing: 15) {
                    Line()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .white.opacity(0.5), .clear]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 1, dash: [5, 5])
                        )
                        .frame(height: 1)
                    
                    Image(systemName: "moon.stars.fill")
                        .foregroundColor(Color(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)))
                        .font(.system(size: 16))
                    
                    Line()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .white.opacity(0.5), .clear]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 1, dash: [5, 5])
                        )
                        .frame(height: 1)
                }
                .frame(height: 20)
                .padding(.horizontal)
                
                // İçerik kutusu
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        // Paragrafları ayırıp her birini kendi görünümünde göster
                        ForEach(paragraphs(from: text), id: \.self) { paragraph in
                            HStack(alignment: .top, spacing: 10) {
                                // Her paragrafın başında bir sembol koy
                                if paragraph.contains("uyarı") || paragraph.contains("dikkat") {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(Color(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)))
                                        .font(.system(size: 16))
                                } else if paragraph.contains("öneri") || paragraph.contains("tavsiye") {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(Color(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)))
                                        .font(.system(size: 16))
                                } else {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(Color(#colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)))
                                        .font(.system(size: 16))
                                }
                                
                                Text(paragraph)
                                    .font(.system(size: 16, weight: .regular, design: .serif))
                                    .foregroundColor(.white)
                                    .lineSpacing(6)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(#colorLiteral(red: 0.1, green: 0.05, blue: 0.3, alpha: 0.7)),
                                        Color(#colorLiteral(red: 0.2, green: 0.1, blue: 0.4, alpha: 0.7))
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.white.opacity(0.3),
                                                Color.white.opacity(0.1)
                                            ]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                }
                .frame(height: 350)
                
                // Ek bilgi
                Text("Bu yorum fotoğrafınızın analizine dayanarak üretilmiştir")
                    .font(.caption)
                    .foregroundColor(Color.white.opacity(0.6))
                    .italic()
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                
                // Yeni fal butonu
                Button {
                    withAnimation {
                        viewModel.resetState()
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Yeni Fal Baktır")
                            .fontWeight(.semibold)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 25)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)), Color(#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1))]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .shadow(color: Color(#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)).opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.vertical)
            }
        }
    }
    
    // Metni paragraflara ayırma
    private func paragraphs(from text: String) -> [String] {
        // Eğer paragraflar yoksa, kendi cümle yapısına göre bölme
        let paragraphs = text.components(separatedBy: "\n\n")
        if paragraphs.count > 1 {
            return paragraphs
        }
        
        // Eğer sadece bir paragraf varsa, uzun cümlelere böl
        let sentences = text.components(separatedBy: ". ")
        
        // Cümleleri gruplandır (her grupta yaklaşık 2-3 cümle olsun)
        var result: [String] = []
        var temp = ""
        var charCount = 0
        
        for (index, sentence) in sentences.enumerated() {
            let sentenceWithPeriod = index < sentences.count - 1 ? sentence + "." : sentence
            
            if charCount + sentenceWithPeriod.count > 150 {
                // Mevcut grup yeterince uzun, yeni bir grup başlat
                if !temp.isEmpty {
                    result.append(temp)
                }
                temp = sentenceWithPeriod
                charCount = sentenceWithPeriod.count
            } else {
                // Mevcut gruba ekle
                if !temp.isEmpty {
                    temp += " "
                }
                temp += sentenceWithPeriod
                charCount += sentenceWithPeriod.count
            }
        }
        
        // Son grubu ekle
        if !temp.isEmpty {
            result.append(temp)
        }
        
        return result
    }
    
    // Çizgi çizme için Shape
    struct Line: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
            return path
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